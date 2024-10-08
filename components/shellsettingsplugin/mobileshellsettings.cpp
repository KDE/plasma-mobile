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
            Q_EMIT navigationPanelEnabledChanged();
            Q_EMIT alwaysShowKeyboardToggleOnNavigationPanelChanged();
            Q_EMIT keyboardButtonEnabledChanged();
            Q_EMIT taskSwitcherPreviewsEnabledChanged();
            Q_EMIT actionDrawerTopLeftModeChanged();
            Q_EMIT actionDrawerTopRightModeChanged();
            Q_EMIT convergenceModeEnabledChanged();
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

    updateNavigationBarsInPlasma();
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

    // update Plasma panels
    updateNavigationBarsInPlasma();
}

void MobileShellSettings::updateNavigationBarsInPlasma()
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

    QString deletePanelsScript = R"(
            let allPanels = panels();
            for (let i = 0; i < allPanels.length; i++) {
                if (allPanels[i].type === "org.kde.plasma.mobile.taskpanel" || allPanels[i].type === "org.kde.panel") {
                    allPanels[i].remove();
                }
            }
        )";

    QString createNavigationPanelScript = R"(
            loadTemplate("org.kde.plasma.mobile.defaultNavigationPanel");
        )";

    QString createDesktopPanelScript = R"(
            if (knownPanelTypes.includes("org.kde.panel")) {
                // Create a panel for each screen
                for (let i = 0; i < screenCount; i++) {
                    loadTemplate("org.kde.plasma.mobile.defaultDesktopPanel");
                }

                let panelsList = panels();
                let curScreen = 0;

                // Set the location and screen that each panel is on
                for (let i = 0; i < panelsList.length; i++) {
                    let panel = panelsList[i];
                    if (panel.type === "org.kde.panel") {
                        panel.location = 'bottom';

                        if (panel.screen !== curScreen) {
                            panel.screen = curScreen;
                        }
                        curScreen++;
                    }
                }
            }
        )";

    // If the desktop panel doesn't get created (ex. Plasma Desktop is not installed), fallback to navbar
    QString checkIfDesktopPanelCreatedScript = R"(
            if (!knownPanelTypes.includes("org.kde.panel")) {
                print("Plasma Desktop is not installed, cannot add desktop panel.");
                loadTemplate("org.kde.plasma.mobile.defaultNavigationPanel");
            }
        )";

    QString str = deletePanelsScript;

    if (convergenceModeEnabled()) {
        str += createDesktopPanelScript;

        if (navigationPanelEnabled()) {
            str += checkIfDesktopPanelCreatedScript;
        }

    } else if (navigationPanelEnabled()) {
        str += createNavigationPanelScript;
    }

    message << str;

    // TODO check for error response
    QDBusConnection::sessionBus().asyncCall(message);
}
