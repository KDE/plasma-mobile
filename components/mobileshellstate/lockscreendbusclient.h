// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QDBusServiceWatcher>
#include <QObject>
#include <QString>

class LockscreenDBusClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool lockscreenActive READ lockscreenActive NOTIFY lockscreenActiveChanged);

public:
    explicit LockscreenDBusClient(QObject *parent = nullptr);
    static LockscreenDBusClient *self();

    bool lockscreenActive() const;

Q_SIGNALS:
    void lockscreenActiveChanged();

public Q_SLOTS:
    void slotLockscreenActiveChanged(bool active);

private:
    bool m_lockscreenActive;
};
