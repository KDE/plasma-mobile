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
        connect(m_windowManagement, &KWayland::Client::PlasmaWindowManagement::windowCreated, this, &WindowListener::onWindowCreated);
        connect(m_windowManagement, &KWayland::Client::PlasmaWindowManagement::activeWindowChanged, this, [this]() {
            Q_EMIT activeWindowChanged(m_windowManagement->activeWindow());
        });
    });

    registry->setup();
    connection->roundtrip();
}

WindowListener *WindowListener::instance()
{
    static WindowListener *listener = new WindowListener();
    return listener;
}

void WindowListener::onWindowCreated(KWayland::Client::PlasmaWindow *window)
{
    QString storageId = window->appId();

    // Ignore empty windows
    if (storageId == "") {
        return;
    }

    // Special handling for plasmashell windows, don't track them
    if (storageId == "org.kde.plasmashell") {
        Q_EMIT plasmaWindowCreated(window);
        return;
    }

    // listen for window close
    connect(window, &KWayland::Client::PlasmaWindow::unmapped, this, [this, storageId]() {
        Q_EMIT windowRemoved(storageId);
    });

    Q_EMIT windowCreated(window);
}
