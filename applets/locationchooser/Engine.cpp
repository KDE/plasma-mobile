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
    QStringList locations;
    qreal listItemHeight;
};

Engine::Engine(Plasma::PopupApplet * parent)
    : QObject(parent), d(new Private())
{
    d->locationManager = new org::kde::LocationManager(
            LOCATION_MANAGER_DBUS_PATH,
            LOCATION_MANAGER_DBUS_OBJECT,
            QDBusConnection::sessionBus(),
            this),
    d->parent = parent;

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

                d->locations << d->locationManager->locationName(id);
            }

            kDebug() << d->locations <<

            QMetaObject::invokeMethod(parent, "knownLocationsChanged",
                    Qt::QueuedConnection, Q_ARG(QStringList, d->locations));

            deleteLater();
        }

    private:
        Engine * const parent;
        Engine::Private * const d;

    };

    connect(d->locationManager, SIGNAL(currentLocationChanged(QString, QString)),
            this, SLOT(onCurrentLocationChanged(QString, QString)));

    connect(d->locationManager, SIGNAL(locationAdded(QString, QString)),
            this, SLOT(onLocationAdded(QString, QString)));
    connect(d->locationManager, SIGNAL(locationRemoved(QString, QString)),
            this, SLOT(onLocationRemoved(QString, QString)));
    connect(d->locationManager, SIGNAL(locationNameChanged(QString, QString, QString)),
            this, SLOT(onLocationNameChanged(QString, QString, QString)));

    kDebug() << "Starting the async getter";
    (new GetLocations(this, d))->start();
}

void Engine::setIcon(const QString & icon)
{
    d->parent->setPopupIcon("plasmaapplet-" + icon);
}

QString Engine::currentLocationId() const
{
    return d->locationManager->currentLocationId();
}

QString Engine::currentLocationName() const
{
    return d->locationManager->currentLocationName();
}

void Engine::onCurrentLocationChanged(const QString & id, const QString & name)
{
    emit currentLocationIdChanged(id);
    emit currentLocationNameChanged(name);
}

void Engine::setCurrentLocation(const QString & location)
{
    d->locationManager->setCurrentLocation(location);
    d->parent->hidePopup();
}

void Engine::requestUiReset()
{
    emit resetUiRequested();
}

void Engine::setState(const QString & state)
{
    if (state == "Showing") {
        d->parent->graphicsWidget()->resize(d->regularSize);

    } else if (state == "Querying") {
        d->regularSize = d->parent->graphicsWidget()->size();

        QSizeF bigSize(d->regularSize);
        bigSize.setHeight(
                bigSize.height() + d->locations.size() * (4 + d->listItemHeight)
                );
        d->parent->graphicsWidget()->resize(bigSize);
    }
}

void Engine::setListItemHeight(qreal height)
{
    kDebug() << height;
    d->listItemHeight = height;
}

QStringList Engine::knownLocations() const
{
    return d->locations;
}

void Engine::onLocationAdded(const QString & id, const QString & name)
{
    Q_UNUSED(id)
    kDebug() << id << name;
    d->locations << name;
    emit knownLocationsChanged(d->locations);
}

void Engine::onLocationRemoved(const QString & id, const QString & name)
{
    Q_UNUSED(id)
    kDebug() << id << name;
    d->locations.removeAll(name);
    emit knownLocationsChanged(d->locations);
}

void Engine::onLocationNameChanged(const QString & id, const QString & oldname, const QString & newname)
{
    Q_UNUSED(id)
    d->locations.removeAll(oldname);
    d->locations << newname;
    emit knownLocationsChanged(d->locations);
}

