/***************************************************************************
 *   dbussystemtrayprotocol.cpp                                            *
 *                                                                         *
 *   Copyright (C) 2009 Marco Martin <notmart@gmail.com>                   *
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

#include "dbussystemtraytask.h"
#include "dbussystemtrayprotocol.h"

#include <Plasma/DataEngineManager>


namespace SystemTray
{

DBusSystemTrayProtocol::DBusSystemTrayProtocol(QObject *parent)
    : Protocol(parent),
      m_dataEngine(Plasma::DataEngineManager::self()->loadEngine("statusnotifieritem")),
      m_tasks()
{
}

DBusSystemTrayProtocol::~DBusSystemTrayProtocol()
{
    Plasma::DataEngineManager::self()->unloadEngine("statusnotifieritem");
}

void DBusSystemTrayProtocol::init()
{
    if (m_dataEngine->isValid()) {
        initRegisteredServices();
        connect(m_dataEngine, SIGNAL(sourceAdded(const QString&)),
                this, SLOT(newTask(const QString&)));
        connect(m_dataEngine, SIGNAL(sourceRemoved(const QString&)),
                this, SLOT(cleanupTask(const QString&)));
    }
}

void DBusSystemTrayProtocol::newTask(const QString &service)
{
    if (m_tasks.contains(service)) {
        return;
    }

    DBusSystemTrayTask *task = new DBusSystemTrayTask(service, m_dataEngine->serviceForSource(service), this);

    m_dataEngine->connectSource(service, task);

    if (!task->isValid()) {
        // we failed to load our task, *sob*
        delete task;
        return;
    }

    m_tasks[service] = task;
//    connect(task, SIGNAL(taskDeleted(QString)), this, SLOT(cleanupTask(QString)));
    emit taskCreated(task);
}

void DBusSystemTrayProtocol::cleanupTask(const QString &service)
{
    DBusSystemTrayTask *task = m_tasks.value(service);

    if (task) {
        m_dataEngine->disconnectSource(service, task);
        m_tasks.remove(service);
        emit task->destroyed(task);
        task->deleteLater();
    }
}

void DBusSystemTrayProtocol::initRegisteredServices()
{
    if (m_dataEngine->isValid()) {
        QStringList registeredItems = m_dataEngine->sources();
        foreach (const QString &service, registeredItems) {
            newTask(service);
        }
    }
}

}

#include "dbussystemtrayprotocol.moc"
