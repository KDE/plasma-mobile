/***************************************************************************
 *   Copyright 2015 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU Library General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "fullscreenpanel.h"

#include <QStandardPaths>

#include <QDebug>
#include <QGuiApplication>

#include <kwindowsystem.h>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmashell.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>
#include <KWayland/Client/shell.h>

FullScreenPanel::FullScreenPanel(QQuickWindow *parent)
    : QQuickWindow(parent)
{
    setFlags(Qt::FramelessWindowHint);
    setWindowState(Qt::WindowFullScreen);
   // connect(this, &FullScreenPanel::activeFocusItemChanged, this, [this]() {qWarning()<<"hide()";});
    connect(this, &QWindow::activeChanged, this, &FullScreenPanel::activeChanged);
    initWayland();
}

FullScreenPanel::~FullScreenPanel()
{
}

void FullScreenPanel::initWayland()
{
    if (!QGuiApplication::platformName().startsWith(QLatin1String("wayland"), Qt::CaseInsensitive)) {
        return;
    }
    using namespace KWayland::Client;
    ConnectionThread *connection = ConnectionThread::fromApplication(this);
    if (!connection) {
        return;
    }
    Registry *registry = new Registry(this);
    registry->create(connection);

    m_surface = Surface::fromWindow(this);
    if (!m_surface) {
        return;
    }
    connect(registry, &Registry::plasmaShellAnnounced, this,
        [this, registry] (quint32 name, quint32 version) {

            m_plasmaShellInterface = registry->createPlasmaShell(name, version, this);

            m_plasmaShellSurface = m_plasmaShellInterface->createSurface(m_surface, this);
            m_plasmaShellSurface->setSkipTaskbar(true);
        }
    );
    /*
    connect(registry, &Registry::shellAnnounced, this,
        [this, registry] (quint32 name, quint32 version) {

            m_shellInterface = registry->createShell(name, version, this);
            if (!m_shellInterface) {
                return;
            }
            //bshah: following code results in error...
            //wl_surface@67: error 0: ShellSurface already created
            //Wayland display got fatal error 71: Protocol error
            //Additionally, errno was set to 71: Protocol error
            m_shellSurface = m_shellInterface->createSurface(m_surface, this);
        }
    );*/
    registry->setup();
    connection->roundtrip();
}

void FullScreenPanel::showEvent(QShowEvent *event)
{
    using namespace KWayland::Client;
    QQuickWindow::showEvent(event);
}

#include "fullscreenpanel.moc"

