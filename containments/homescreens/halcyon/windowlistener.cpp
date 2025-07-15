// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "windowlistener.h"

WindowListener::WindowListener(QObject *parent)
    : QObject{parent}
{
    // initialize wayland window checking
    KWayland::Client::ConnectionThread *connection = KWayland::Client::ConnectionThread::fromApplication(this);
    if (!connection) {
        return;
    }

    auto *registry = new KWayland::Client::Registry(this);
    registry->create(connection);

    connect(registry, &KWayland::Client::Registry::plasmaWindowManagementAnnounced, this, [this, registry](quint32 name, quint32 version) {
        m_windowManagement = registry->createPlasmaWindowManagement(name, version, this);
        connect(m_windowManagement, &KWayland::Client::PlasmaWindowManagement::windowCreated, this, &WindowListener::windowCreated);
    });

    registry->setup();
    connection->roundtrip();
}

WindowListener *WindowListener::instance()
{
    static WindowListener *listener = new WindowListener();
    return listener;
}

QList<KWayland::Client::PlasmaWindow *> WindowListener::windowsFromStorageId(QString &storageId) const
{
    if (!m_windows.contains(storageId)) {
        return {};
    }
    return m_windows[storageId];
}

void WindowListener::windowCreated(KWayland::Client::PlasmaWindow *window)
{
    QString storageId = window->appId() + QStringLiteral(".desktop");

    // ignore empty windows
    if (storageId == ".desktop" || storageId == "org.kde.plasmashell.desktop") {
        return;
    }

    if (!m_windows.contains(storageId)) {
        m_windows[storageId] = {};
    }
    m_windows[storageId].push_back(window);

    // listen for window close
    connect(window, &KWayland::Client::PlasmaWindow::unmapped, this, [this, storageId]() {
        m_windows.remove(storageId);
        Q_EMIT windowChanged(storageId);
    });

    Q_EMIT windowChanged(storageId);
}
