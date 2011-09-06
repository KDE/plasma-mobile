/*
 *   Copyright (C) 2011 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */


#include "DBusSensor.h"

#include <QDBusServiceWatcher>
#include <QDBusInterface>
#include <QDBusPendingCall>
#include <QDBusConnection>
#include <QDBusConnectionInterface>

#include <KDebug>

/**
 *
 */
class DBusSensor::Private {
public:
    Private()
        : conn(QDBusConnection::sessionBus()) {
        conniface = conn.interface();
        servicePrefix = QString();
        watcher = NULL;
    }

    QDBusServiceWatcher * watcher;
    QDBusConnection conn;
    QDBusConnectionInterface * conniface;
    QString servicePrefix;
};

DBusSensor::DBusSensor()
    : d(new Private())
{
}

DBusSensor::~DBusSensor()
{
    kDebug() << "Deleting me";
    delete d;
}

void DBusSensor::watchFor(const QString & service)
{
    if (service.endsWith("*")) {
        kDebug() << "Watching for pattern" << service;

        d->servicePrefix = service;
        d->servicePrefix.remove('*');

        connect(d->conniface, SIGNAL(serviceRegistered(QString)),
                this,         SLOT(__serviceRegistered(QString)));
        connect(d->conniface, SIGNAL(serviceUnregistered(QString)),
                this,         SLOT(__serviceUnregistered(QString)));

        foreach (const QString & name, d->conniface->registeredServiceNames().value()) {
            if (name.startsWith(d->servicePrefix)) {
                emit serviceRegistered(name);
            }
        }

    } else {
        kDebug() << "Watching for exact" << service;

        d->servicePrefix = QString();

        d->watcher = new QDBusServiceWatcher(
                service,
                d->conn,
                QDBusServiceWatcher::WatchForRegistration | QDBusServiceWatcher::WatchForUnregistration | QDBusServiceWatcher::WatchForOwnerChange,
                this);

        connect(d->watcher, SIGNAL(serviceOwnerChanged(QString, QString, QString)),
                this,       SIGNAL(serviceOwnerChanged(QString, QString, QString)));
        connect(d->watcher, SIGNAL(serviceRegistered(QString)),
                this,       SIGNAL(serviceRegistered(QString)));
        connect(d->watcher, SIGNAL(serviceUnregistered(QString)),
                this,       SIGNAL(serviceUnregistered(QString)));

        if (d->conniface->isServiceRegistered(service)) {
            emit serviceRegistered(service);
        }

        // TODO: Check whether the service is already running
    }

}

void DBusSensor::watchAll()
{
    kDebug() << "Watching for all";

    d->servicePrefix = QString();

    connect(d->conniface, SIGNAL(serviceOwnerChanged(QString, QString, QString)),
            this,      SIGNAL(serviceOwnerChanged(QString, QString, QString)));
    connect(d->conniface, SIGNAL(serviceRegistered(QString)),
            this,      SIGNAL(serviceRegistered(QString)));
    connect(d->conniface, SIGNAL(serviceUnregistered(QString)),
            this,      SIGNAL(serviceUnregistered(QString)));
}

void DBusSensor::call(const QString & service, const QString & object, const QString & type, const QString & method)
{
    kDebug() << service << object << type << method;
    QDBusInterface remoteApp(service, object, type);
    remoteApp.asyncCall(method);
}

QString DBusSensor::identifier() const
{
    return "DBus";
}

void DBusSensor::__serviceRegistered(const QString & service)
{
    kDebug() << service << d->servicePrefix;

    if (service.startsWith(d->servicePrefix)) {
        emit serviceRegistered(service);
    }
}

void DBusSensor::__serviceUnregistered(const QString & service)
{
    kDebug() << service << d->servicePrefix;

    if (service.startsWith(d->servicePrefix)) {
        emit serviceUnregistered(service);
    }
}

// class DBusSensor


