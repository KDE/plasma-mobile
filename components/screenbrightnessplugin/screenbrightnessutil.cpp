// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "screenbrightnessutil.h"

#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>

ScreenBrightnessUtil::ScreenBrightnessUtil(QObject *parent)
    : QObject{parent}
{
    m_brightnessInterface =
        new org::kde::Solid::PowerManagement::Actions::BrightnessControl(QStringLiteral("org.kde.Solid.PowerManagement"),
                                                                         QStringLiteral("/org/kde/Solid/PowerManagement/Actions/BrightnessControl"),
                                                                         QDBusConnection::sessionBus(),
                                                                         this);

    fetchBrightness();
    fetchMaxBrightness();

    connect(m_brightnessInterface,
            &org::kde::Solid::PowerManagement::Actions::BrightnessControl::brightnessChanged,
            this,
            &ScreenBrightnessUtil::fetchBrightness);
    connect(m_brightnessInterface,
            &org::kde::Solid::PowerManagement::Actions::BrightnessControl::brightnessMaxChanged,
            this,
            &ScreenBrightnessUtil::fetchMaxBrightness);

    // watch for brightness interface
    m_brightnessInterfaceWatcher = new QDBusServiceWatcher(QStringLiteral("org.kde.Solid.PowerManagement.Actions.BrightnessControl"),
                                                           QDBusConnection::sessionBus(),
                                                           QDBusServiceWatcher::WatchForOwnerChange,
                                                           this);

    connect(m_brightnessInterfaceWatcher, &QDBusServiceWatcher::serviceRegistered, this, [this]() -> void {
        Q_EMIT brightnessAvailableChanged();
    });

    connect(m_brightnessInterfaceWatcher, &QDBusServiceWatcher::serviceUnregistered, this, [this]() -> void {
        Q_EMIT brightnessAvailableChanged();
    });
}

int ScreenBrightnessUtil::brightness() const
{
    return m_brightness;
}

void ScreenBrightnessUtil::setBrightness(int brightness)
{
    m_brightnessInterface->setBrightness(brightness);
}

int ScreenBrightnessUtil::maxBrightness() const
{
    return m_maxBrightness;
}

bool ScreenBrightnessUtil::brightnessAvailable() const
{
    return m_brightnessInterface->isValid();
}

void ScreenBrightnessUtil::fetchBrightness()
{
    QDBusPendingReply<int> reply = m_brightnessInterface->brightness();
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(reply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](QDBusPendingCallWatcher *watcher) {
        QDBusPendingReply<int> reply = *watcher;
        if (reply.isError()) {
            qWarning() << "Getting brightness failed:" << reply.error().name() << reply.error().message();
        } else if (m_brightness != reply.value()) {
            m_brightness = reply.value();
            Q_EMIT brightnessChanged();
        }
        watcher->deleteLater();
    });
}

void ScreenBrightnessUtil::fetchMaxBrightness()
{
    QDBusPendingReply<int> reply = m_brightnessInterface->brightnessMax();
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(reply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](QDBusPendingCallWatcher *watcher) {
        QDBusPendingReply<int> reply = *watcher;
        if (reply.isError()) {
            qWarning() << "Getting max brightness failed:" << reply.error().name() << reply.error().message();
        } else if (m_maxBrightness != reply.value()) {
            m_maxBrightness = reply.value();
            Q_EMIT maxBrightnessChanged();
        }
        watcher->deleteLater();
    });
}
