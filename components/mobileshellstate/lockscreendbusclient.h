// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QDBusError>
#include <QDBusServiceWatcher>
#include <QObject>
#include <QString>
#include <qqmlregistration.h>

class LockscreenDBusClient : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(bool lockscreenActive READ lockscreenActive NOTIFY lockscreenActiveChanged);

public:
    explicit LockscreenDBusClient(QObject *parent = nullptr);

    bool lockscreenActive() const;
    Q_INVOKABLE void lockScreen();

Q_SIGNALS:
    void lockscreenActiveChanged();
    void lockscreenUnlocked();
    void lockscreenLocked();

public Q_SLOTS:
    void slotLockscreenActiveChanged(bool active);
    void dbusError(QDBusError error);

private:
    bool m_lockscreenActive = false;
    bool m_firstPropertySet = false;
};
