/***************************************************************************
 *   manager.cpp                                                           *
 *                                                                         *
 *   Copyright (C) 2008 Jason Stubbs <jasonbstubbs@gmail.com>              *
 *   Copyright (C) 2010 Marco Martin <notmart@gmail.com>                   *
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

#include "manager.h"

#include <KGlobal>

#include <plasma/applet.h>

#include "protocol.h"
#include "task.h"

//#include "../protocols/fdo/fdoprotocol.h"
#include "../protocols/plasmoid/plasmoidtaskprotocol.h"
#include "../protocols/dbussystemtray/dbussystemtrayprotocol.h"

#include <QTimer>

namespace SystemTray
{

class Manager::Private
{
public:
    Private(Manager *manager)
        : q(manager),
          plasmoidProtocol(0)
    {
    }

    void setupProtocol(Protocol *protocol);

    Manager *q;
    QList<Task *> tasks;
    PlasmoidProtocol *plasmoidProtocol;
};


Manager::Manager()
    : d(new Private(this))
{
    d->plasmoidProtocol = new PlasmoidProtocol(this);
    d->setupProtocol(d->plasmoidProtocol);
    //d->setupProtocol(new SystemTray::FdoProtocol(this));
    d->setupProtocol(new SystemTray::DBusSystemTrayProtocol(this));
}

Manager::~Manager()
{
    delete d;
}


QList<Task*> Manager::tasks() const
{
    return d->tasks;
}

void Manager::addTask(Task *task)
{
    connect(task, SIGNAL(destroyed(SystemTray::Task*)), this, SLOT(removeTask(SystemTray::Task*)));
    connect(task, SIGNAL(changed(SystemTray::Task*)), this, SIGNAL(taskChanged(SystemTray::Task*)));

    kDebug() << task->name() << "(" << task->typeId() << ")";

    d->tasks.append(task);
    emit taskAdded(task);
}


void Manager::removeTask(Task *task)
{
    d->tasks.removeAll(task);
    disconnect(task, 0, this, 0);
    emit taskRemoved(task);
}

void Manager::forwardConstraintsEvent(Plasma::Constraints constraints, Plasma::Applet *host)
{
    d->plasmoidProtocol->forwardConstraintsEvent(constraints, host);
}

void Manager::loadApplets(Plasma::Applet *parent)
{
    d->plasmoidProtocol->loadFromConfig(parent);
}

void Manager::addApplet(const QString appletName, Plasma::Applet *parent)
{
    d->plasmoidProtocol->addApplet(appletName, 0, parent);
}

void Manager::removeApplet(const QString appletName, Plasma::Applet *parent)
{
    d->plasmoidProtocol->removeApplet(appletName, parent);
}

QStringList Manager::applets(Plasma::Applet *parent) const
{
    return d->plasmoidProtocol->applets(parent);
}


void Manager::Private::setupProtocol(Protocol *protocol)
{
    connect(protocol, SIGNAL(taskCreated(SystemTray::Task*)), q, SLOT(addTask(SystemTray::Task*)));
    protocol->init();
}

}


#include "manager.moc"
