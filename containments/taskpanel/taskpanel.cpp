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

#include <Plasma/Package>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/plasmawindowmodel.h>
#include <KWayland/Client/registry.h>

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
    registry->setup();
}

QAbstractItemModel *TaskPanel::windowModel() const
{
    return m_windowModel;
}

void TaskPanel::updateActiveWindow()
{
    if (!m_windowManagement) {
        return;
    }
    m_activeWindow = m_windowManagement->activeWindow();
    // TODO: connect to closeableChanged, not needed right now as KWin doesn't provide this changeable
    emit hasCloseableActiveWindowChanged();
}

bool TaskPanel::hasCloseableActiveWindow() const
{
    return m_activeWindow && m_activeWindow->isCloseable();
}

void TaskPanel::closeActiveWindow()
{
    if (m_activeWindow) {
        m_activeWindow->requestClose();
    }
}

K_EXPORT_PLASMA_APPLET_WITH_JSON(taskpanel, TaskPanel, "metadata.json")

#include "taskpanel.moc"
