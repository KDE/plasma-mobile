/*
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "mobileshellsettings.h"

#include <QDebug>

const QString CONFIG_FILE = QStringLiteral("plasmamobilerc");
const QString GENERAL_CONFIG_GROUP = QStringLiteral("General");
const QString QUICKSETTINGS_CONFIG_GROUP = QStringLiteral("QuickSettings");

MobileShellSettings *MobileShellSettings::self()
{
    static MobileShellSettings *singleton = new MobileShellSettings();
    return singleton;
}

MobileShellSettings::MobileShellSettings(QObject *parent)
    : QObject{parent}
    , m_config{KSharedConfig::openConfig(CONFIG_FILE, KConfig::SimpleConfig)}
{
    m_configWatcher = KConfigWatcher::create(m_config);

    connect(m_configWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group, const QByteArrayList &names) -> void {
        if (group.name() == GENERAL_CONFIG_GROUP) {
            Q_EMIT vibrationsEnabledChanged();
            Q_EMIT vibrationIntensityChanged();
            Q_EMIT vibrationDurationChanged();
            Q_EMIT animationsEnabledChanged();
            Q_EMIT navigationPanelEnabledChanged();
            Q_EMIT keyboardButtonEnabledChanged();
            Q_EMIT taskSwitcherPreviewsEnabledChanged();
            Q_EMIT actionDrawerTopLeftModeChanged();
            Q_EMIT actionDrawerTopRightModeChanged();
        } else if (group.name() == QUICKSETTINGS_CONFIG_GROUP) {
            Q_EMIT enabledQuickSettingsChanged();
            Q_EMIT disabledQuickSettingsChanged();
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
    return group.readEntry("vibrationDuration", 100);
}

void MobileShellSettings::setVibrationDuration(int vibrationDuration)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("vibrationDuration", vibrationDuration, KConfigGroup::Notify);
    m_config->sync();
}

qreal MobileShellSettings::vibrationIntensity() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("vibrationIntensity", 0.5);
}

void MobileShellSettings::setVibrationIntensity(qreal vibrationIntensity)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("vibrationIntensity", vibrationIntensity, KConfigGroup::Notify);
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
}

bool MobileShellSettings::taskSwitcherPreviewsEnabled() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("taskSwitcherPreviewsEnabled", true);
}

void MobileShellSettings::setTaskSwitcherPreviewsEnabled(bool taskSwitcherPreviewsEnabled)
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    group.writeEntry("taskSwitcherPreviewsEnabled", taskSwitcherPreviewsEnabled, KConfigGroup::Notify);
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

QList<QString> MobileShellSettings::enabledQuickSettings() const
{
    auto group = KConfigGroup{m_config, QUICKSETTINGS_CONFIG_GROUP};
    // TODO move defaults to file
    // we aren't worried about quicksettings not showing up though, any that are not specified will be automatically added to the end
    return group.readEntry("enabledQuickSettings",
                           QList<QString>{QStringLiteral("org.kde.plasma.quicksetting.wifi"),
                                          QStringLiteral("org.kde.plasma.quicksetting.mobiledata"),
                                          QStringLiteral("org.kde.plasma.quicksetting.bluetooth"),
                                          QStringLiteral("org.kde.plasma.quicksetting.flashlight"),
                                          QStringLiteral("org.kde.plasma.quicksetting.screenrotation"),
                                          QStringLiteral("org.kde.plasma.quicksetting.settingsapp"),
                                          QStringLiteral("org.kde.plasma.quicksetting.airplanemode"),
                                          QStringLiteral("org.kde.plasma.quicksetting.audio"),
                                          QStringLiteral("org.kde.plasma.quicksetting.battery"),
                                          QStringLiteral("org.kde.plasma.quicksetting.record"),
                                          QStringLiteral("org.kde.plasma.quicksetting.nightcolor"),
                                          QStringLiteral("org.kde.plasma.quicksetting.screenshot"),
                                          QStringLiteral("org.kde.plasma.quicksetting.powermenu"),
                                          QStringLiteral("org.kde.plasma.quicksetting.donotdisturb"),
                                          QStringLiteral("org.kde.plasma.quicksetting.caffeine"),
                                          QStringLiteral("org.kde.plasma.quicksetting.keyboardtoggle")});
}

void MobileShellSettings::setEnabledQuickSettings(QList<QString> &list)
{
    auto group = KConfigGroup{m_config, QUICKSETTINGS_CONFIG_GROUP};
    group.writeEntry("enabledQuickSettings", list, KConfigGroup::Notify);
    m_config->sync();
}

QList<QString> MobileShellSettings::disabledQuickSettings() const
{
    auto group = KConfigGroup{m_config, QUICKSETTINGS_CONFIG_GROUP};
    return group.readEntry("disabledQuickSettings", QList<QString>{});
}

void MobileShellSettings::setDisabledQuickSettings(QList<QString> &list)
{
    auto group = KConfigGroup{m_config, QUICKSETTINGS_CONFIG_GROUP};
    group.writeEntry("disabledQuickSettings", list, KConfigGroup::Notify);
    m_config->sync();
}
