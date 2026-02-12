/*
 *  SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "kwinsettings.h"

const QString CONFIG_FILE = QStringLiteral("kwinrc");
const QString OVERLAY_CONFIG_FILE = QStringLiteral("plasma-mobile/kwinrc");
const QString WAYLAND_CONFIG_GROUP = QStringLiteral("Wayland");
const QString SCREEN_EDGES_CONFIG_GROUP = QStringLiteral("ScreenEdges");

KWinSettings::KWinSettings(QObject *parent)
    : QObject{parent}
    , m_config{KSharedConfig::openConfig(CONFIG_FILE)}
    , m_overlayConfig{KSharedConfig::openConfig(OVERLAY_CONFIG_FILE)}
{
    m_configWatcher = KConfigWatcher::create(m_config);
    connect(m_configWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group, const QByteArrayList &names) -> void {
        Q_UNUSED(names)
        if (group.name() == WAYLAND_CONFIG_GROUP) {
            Q_EMIT doubleTapWakeupChanged();
        } else if (group.name() == SCREEN_EDGES_CONFIG_GROUP) {
            Q_EMIT screenEdgeTouchTargetChanged();
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
    if (enabled != doubleTapWakeup()) {
        auto group = KConfigGroup{m_config, WAYLAND_CONFIG_GROUP};
        group.writeEntry("DoubleTapWakeup", enabled, KConfigGroup::Notify);
        m_config->sync();
    }
}

int KWinSettings::screenEdgeTouchTarget() const
{
    auto group = KConfigGroup{m_overlayConfig, SCREEN_EDGES_CONFIG_GROUP};
    return group.readEntry("TouchTarget", 0);
}

void KWinSettings::setScreenEdgeTouchTarget(int target)
{
    // Use m_overlayConfig instead of m_config so we don't affect other shells
    if (target != screenEdgeTouchTarget()) {
        auto group = KConfigGroup{m_overlayConfig, SCREEN_EDGES_CONFIG_GROUP};
        group.writeEntry("TouchTarget", target, KConfigGroup::Notify);
        m_overlayConfig->sync();
    }
}
