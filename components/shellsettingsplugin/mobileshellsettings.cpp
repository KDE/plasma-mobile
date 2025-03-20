/*
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "mobileshellsettings.h"

#include <KIO/CommandLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KPluginFactory>
#include <KRuntimePlatform>

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusPendingCall>
#include <QDebug>

const QString CONFIG_FILE = QStringLiteral("plasmamobilerc");
const QString GENERAL_CONFIG_GROUP = QStringLiteral("General");
const QString LOCKSCREEN_CONFIG_GROUP = QStringLiteral("Lockscreen");

MobileShellSettings::MobileShellSettings(QObject *parent)
    : QObject{parent}
    , m_config{KSharedConfig::openConfig(CONFIG_FILE, KConfig::SimpleConfig)}
{
    m_configWatcher = KConfigWatcher::create(m_config);
    connect(m_configWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group, const QByteArrayList &names) -> void {
        Q_UNUSED(names)
        if (group.name() == GENERAL_CONFIG_GROUP) {
            Q_EMIT vibrationsEnabledChanged();
            Q_EMIT vibrationDurationChanged();
            Q_EMIT animationsEnabledChanged();
            Q_EMIT dateInStatusBarChanged();
            Q_EMIT statusBarScaleFactorChanged();
            Q_EMIT showBatteryPercentageChanged();
            Q_EMIT navigationPanelEnabledChanged();
            Q_EMIT alwaysShowKeyboardToggleOnNavigationPanelChanged();
            Q_EMIT keyboardButtonEnabledChanged();
            Q_EMIT taskSwitcherPreviewsEnabledChanged();
            Q_EMIT actionDrawerTopLeftModeChanged();
            Q_EMIT actionDrawerTopRightModeChanged();
            Q_EMIT convergenceModeEnabledChanged();
            Q_EMIT allowLogoutChanged();
        }
        if (group.name() == LOCKSCREEN_CONFIG_GROUP) {
            Q_EMIT lockscreenLeftButtonActionChanged();
            Q_EMIT lockscreenRightButtonActionChanged();
        }
    });
}

bool MobileShellSettings::vibrationsEnabled() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("vibrationsEnabled", true);
}

void MobileShellSettings::setVibrationsEnabled(bool vibrationsEnabled)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("vibrationsEnabled", vibrationsEnabled, KConfigGroup::Notify);
    m_config->sync();
}

int MobileShellSettings::vibrationDuration() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("vibrationDuration", 10);
}

void MobileShellSettings::setVibrationDuration(int vibrationDuration)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("vibrationDuration", vibrationDuration, KConfigGroup::Notify);
    m_config->sync();
}

bool MobileShellSettings::animationsEnabled() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("animationsEnabled", true);
}

void MobileShellSettings::setAnimationsEnabled(bool animationsEnabled)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("animationsEnabled", animationsEnabled, KConfigGroup::Notify);
    m_config->sync();
}

bool MobileShellSettings::dateInStatusBar() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("dateInStatusBar", false);
}

void MobileShellSettings::setDateInStatusBar(bool dateInStatusBar)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("dateInStatusBar", dateInStatusBar, KConfigGroup::Notify);
    m_config->sync();
}

float MobileShellSettings::statusBarScaleFactor() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("statusBarScaleFactor", 1.0);
}

void MobileShellSettings::setStatusBarScaleFactor(float statusBarScaleFactor)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("statusBarScaleFactor", statusBarScaleFactor, KConfigGroup::Notify);
    m_config->sync();
}

bool MobileShellSettings::showBatteryPercentage() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("showBatteryPercentage", true);
}

void MobileShellSettings::setShowBatteryPercentage(bool showBatteryPercentage)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("showBatteryPercentage", showBatteryPercentage, KConfigGroup::Notify);
    m_config->sync();
}

bool MobileShellSettings::navigationPanelEnabled() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("navigationPanelEnabled", true);
}

void MobileShellSettings::setNavigationPanelEnabled(bool navigationPanelEnabled)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("navigationPanelEnabled", navigationPanelEnabled, KConfigGroup::Notify);
    m_config->sync();

    updateNavigationBarsInPlasma(navigationPanelEnabled);
}

bool MobileShellSettings::alwaysShowKeyboardToggleOnNavigationPanel() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("alwaysShowKeyboardToggleOnNavigationPanel", false);
}

void MobileShellSettings::setAlwaysShowKeyboardToggleOnNavigationPanel(bool alwaysShowKeyboardToggleOnNavigationPanel)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("alwaysShowKeyboardToggleOnNavigationPanel", alwaysShowKeyboardToggleOnNavigationPanel, KConfigGroup::Notify);
    m_config->sync();
}

MobileShellSettings::ActionDrawerMode MobileShellSettings::actionDrawerTopLeftMode() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return (ActionDrawerMode)group.readEntry("actionDrawerTopLeftMode", (int)ActionDrawerMode::Pinned);
}

void MobileShellSettings::setActionDrawerTopLeftMode(ActionDrawerMode actionDrawerMode)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("actionDrawerTopLeftMode", (int)actionDrawerMode, KConfigGroup::Notify);
    m_config->sync();
}

MobileShellSettings::ActionDrawerMode MobileShellSettings::actionDrawerTopRightMode() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return (ActionDrawerMode)group.readEntry("actionDrawerTopRightMode", (int)ActionDrawerMode::Expanded);
}

void MobileShellSettings::setActionDrawerTopRightMode(ActionDrawerMode actionDrawerMode)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("actionDrawerTopRightMode", (int)actionDrawerMode, KConfigGroup::Notify);
    m_config->sync();
}

bool MobileShellSettings::convergenceModeEnabled() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("convergenceModeEnabled", false);
}

void MobileShellSettings::setConvergenceModeEnabled(bool enabled)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("convergenceModeEnabled", enabled, KConfigGroup::Notify);
    m_config->sync();

    // update environment settings
    auto *job = new KIO::CommandLauncherJob(QStringLiteral("plasma-mobile-envmanager --apply-settings"), {});
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoErrorHandlingEnabled));
    job->setDesktopName(QStringLiteral("org.kde.plasma-mobile-envmanager"));
    job->start();
}

void MobileShellSettings::updateNavigationBarsInPlasma(bool navigationPanelEnabled)
{
    // Do not update panels when not in Plasma Mobile
    bool isMobilePlatform = KRuntimePlatform::runtimePlatform().contains("phone");
    if (!isMobilePlatform) {
        return;
    }

    auto message = QDBusMessage::createMethodCall(QLatin1String("org.kde.plasmashell"),
                                                  QLatin1String("/PlasmaShell"),
                                                  QLatin1String("org.kde.PlasmaShell"),
                                                  QLatin1String("evaluateScript"));

    if (navigationPanelEnabled) {
        QString createNavigationPanelScript = R"(
            loadTemplate("org.kde.plasma.mobile.defaultNavigationPanel");
        )";

        message << createNavigationPanelScript;

    } else {
        QString deleteNavigationPanelScript = R"(
            let allPanels = panels();
            for (var i = 0; i < allPanels.length; i++) {
                if (allPanels[i].type === "org.kde.plasma.mobile.taskpanel") {
                    allPanels[i].remove();
                }
            }
        )";

        message << deleteNavigationPanelScript;
    }

    // TODO check for error response
    QDBusConnection::sessionBus().asyncCall(message);
}

bool MobileShellSettings::allowLogout() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("allowLogout", true);
}

MobileShellSettings::LockscreenButtonAction MobileShellSettings::lockscreenLeftButtonAction() const
{
    auto group = KConfigGroup{m_config, LOCKSCREEN_CONFIG_GROUP};
    return (LockscreenButtonAction)group.readEntry("lockscreenLeftButtonAction", (int)LockscreenButtonAction::None);
}

void MobileShellSettings::setLockscreenLeftButtonAction(const LockscreenButtonAction action)
{
    auto group = KConfigGroup{m_config, LOCKSCREEN_CONFIG_GROUP};
    group.writeEntry("lockscreenLeftButtonAction", (int)action, KConfigGroup::Notify);
    m_config->sync();
}

MobileShellSettings::LockscreenButtonAction MobileShellSettings::lockscreenRightButtonAction() const
{
    auto group = KConfigGroup{m_config, LOCKSCREEN_CONFIG_GROUP};
    return (LockscreenButtonAction)group.readEntry("lockscreenRightButtonAction", (int)LockscreenButtonAction::None);
}

void MobileShellSettings::setLockscreenRightButtonAction(const LockscreenButtonAction action)
{
    auto group = KConfigGroup{m_config, LOCKSCREEN_CONFIG_GROUP};
    group.writeEntry("lockscreenRightButtonAction", (int)action, KConfigGroup::Notify);
    m_config->sync();
}
