// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QList>
#include <QObject>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

class WindowListener : public QObject
{
    Q_OBJECT

public:
    WindowListener(QObject *parent = nullptr);

    static WindowListener *instance();

    QList<KWayland::Client::PlasmaWindow *> windowsFromStorageId(QString &storageId) const;

public Q_SLOTS:
    void windowCreated(KWayland::Client::PlasmaWindow *window);

Q_SIGNALS:
    void windowChanged(QString storageId);

private:
    KWayland::Client::PlasmaWindowManagement *m_windowManagement = nullptr;
    QHash<QString, QList<KWayland::Client::PlasmaWindow *>> m_windows; // <storageId, window>
};
