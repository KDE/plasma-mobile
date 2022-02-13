/*
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "mobileshellsettings.h"

const QString CONFIG_FILE = QStringLiteral("plasmamobilerc");
const QString GENERAL_CONFIG_GROUP = QStringLiteral("General");

MobileShellSettings *MobileShellSettings::self()
{
    static MobileShellSettings *singleton = new MobileShellSettings();
    return singleton;
}

MobileShellSettings::MobileShellSettings(QObject *parent)
    : QObject{parent}
{
    m_config = KSharedConfig::openConfig(CONFIG_FILE, KConfig::SimpleConfig);
    m_configWatcher = KConfigWatcher::create(m_config);

    connect(m_configWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group, const QByteArrayList &names) -> void {
        if (group.name() == GENERAL_CONFIG_GROUP) {
            Q_EMIT navigationPanelEnabledChanged();
        }
    });
}

bool MobileShellSettings::navigationPanelEnabled() const
{
    auto group = KConfigGroup{m_config, GENERAL_CONFIG_GROUP};
    return group.readEntry("navigationPanelEnabled", true);
}
