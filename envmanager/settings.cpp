// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "settings.h"
#include "config.h"
#include "utils.h"

#include <KRuntimePlatform>

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDebug>
#include <QProcess>

using namespace Qt::Literals::StringLiterals;

const QString CONFIG_FILE = u"plasmamobilerc"_s;
const QString SAVED_CONFIG_GROUP = u"SavedConfig"_s;

// In bin/startplasmamobile, we add `~/.config/plasma-mobile` to XDG_CONFIG_DIRS to overlay our own configs
const QString MOBILE_KWINRC_FILE = u"plasma-mobile/kwinrc"_s;
const QString MOBILE_KSMSERVERRC_FILE = u"plasma-mobile/ksmserverrc"_s;
const QString MOBILE_KDEGLOBALS_FILE = u"plasma-mobile/kdeglobals"_s;

Settings::Settings(QObject *parent)
    : QObject{parent}
    , m_isMobilePlatform{KRuntimePlatform::runtimePlatform().contains(u"phone"_s)}
    , m_mobileConfig{KSharedConfig::openConfig(CONFIG_FILE, KConfig::SimpleConfig)}
    , m_appBlacklistConfig{KSharedConfig::openConfig(u"applications-blacklistrc"_s, KConfig::SimpleConfig)}
{
}

Settings &Settings::self()
{
    static Settings settings;
    return settings;
}

void Settings::applyConfiguration()
{
    if (!m_isMobilePlatform) {
        qCDebug(LOGGING_CATEGORY) << "Configuration will not be applied, as the session is not Plasma Mobile.";
        qCDebug(LOGGING_CATEGORY) << "Restoring any previously saved configuration...";
        loadSavedConfiguration();
        return;
    }

    qCDebug(LOGGING_CATEGORY) << "Checking and applying mobile configuration...";
    applyMobileConfiguration();
}

void Settings::loadSavedConfiguration()
{
    // kwinrc (legacy, we only write in the plasma-mobile/kwinrc file now)
    auto originalKwinrcConfig = KSharedConfig::openConfig(u"kwinrc"_s, KConfig::SimpleConfig);
    loadKeys(u"kwinrc"_s, originalKwinrcConfig, getKwinrcSettings(m_mobileConfig));
    originalKwinrcConfig->sync();
    reloadKWinConfig();

    // applications-blacklistrc
    loadKeys(u"applications-blacklistrc"_s, m_appBlacklistConfig, APPLICATIONS_BLACKLIST_DEFAULT_SETTINGS);
    m_appBlacklistConfig->sync();

    // kdeglobals (legacy, we only write in the plasma-mobile/kdeglobals file now)
    auto originalKdeglobalsConfig = KSharedConfig::openConfig(u"kdeglobals"_s, KConfig::SimpleConfig);
    loadKeys(u"kdeglobals"_s, originalKdeglobalsConfig, KDEGLOBALS_SETTINGS);
    originalKdeglobalsConfig->sync();

    // save our changes
    m_mobileConfig->sync();
}

void Settings::applyMobileConfiguration()
{
    // kwinrc
    {
        auto kwinSettings = getKwinrcSettings(m_mobileConfig);
        setOptionsImmutable(false, MOBILE_KWINRC_FILE, kwinSettings);

        auto kwinrc = kwinrcConfig();
        writeKeys(MOBILE_KWINRC_FILE, kwinrc, kwinSettings);
        writeKeys(MOBILE_KWINRC_FILE, kwinrc, KWINRC_DEFAULT_SETTINGS); // only write, don't make immutable
        kwinrc->sync();
        reloadKWinConfig();

        setOptionsImmutable(true, MOBILE_KWINRC_FILE, kwinSettings);
    }

    // applications-blacklistrc
    {
        writeKeysAndSave(u"applications-blacklistrc"_s,
                         m_appBlacklistConfig,
                         APPLICATIONS_BLACKLIST_DEFAULT_SETTINGS,
                         true); // only write entries if they are not already defined in the config
        m_appBlacklistConfig->sync();
    }

    // kdeglobals
    {
        setOptionsImmutable(false, MOBILE_KDEGLOBALS_FILE, KDEGLOBALS_SETTINGS);

        auto kdeglobals = KSharedConfig::openConfig(MOBILE_KDEGLOBALS_FILE, KConfig::SimpleConfig);
        writeKeys(MOBILE_KDEGLOBALS_FILE, kdeglobals, KDEGLOBALS_DEFAULT_SETTINGS); // only write, don't make immutable
        writeKeys(MOBILE_KDEGLOBALS_FILE, kdeglobals, KDEGLOBALS_SETTINGS);
        kdeglobals->sync();

        setOptionsImmutable(true, MOBILE_KDEGLOBALS_FILE, KDEGLOBALS_SETTINGS);
    }

    // ksmserver
    {
        setOptionsImmutable(false, MOBILE_KSMSERVERRC_FILE, KSMSERVER_SETTINGS);

        auto ksmserver = KSharedConfig::openConfig(MOBILE_KSMSERVERRC_FILE, KConfig::SimpleConfig);
        writeKeys(MOBILE_KSMSERVERRC_FILE, ksmserver, KSMSERVER_SETTINGS);
        ksmserver->sync();

        setOptionsImmutable(true, MOBILE_KSMSERVERRC_FILE, KSMSERVER_SETTINGS);
    }

    // save our changes
    m_mobileConfig->sync();
}

