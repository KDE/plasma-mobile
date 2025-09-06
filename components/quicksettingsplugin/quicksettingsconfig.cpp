/*
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "quicksettingsconfig.h"

#include <QDebug>

const QString CONFIG_FILE = QStringLiteral("plasmamobilerc");
const QString QUICKSETTINGS_CONFIG_GROUP = QStringLiteral("QuickSettings");

QuickSettingsConfig::QuickSettingsConfig(QObject *parent)
    : QObject{parent}
    , m_config{KSharedConfig::openConfig(CONFIG_FILE, KConfig::SimpleConfig)}
{
    m_configWatcher = KConfigWatcher::create(m_config);

    connect(m_configWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group) -> void {
        if (group.name() == QUICKSETTINGS_CONFIG_GROUP) {
            Q_EMIT enabledQuickSettingsChanged();
            Q_EMIT disabledQuickSettingsChanged();
        }
    });
}

QList<QString> QuickSettingsConfig::enabledQuickSettings() const
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
                                          QStringLiteral("org.kde.plasma.quicksetting.keyboardtoggle"),
                                          QStringLiteral("org.kde.plasma.quicksetting.hotspot")});
}

void QuickSettingsConfig::setEnabledQuickSettings(QList<QString> &list)
{
    auto group = KConfigGroup{m_config, QUICKSETTINGS_CONFIG_GROUP};
    group.writeEntry("enabledQuickSettings", list, KConfigGroup::Notify);
    m_config->sync();
}

QList<QString> QuickSettingsConfig::disabledQuickSettings() const
{
    auto group = KConfigGroup{m_config, QUICKSETTINGS_CONFIG_GROUP};
    return group.readEntry("disabledQuickSettings", QList<QString>{
        QStringLiteral("org.kde.plasma.quicksetting.terminal"),
    });
}

void QuickSettingsConfig::setDisabledQuickSettings(QList<QString> &list)
{
    auto group = KConfigGroup{m_config, QUICKSETTINGS_CONFIG_GROUP};
    group.writeEntry("disabledQuickSettings", list, KConfigGroup::Notify);
    m_config->sync();
}
