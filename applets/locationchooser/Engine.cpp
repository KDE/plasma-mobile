/*
 *   Copyright (C) 2012 Ivan Cukic <ivan.cukic(at)kde.org>
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

#include "Engine.h"

#include <QDBusConnection>
#include <QtConcurrentRun>
#include <locationmanager_interface.h>

#define LOCATION_MANAGER_DBUS_PATH "org.kde.LocationManager"
#define LOCATION_MANAGER_DBUS_OBJECT "/LocationManager"

class Engine::Private {
public:
    org::kde::LocationManager * locationManager;
    Plasma::PopupApplet * parent;
    QSizeF regularSize;
    QVariantHash locations;
    qreal listItemHeight;
    QDBusServiceWatcher * watcher;
};

Engine::Engine(Plasma::PopupApplet * parent)
    : QObject(parent), d(new Private())
{
    d->locationManager = NULL;
    d->parent = parent;
}

void Engine::init()
{
    d->watcher = new QDBusServiceWatcher(QLatin1String(LOCATION_MANAGER_DBUS_PATH),
                        QDBusConnection::sessionBus(),
                        QDBusServiceWatcher::WatchForRegistration |
                        QDBusServiceWatcher::WatchForUnregistration,
                        this);
    connect(d->watcher, SIGNAL(serviceRegistered(QString)), this, SLOT(onServiceRegistered()));
    connect(d->watcher, SIGNAL(serviceUnregistered(QString)), this, SLOT(onServiceUnregistered()));

    bool servicePresent = QDBusConnection::sessionBus().interface()->isServiceRegistered(LOCATION_MANAGER_DBUS_PATH);

    if (servicePresent) {
        onServiceRegistered();
    } else {
        onServiceUnregistered();
    }
}

void Engine::onServiceRegistered()
{
    d->locationManager = new org::kde::LocationManager(
            LOCATION_MANAGER_DBUS_PATH,
            LOCATION_MANAGER_DBUS_OBJECT,
            QDBusConnection::sessionBus(),
            this);

    // This would be so much nicer as a .\ in C++11
    // Heck, it would be nicer even with boost::bind
    class GetLocations: public QThread {
    public:
        GetLocations(Engine * parent_, Engine::Private * d_)
            : parent(parent_), d(d_)
        {
        }

    protected:
        void run()
        {
            foreach (const QString & id, d->locationManager->knownLocations().value()) {
                if (id.isEmpty()) continue;

                QVariantHash loc;
                loc["id"] = id;
                loc["name"] = QString(d->locationManager->locationName(id));
                d->locations[id] = loc;
            }

            QMetaObject::invokeMethod(parent, "knownLocationsChanged",
                    Qt::QueuedConnection, Q_ARG(QVariantList, d->locations.values()));

            deleteLater();
        }

    private:
        Engine * const parent;
        Engine::Private * const d;

    };

    connect(d->locationManager, SIGNAL(currentLocationChanged(QString,QString)),
            this, SLOT(onCurrentLocationChanged(QString,QString)));

    connect(d->locationManager, SIGNAL(locationAdded(QString,QString)),
            this, SLOT(onLocationAdded(QString,QString)));
    connect(d->locationManager, SIGNAL(locationRemoved(QString,QString)),
            this, SLOT(onLocationRemoved(QString,QString)));
    connect(d->locationManager, SIGNAL(locationNameChanged(QString,QString,QString)),
            this, SLOT(onLocationNameChanged(QString,QString,QString)));

    // Starting the async getter
    (new GetLocations(this, d))->start();

    emit locationManagerPresenceChanged();

    setIcon("location");
}

void Engine::onServiceUnregistered()
{
    delete d->locationManager;
    d->locationManager = NULL;

    setState("Error");

    emit locationManagerPresenceChanged();

    d->parent->setPopupIcon("application-exit");
}

void Engine::setIcon(const QString & icon)
{
    if (d->locationManager) {
        d->parent->setPopupIcon("plasmaapplet-" + icon);
    } else {
        d->parent->setPopupIcon("application-exit");
    }
}

QString Engine::currentLocationId() const
{
    if (d->locationManager)
        return d->locationManager->currentLocationId();
    else
        return i18n("The location manager is not running");
}

QString Engine::currentLocationName() const
{
    if (d->locationManager)
        return d->locationManager->currentLocationName();
    else
        return i18n("The location manager is not running");
}

void Engine::onCurrentLocationChanged(const QString & id, const QString & name)
{
    emit currentLocationIdChanged(id);
    emit currentLocationNameChanged(name);
}

void Engine::setCurrentLocation(const QString & location)
{
    if (d->locationManager) {
        d->locationManager->setCurrentLocation(location);
    }

    d->parent->hidePopup();
}

void Engine::removeLocation(const QString & location)
{
    if (d->locationManager) {
        d->locationManager->removeLocation(location);
    }
}

void Engine::requestUiReset()
{
    setIcon("location");
    emit resetUiRequested();
}

void Engine::setState(const QString & state)
{
    if (state == "Showing" || state == "Error") {
        d->parent->graphicsWidget()->resize(d->regularSize);

    } else if (state == "Querying") {
        d->regularSize = d->parent->graphicsWidget()->size();

        QSizeF bigSize(d->regularSize);
        qreal height = bigSize.height() + d->locations.size() * (4 + d->listItemHeight);
        if (height > 400) {
            height = 400;
        }

        bigSize.setHeight(height);
        d->parent->graphicsWidget()->resize(bigSize);
    }
}

void Engine::setListItemHeight(qreal height)
{
    d->listItemHeight = height;
}

QVariantList Engine::knownLocations() const
{
    return d->locations.values();
}

void Engine::onLocationAdded(const QString & id, const QString & name)
{
    Q_UNUSED(id)
    QVariantHash location;
    location["id"] = id;
    location["name"] = name;
    d->locations[id] = location;
    emit knownLocationsChanged(d->locations.values());
}

void Engine::onLocationRemoved(const QString & id, const QString & name)
{
    Q_UNUSED(id)
    d->locations.remove(id);
    emit knownLocationsChanged(d->locations.values());
}

void Engine::onLocationNameChanged(const QString & id, const QString & oldname, const QString & newname)
{
    Q_UNUSED(id)
    QVariantHash location;
    location["id"] = id;
    location["name"] = newname;
    d->locations[id] = location;
    emit knownLocationsChanged(d->locations.values());
}

bool Engine::locationManagerPresent() const
{
    return (d->locationManager != NULL);
}
