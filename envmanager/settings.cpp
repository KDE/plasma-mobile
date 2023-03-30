// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "settings.h"
#include "config.h"
#include "utils.h"

#include <KPackage/PackageLoader>
#include <KRuntimePlatform>

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDebug>
#include <QProcess>

const QString CONFIG_FILE = QStringLiteral("plasmamobilerc");
const QString INITIAL_START_CONFIG_GROUP = QStringLiteral("InitialStart");
const QString SAVED_CONFIG_GROUP = QStringLiteral("SavedConfig");

const QString MOBILE_LOOK_AND_FEEL = QStringLiteral("org.kde.breeze.mobile");
const QString LOOK_AND_FEEL_KEY = QStringLiteral("LookAndFeelPackage");

Settings::Settings(QObject *parent)
    : QObject{parent}
    , m_isMobilePlatform{KRuntimePlatform::runtimePlatform().contains(QStringLiteral("phone"))}
    , m_mobileConfig{KSharedConfig::openConfig(CONFIG_FILE, KConfig::SimpleConfig)}
    , m_kwinrcConfig{KSharedConfig::openConfig(QStringLiteral("kwinrc"), KConfig::SimpleConfig)}
    , m_appBlacklistConfig{KSharedConfig::openConfig(QStringLiteral("applications-blacklistrc"), KConfig::SimpleConfig)}
    , m_kdeglobalsConfig{KSharedConfig::openConfig(QStringLiteral("kdeglobals"), KConfig::SimpleConfig)}
    , m_configWatcher{KConfigWatcher::create(m_mobileConfig)}
{
}

Settings *Settings::self()
{
    static Settings *settings = new Settings;
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
    // check look and feel
    QString lnf = loadSavedConfigSetting(m_kdeglobalsConfig, QStringLiteral("kdeglobals"), QStringLiteral("KDE"), LOOK_AND_FEEL_KEY, false);
    QProcess::execute("plasma-apply-lookandfeel", {"-a", lnf});

    // kwinrc
    loadKeys(QStringLiteral("kwinrc"), m_kwinrcConfig, getKwinrcSettings(m_mobileConfig));
    m_kwinrcConfig->sync();
    reloadKWinConfig();

    // applications-blacklistrc
    loadKeys(QStringLiteral("applications-blacklistrc"), m_appBlacklistConfig, APPLICATIONS_BLACKLIST_SETTINGS);
    m_appBlacklistConfig->sync();

    // kdeglobals
    loadKeys(QStringLiteral("kdeglobals"), m_kdeglobalsConfig, KDEGLOBALS_SETTINGS);
    m_kdeglobalsConfig->sync();

    // save our changes
    m_mobileConfig->sync();
}

void Settings::applyMobileConfiguration()
{
    // check look and feel
    KPackage::Package package = KPackage::PackageLoader::self()->loadPackage(QStringLiteral("Plasma/LookAndFeel"));

    if (package.path() != MOBILE_LOOK_AND_FEEL) {
        // save it to be loaded when back on desktop
        saveConfigSetting(QStringLiteral("kdeglobals"), QStringLiteral("KDE"), LOOK_AND_FEEL_KEY, package.path());

        // ensure correct look and feel is applied
        QProcess::execute("plasma-apply-lookandfeel", {"-a", MOBILE_LOOK_AND_FEEL});
    }

    // kwinrc
    writeKeys(QStringLiteral("kwinrc"), m_kwinrcConfig, getKwinrcSettings(m_mobileConfig), false);
    m_kwinrcConfig->sync();
    reloadKWinConfig();

    // applications-blacklistrc
    // NOTE: we only write entries if they are not already defined in the config
    writeKeys(QStringLiteral("applications-blacklistrc"), m_appBlacklistConfig, APPLICATIONS_BLACKLIST_SETTINGS, true);
    m_appBlacklistConfig->sync();

    // kdeglobals
    // NOTE: we only write entries if they are not already defined in the config
    writeKeys(QStringLiteral("kdeglobals"), m_kdeglobalsConfig, KDEGLOBALS_SETTINGS, true);
    m_kdeglobalsConfig->sync();

    // save our changes
    m_mobileConfig->sync();
}

void Settings::writeKeys(const QString &fileName, KSharedConfig::Ptr &config, const QMap<QString, QMap<QString, QVariant>> &settings, bool overwriteOnlyIfEmpty)
{
    for (auto groupName : settings.keys()) {
        auto group = KConfigGroup{config, groupName};

        for (auto key : settings[groupName].keys()) {
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
    for (auto groupName : settings.keys()) {
        auto group = KConfigGroup{config, groupName};

        for (auto key : settings[groupName].keys()) {
            loadSavedConfigSetting(config, fileName, groupName, key);
        }
    }
}

// NOTE: this only saves a value if it hasn't already been saved
void Settings::saveConfigSetting(const QString &fileName, const QString &group, const QString &key, const QVariant value)
{
    auto savedGroup = KConfigGroup{m_mobileConfig, SAVED_CONFIG_GROUP};
    auto fileGroup = KConfigGroup{&savedGroup, fileName};
    auto keyGroup = KConfigGroup{&fileGroup, group};

    if (!keyGroup.hasKey(key)) {
        qCDebug(LOGGING_CATEGORY) << "In" << fileName << "set" << key << "to" << value;
        keyGroup.writeEntry(key, value);
    }
}

// NOTE: this deletes the stored value from the config after loading
const QString Settings::loadSavedConfigSetting(KSharedConfig::Ptr &config, const QString &fileName, const QString &group, const QString &key, bool write)
{
    const auto savedGroup = KConfigGroup{m_mobileConfig, SAVED_CONFIG_GROUP};
    const auto fileGroup = KConfigGroup{&savedGroup, fileName};
    auto keyGroup = KConfigGroup{&fileGroup, group};

    if (!keyGroup.hasKey(key)) {
        return {};
    }

    const auto value = keyGroup.readEntry(key);

    // write to real config
    auto configGroup = KConfigGroup{config, group};

    if ((!configGroup.hasKey(key) || configGroup.readEntry(key) != value) && write) {
        qCDebug(LOGGING_CATEGORY) << "In" << fileName << "loading saved value of" << key << "which is" << value;

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
    QDBusMessage message = QDBusMessage::createSignal(QStringLiteral("/KWin"), QStringLiteral("org.kde.KWin"), QStringLiteral("reloadConfig"));
    QDBusConnection::sessionBus().send(message);
}