void Settings::writeKeys(const QString &fileName, KSharedConfig::Ptr &config, const QMap<QString, QMap<QString, QVariant>> &settings)
{
    const auto groupNames = settings.keys();
    for (const auto &groupName : groupNames) {
        auto group = KConfigGroup{config, groupName};

        const auto keys = settings[groupName].keys();
        for (const auto &key : keys) {
            group.writeEntry(key, settings[groupName][key], KConfigGroup::Notify);
        }
    }
}

void Settings::writeKeysAndSave(const QString &fileName,
                                KSharedConfig::Ptr &config,
                                const QMap<QString, QMap<QString, QVariant>> &settings,
                                bool overwriteOnlyIfEmpty)
{
    const auto groupNames = settings.keys();
    for (const auto &groupName : groupNames) {
        auto group = KConfigGroup{config, groupName};

        const auto keys = settings[groupName].keys();
        for (const auto &key : keys) {
            if (!group.hasKey(key) || !overwriteOnlyIfEmpty) {
                // save key
                saveConfigSetting(fileName, groupName, key, group.readEntry(key));

                // overwrite with mobile setting
                group.writeEntry(key, settings[groupName][key], KConfigGroup::Notify);
            }
        }
    }
}

void Settings::loadKeys(const QString &fileName, KSharedConfig::Ptr &config, const QMap<QString, QMap<QString, QVariant>> &settings)
{
    const auto groupNames = settings.keys();
    for (const auto &groupName : groupNames) {
        const auto group = KConfigGroup{config, groupName};

        const auto keys = settings[groupName].keys();
        for (const auto &key : keys) {
            loadSavedConfigSetting(config, fileName, groupName, key);
        }
    }
}

// NOTE: this only saves a value if it hasn't already been saved
void Settings::saveConfigSetting(const QString &fileName, const QString &group, const QString &key, const QVariant value)
{
    // These are not const because we are writing an entry
    auto savedGroup = KConfigGroup{m_mobileConfig, SAVED_CONFIG_GROUP};
    auto fileGroup = KConfigGroup{&savedGroup, fileName};
    auto keyGroup = KConfigGroup{&fileGroup, group};

    if (!keyGroup.hasKey(key)) {
        qCDebug(LOGGING_CATEGORY) << "In" << fileName << "saved" << key << "=" << value;
        keyGroup.writeEntry(key, value);
    }
}

// NOTE: this deletes the stored value from the config after loading
const QString Settings::loadSavedConfigSetting(KSharedConfig::Ptr &config, const QString &fileName, const QString &group, const QString &key, bool write)
{
    auto savedGroup = KConfigGroup{m_mobileConfig, SAVED_CONFIG_GROUP};
    auto fileGroup = KConfigGroup{&savedGroup, fileName};
    auto keyGroup = KConfigGroup{&fileGroup, group};

    if (!keyGroup.hasKey(key)) {
        return {};
    }

    const auto value = keyGroup.readEntry(key);

    // write to real config
    auto configGroup = KConfigGroup{config, group};

    if ((!configGroup.hasKey(key) || configGroup.readEntry(key) != value) && write) {
        qCDebug(LOGGING_CATEGORY) << "In" << fileName << "loading saved value of" << key << "which is" << value << "in" << group;

        if (value.isEmpty()) { // delete blank entries!
            configGroup.deleteEntry(key);
        } else {
            configGroup.writeEntry(key, value, KConfigGroup::Notify);
        }
    }

    // remove saved config option
    keyGroup.deleteEntry(key);
    return value;
}

