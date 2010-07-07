/***************************************************************************
 *   plasmoidprotocol.cpp                                                  *
 *                                                                         *
 *   Copyright (C) 2008 Jason Stubbs <jasonbstubbs@gmail.com>              *
 *   Copyright (C) 2008 Sebastian Kügler <sebas@kde.org>                   *
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

#include "plasmoidtask.h"
#include "plasmoidtaskprotocol.h"

#include <KDebug>

#include <Plasma/Applet>

namespace SystemTray
{

PlasmoidProtocol::PlasmoidProtocol(QObject *parent)
    : Protocol(parent)
{
}


PlasmoidProtocol::~PlasmoidProtocol()
{
}


void PlasmoidProtocol::init()
{
}

void PlasmoidProtocol::forwardConstraintsEvent(Plasma::Constraints constraints, Plasma::Applet *host)
{
    if (m_tasks.contains(host)) {
        QHash<QString, PlasmoidTask*> tasksForHost = m_tasks.value(host);
        foreach (PlasmoidTask *task, tasksForHost) {
            task->forwardConstraintsEvent(constraints);
        }
    }
}

void PlasmoidProtocol::loadFromConfig(Plasma::Applet *parent)
{
    KConfigGroup cg = parent->config();
    QHash<QString, PlasmoidTask*> existingTasks = m_tasks.value(parent);

    if (m_tasks.contains(parent)) {
        m_tasks[parent].clear();
    }

    KConfigGroup appletGroup(&cg, "Applets");
    foreach (const QString &groupName, appletGroup.groupList()) {
        KConfigGroup childGroup(&appletGroup, groupName);
        QString appletName = childGroup.readEntry("plugin", QString());

        if (m_tasks.contains(parent) && m_tasks.value(parent).contains(appletName)) {
            continue;
        }

        if (existingTasks.contains(appletName)) {
            m_tasks[parent].insert(appletName, existingTasks.value(appletName));
            existingTasks.remove(appletName);
            continue;
        }

        addApplet(appletName, groupName.toInt(), parent);

        existingTasks.remove(appletName);
    }

    QHashIterator<QString, PlasmoidTask*> it(existingTasks);
    while (it.hasNext()) {
        it.next();
        Plasma::Applet *applet = qobject_cast<Plasma::Applet *>(it.value()->widget(parent, true));
        if (applet) {
            applet->destroy();
        }
    }
}

void PlasmoidProtocol::addApplet(const QString appletName, const int id, Plasma::Applet *parent)
{
    kDebug() << "Registering task with the manager" << appletName;

    PlasmoidTask *task = new PlasmoidTask(appletName, id, this, parent);

    if (!task->isValid()) {
        // we failed to load our applet *sob*
        delete task;
        return;
    }


    m_tasks[parent].insert(appletName, task);

    connect(task, SIGNAL(taskDeleted(Plasma::Applet *, const QString &)), this, SLOT(cleanupTask(Plasma::Applet *, const QString &)));
    emit taskCreated(task);
}

void PlasmoidProtocol::removeApplet(const QString appletName, Plasma::Applet *parent)
{
    if (!m_tasks.contains(parent) || !m_tasks.value(parent).contains(appletName)) {
        return;
    }

    Plasma::Applet *applet = qobject_cast<Plasma::Applet *>(m_tasks.value(parent).value(appletName)->widget(parent, true));

    if (applet) {
        applet->destroy();
    }
}

void PlasmoidProtocol::cleanupTask(Plasma::Applet *host, const QString &typeId)
{
    kDebug() << "task with typeId" << typeId << "removed";
    if (m_tasks.contains(host)) {
        m_tasks[host].remove(typeId);
        if (m_tasks.value(host).isEmpty()) {
            m_tasks.remove(host);
        }
    }
}

QStringList PlasmoidProtocol::applets(Plasma::Applet *host) const
{
    QStringList list;
    if (!m_tasks.contains(host)) {
        return list;
    }

    QHashIterator<QString, PlasmoidTask *> i(m_tasks.value(host));

    while (i.hasNext()) {
        i.next();
        list << i.key();
    }

    return list;
}

}

#include "plasmoidtaskprotocol.moc"
