// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "lockscreendbusclient.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusReply>
#include <QTimer>

LockscreenDBusClient::LockscreenDBusClient(QObject *parent)
    : QObject{parent}
{
    QDBusMessage request = QDBusMessage::createMethodCall(QStringLiteral("org.freedesktop.ScreenSaver"),
                                                          QStringLiteral("/ScreenSaver"),
                                                          QStringLiteral("org.freedesktop.ScreenSaver"),
                                                          QStringLiteral("GetActive"));
    const QDBusReply<bool> response = QDBusConnection::sessionBus().call(request);

    m_lockscreenActive = response.isValid() ? response.value() : false;
    Q_EMIT lockscreenActiveChanged();

    QDBusConnection::sessionBus().connect(QStringLiteral("org.freedesktop.ScreenSaver"),
                                          QStringLiteral("/ScreenSaver"),
                                          QStringLiteral("org.freedesktop.ScreenSaver"),
                                          QStringLiteral("ActiveChanged"),
                                          this,
                                          SLOT(slotLockscreenActiveChanged));
}

LockscreenDBusClient *LockscreenDBusClient::self()
{
    static LockscreenDBusClient *instance = new LockscreenDBusClient;
    return instance;
}

bool LockscreenDBusClient::lockscreenActive() const
{
    return m_lockscreenActive;
}

void LockscreenDBusClient::slotLockscreenActiveChanged(bool active)
{
    if (active != m_lockscreenActive) {
        m_lockscreenActive = active;
        Q_EMIT lockscreenActiveChanged();
    }
}
