/***************************************************************************
 *   Copyright (C) 2015 Marco Martin <mart@kde.org>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "taskpanel.h"

#include <QtQml>
#include <QDebug>
#include <QQuickItem>
#include <QQuickWindow>

#include <Plasma/Package>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/plasmawindowmodel.h>
#include <KWayland/Client/plasmashell.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

static const QString s_kwinService = QStringLiteral("org.kde.KWin");

TaskPanel::TaskPanel(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args)
    , m_showingDesktop(false)
    , m_windowManagement(nullptr)
{
    setHasConfigurationInterface(true);
    initWayland();
}

TaskPanel::~TaskPanel()
{
}

void TaskPanel::requestShowingDesktop(bool showingDesktop)
{
    if (!m_windowManagement) {
        return;
    }
    m_windowManagement->setShowingDesktop(showingDesktop);
}

void TaskPanel::initWayland()
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
    connect(registry, &Registry::plasmaWindowManagementAnnounced, this,
        [this, registry] (quint32 name, quint32 version) {
            m_windowManagement = registry->createPlasmaWindowManagement(name, version, this);
            qRegisterMetaType<QVector<int> >("QVector<int>");
            m_windowModel = m_windowManagement->createWindowModel();
            emit windowModelChanged();
            connect(m_windowManagement, &PlasmaWindowManagement::showingDesktopChanged, this,
                [this] (bool showing) {
                    if (showing == m_showingDesktop) {
                        return;
                    }
                    m_showingDesktop = showing;
                    emit showingDesktopChanged(m_showingDesktop);
                }
            );
            connect(m_windowManagement, &PlasmaWindowManagement::activeWindowChanged, this, &TaskPanel::updateActiveWindow);
            updateActiveWindow();

            //if a new window is open, show it, not the desktop
            connect(m_windowModel, &PlasmaWindowModel::rowsInserted, [this] () {
                requestShowingDesktop(false);
            });
        }
    );
    connect(registry, &Registry::plasmaShellAnnounced, this,
        [this, registry] (quint32 name, quint32 version) {
            
            m_shellInterface = registry->createPlasmaShell(name, version, this);

            if (!m_panel) {
                return;
            }
            Surface *s = Surface::fromWindow(m_panel);
            if (!s) {
                return;
            }
            m_shellSurface = m_shellInterface->createSurface(s, this);
        }
    );
    registry->setup();
}

QAbstractItemModel *TaskPanel::windowModel() const
{
    return m_windowModel;
}

QWindow *TaskPanel::panel()
{
    return m_panel;
}

void TaskPanel::setPanel(QWindow *panel)
{
    using namespace KWayland::Client;
    if (panel == m_panel) {
        return;
    }

    m_panel = panel;
    emit panelChanged();

    if (!m_shellSurface) {
        return;
    }
    Surface *s = Surface::fromWindow(panel);
    if (!s) {
        return;
    }
    
    m_shellSurface = m_shellInterface->createSurface(s, this);
}

void TaskPanel::updateActiveWindow()
{
    if (!m_windowManagement) {
        return;
    }
    if (m_activeWindow) {
        disconnect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::closeableChanged, this, &TaskPanel::hasCloseableActiveWindowChanged);
        disconnect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::unmapped,
            this, &TaskPanel::forgetActiveWindow);
    }
    m_activeWindow = m_windowManagement->activeWindow();

    connect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::closeableChanged, this, &TaskPanel::hasCloseableActiveWindowChanged);
    connect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::unmapped,
            this, &TaskPanel::forgetActiveWindow);

    // TODO: connect to closeableChanged, not needed right now as KWin doesn't provide this changeable
    emit hasCloseableActiveWindowChanged();
}

bool TaskPanel::hasCloseableActiveWindow() const
{
    return m_activeWindow && m_activeWindow->isCloseable() && !m_activeWindow->isMinimized();
}

void TaskPanel::forgetActiveWindow()
{
    if (m_activeWindow) {
        disconnect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::closeableChanged, this, &TaskPanel::hasCloseableActiveWindowChanged);
        disconnect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::unmapped,
            this, &TaskPanel::forgetActiveWindow);
    }
    m_activeWindow.clear();
    emit hasCloseableActiveWindowChanged();  
}

void TaskPanel::closeActiveWindow()
{
    if (m_activeWindow) {
        m_activeWindow->requestClose();
    }  
}

void TaskPanel::setTaskGeometry(int row, int x, int y, int width, int height)
{
    using namespace KWayland::Client;
    if (!m_shellSurface) {
        if (!m_shellInterface || !m_panel || !m_panel->isVisible()) {
            return;
        }
        m_surface = Surface::fromWindow(m_panel);
        if (!m_surface) {
            return;
        }
        m_shellSurface = m_shellInterface->createSurface(m_surface, this);
    }

    m_windowModel->setMinimizedGeometry(row, m_surface, QRect(x, y, width, height));
}

K_EXPORT_PLASMA_APPLET_WITH_JSON(taskpanel, TaskPanel, "metadata.json")

#include "taskpanel.moc"
