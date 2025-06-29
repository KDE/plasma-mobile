/*
 *  SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "kwinsettings.h"

const QString CONFIG_FILE = QStringLiteral("kwinrc");
const QString WAYLAND_CONFIG_GROUP = QStringLiteral("Wayland");

KWinSettings::KWinSettings(QObject *parent)
    : QObject{parent}
    , m_config{KSharedConfig::openConfig(CONFIG_FILE, KConfig::SimpleConfig)}
{
    m_configWatcher = KConfigWatcher::create(m_config);
    connect(m_configWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group, const QByteArrayList &names) -> void {
        Q_UNUSED(names)
        if (group.name() == WAYLAND_CONFIG_GROUP) {
            Q_EMIT doubleTapWakeupChanged();
        }
    });
}

bool KWinSettings::doubleTapWakeup() const
{
    auto group = KConfigGroup{m_config, WAYLAND_CONFIG_GROUP};
    return group.readEntry("DoubleTapWakeup", true);
}

void KWinSettings::setDoubleTapWakeup(bool enabled)
{
    auto group = KConfigGroup{m_config, WAYLAND_CONFIG_GROUP};
    group.writeEntry("DoubleTapWakeup", enabled, KConfigGroup::Notify);
    m_config->sync();
}