KSharedConfig::Ptr Settings::kwinrcConfig() const
{
    return KSharedConfig::openConfig(MOBILE_KWINRC_FILE, KConfig::SimpleConfig);
}

void Settings::reloadKWinConfig()
{
    // Reload config
    QDBusMessage reloadMessage = QDBusMessage::createSignal("/KWin", "org.kde.KWin", "reloadConfig");
    QDBusConnection::sessionBus().send(reloadMessage);

    // Effects need to manually be loaded/unloaded in a live KWin session.

    KConfigGroup pluginsGroup{kwinrcConfig(), QStringLiteral("Plugins")};

    for (const auto &effect : KWIN_EFFECTS) {
        // Read from the config whether the effect is enabled (settings are suffixed with "Enabled", ex. blurEnabled)
        bool status = pluginsGroup.readEntry(effect + u"Enabled"_s, false);
        const QString method = status ? u"loadEffect"_s : u"unloadEffect"_s;

        QDBusMessage message = QDBusMessage::createMethodCall(u"org.kde.KWin"_s, u"/Effects"_s, u"org.kde.kwin.Effects"_s, method);
        message.setArguments({effect});
        QDBusConnection::sessionBus().send(message);
    }

    auto group = KConfigGroup{m_mobileConfig, QStringLiteral("General")};
    bool convergenceModeEnabled = group.readEntry("convergenceModeEnabled", false);

    // previously used, disabled now due to deprecation
    for (const auto &script : KWIN_SCRIPTS_DISABLED) {
        pluginsGroup.writeEntry(script + u"Enabled"_s, false);
        qCDebug(LOGGING_CATEGORY) << " disabled script in kwinrc:" << script;
    }
    for (const auto &script : KWIN_SCRIPTS_MOBILE) {
        pluginsGroup.writeEntry(script + u"Enabled"_s, !convergenceModeEnabled);
        qCDebug(LOGGING_CATEGORY) << " mobile script in kwinrc:" << script << "(convergenceModeEnabled ==" << convergenceModeEnabled << ")";
    }

    // Unload KWin scripts that are now disabled.
    for (const auto &script : KWIN_SCRIPTS) {
        // Read from the config whether the effect is enabled (settings are suffixed with "Enabled", ex. blurEnabled)
        bool status = pluginsGroup.readEntry(script + u"Enabled"_s, !convergenceModeEnabled);
        qCDebug(LOGGING_CATEGORY) << "unloading disabled script:" << script << "mobile mode?" << (!convergenceModeEnabled);
        // bool status = pluginsGroup.readEntry(script + u"Enabled"_s, false);
        qCDebug(LOGGING_CATEGORY) << "unloading disabled script:" << script;
        if (!status) {
            qCDebug(LOGGING_CATEGORY) << "unloading disabled script:" << script;
            QDBusMessage message = QDBusMessage::createMethodCall(u"org.kde.KWin"_s, u"/Scripting"_s, u"org.kde.kwin.Scripting"_s, u"unloadScript"_s);
            message.setArguments({script});
            QDBusConnection::sessionBus().send(message);
        } else {
            qCDebug(LOGGING_CATEGORY) << "enabled script:" << script << "(will reload)";
        }
    }

    // Call "start" to load enabled KWin scripts.
    QDBusMessage message = QDBusMessage::createMethodCall(u"org.kde.KWin"_s, u"/Scripting"_s, u"org.kde.kwin.Scripting"_s, u"start"_s);
    QDBusConnection::sessionBus().send(message);

    // Call reconfigure
    QDBusMessage reconfigureMessage = QDBusMessage::createSignal("/KWin", "org.kde.KWin", "reconfigure");
    QDBusConnection::sessionBus().send(reconfigureMessage);
}
