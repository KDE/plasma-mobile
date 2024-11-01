// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
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

Settings::Settings(QObject *parent)
    : QObject{parent}
    , m_isMobilePlatform{KRuntimePlatform::runtimePlatform().contains(u"phone"_s)}
    , m_mobileConfig{KSharedConfig::openConfig(CONFIG_FILE, KConfig::SimpleConfig)}
    , m_kwinrcConfig{KSharedConfig::openConfig(u"kwinrc"_s, KConfig::SimpleConfig)}
    , m_appBlacklistConfig{KSharedConfig::openConfig(u"applications-blacklistrc"_s, KConfig::SimpleConfig)}
    , m_kdeglobalsConfig{KSharedConfig::openConfig(u"kdeglobals"_s, KConfig::SimpleConfig)}
    , m_configWatcher{KConfigWatcher::create(m_mobileConfig)}
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
    // kwinrc
    loadKeys(u"kwinrc"_s, m_kwinrcConfig, getKwinrcSettings(m_mobileConfig));
    m_kwinrcConfig->sync();
    reloadKWinConfig();

    // applications-blacklistrc
    loadKeys(u"applications-blacklistrc"_s, m_appBlacklistConfig, APPLICATIONS_BLACKLIST_DEFAULT_SETTINGS);
    m_appBlacklistConfig->sync();

    // kdeglobals
    loadKeys(u"kdeglobals"_s, m_kdeglobalsConfig, KDEGLOBALS_DEFAULT_SETTINGS);
    loadKeys(u"kdeglobals"_s, m_kdeglobalsConfig, KDEGLOBALS_SETTINGS);
    m_kdeglobalsConfig->sync();

    // save our changes
    m_mobileConfig->sync();
}

void Settings::applyMobileConfiguration()
{
    // kwinrc
    writeKeys(u"kwinrc"_s, m_kwinrcConfig, getKwinrcSettings(m_mobileConfig), false);
    m_kwinrcConfig->sync();
    reloadKWinConfig();

    // applications-blacklistrc
    writeKeys(u"applications-blacklistrc"_s,
              m_appBlacklistConfig,
              APPLICATIONS_BLACKLIST_DEFAULT_SETTINGS,
              true); // only write entries if they are not already defined in the config
    m_appBlacklistConfig->sync();

    // kdeglobals
    writeKeys(u"kdeglobals"_s, m_kdeglobalsConfig, KDEGLOBALS_DEFAULT_SETTINGS,
              true); // only write entries if they are not already defined in the config
    writeKeys(u"kdeglobals"_s, m_kdeglobalsConfig, KDEGLOBALS_SETTINGS, false);
    m_kdeglobalsConfig->sync();

    // save our changes
    m_mobileConfig->sync();
}

void Settings::writeKeys(const QString &fileName, KSharedConfig::Ptr &config, const QMap<QString, QMap<QString, QVariant>> &settings, bool overwriteOnlyIfEmpty)
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

void Settings::reloadKWinConfig()
{
    // Most KWin settings are already reloaded through KConfig's notify feature.
    // However, effects need to manually be loaded/unloaded in a live KWin session.

    KConfigGroup pluginsGroup{m_kwinrcConfig, QStringLiteral("Plugins")};

    for (const auto &effect : KWIN_EFFECTS) {
        // Read from the config whether the effect is enabled (settings are suffixed with "Enabled", ex. blurEnabled)
        bool status = pluginsGroup.readEntry(effect + u"Enabled"_s, false);
        const QString method = status ? u"loadEffect"_s : u"unloadEffect"_s;

        QDBusMessage message = QDBusMessage::createMethodCall(u"org.kde.KWin"_s, u"/Effects"_s, u"org.kde.kwin.Effects"_s, method);
        message.setArguments({effect});
        QDBusConnection::sessionBus().send(message);
    }

    // Unload KWin scripts that are now disabled.
    for (const auto &script : KWIN_SCRIPTS) {
        // Read from the config whether the effect is enabled (settings are suffixed with "Enabled", ex. blurEnabled)
        bool status = pluginsGroup.readEntry(script + u"Enabled"_s, false);

        if (!status) {
            QDBusMessage message = QDBusMessage::createMethodCall(u"org.kde.KWin"_s, u"/Scripting"_s, u"org.kde.kwin.Scripting"_s, u"unloadScript"_s);
            message.setArguments({script});
            QDBusConnection::sessionBus().send(message);
        }
    }

    // Call "start" to load enabled KWin scripts.
    QDBusMessage message = QDBusMessage::createMethodCall(u"org.kde.KWin"_s, u"/Scripting"_s, u"org.kde.kwin.Scripting"_s, u"start"_s);
    QDBusConnection::sessionBus().send(message);
}
