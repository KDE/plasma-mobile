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
#include <locationmanager_interface.h>

#define LOCATION_MANAGER_DBUS_PATH "org.kde.LocationManager"
#define LOCATION_MANAGER_DBUS_OBJECT "/LocationManager"

class Engine::Private {
public:
    org::kde::LocationManager * locationManager;
    Plasma::PopupApplet * parent;
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

    connect(d->locationManager, SIGNAL(currentLocationChanged(QString, QString)),
            this, SLOT(onCurrentLocationChanged(QString, QString)));
}

void Engine::setIcon(const QString & icon)
{
    d->parent->setPopupIcon(icon);
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
}

void Engine::requestUiReset()
{
    emit resetUiRequested();
}

