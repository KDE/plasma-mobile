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

#include "LocationManager.h"
#include "LocationManager_p.h"

#include <QHash>
#include <QUuid>

#include <KConfig>
#include <KConfigGroup>
#include <KDebug>

#include "network-engines/NetworkNotifier.h"
#include "locationmanageradaptor.h"

namespace Contour {

LocationManager::LocationManager(QObject * parent)
    : QObject(parent), d(new Private())
{
    kDebug() << "Starting the location manager";

    (void) new LocationManagerAdaptor(this);
    QDBusConnection::sessionBus().registerObject(
            QLatin1String("/locationmanager"), this);


    foreach (const QString & id, d->locationsConfig.keyList()) {
        d->knownLocations[id] = d->locationsConfig.readEntry(id, QString());
    }

    connect(NetworkNotifierLoader::self(), SIGNAL(activeAccessPointChanged(QString, QString)),
            this, SLOT(setActiveAccessPoint(QString, QString)));

    NetworkNotifierLoader::self()->init();
}

LocationManager::~LocationManager()
{
    delete d;
}

QString LocationManager::addLocation(const QString & name)
{
    if (name.isEmpty()) {
        return QString();
    }

    QString id = d->knownLocations.key(name);

    if (id.isEmpty()) {
        // We don't have a location with that name

        // Checking whether the name is an UUID. It shouldn't be
        if (!QUuid(name).isNull()) {
            return QString();
        }

        id = QUuid::createUuid();

        d->knownLocations[id] = name;
        d->locationsConfig.writeEntry(id, name);
        d->scheduleConfigSync();
    }

    return id;
}

QString LocationManager::currentLocationId() const
{
    return d->currentLocationId;
}

QString LocationManager::currentLocationName() const
{
    if (d->currentLocationId.isEmpty())
        return QString();

    return d->knownLocations[d->currentLocationId];
}

QString LocationManager::setCurrentLocation(const QString & location)
{
    if (location.isEmpty()) {
        d->currentLocationId = QString();
        emit currentLocationChanged(d->currentLocationId, d->currentLocationId);
        return d->currentLocationId;
    }

    if (QUuid(location).isNull()) {
        // We got a name for the location

        QString id = d->knownLocations.value(location);

        // It will not create a new location if already exists
        d->currentLocationId = addLocation(location);

    } else {
        // We got an UUID

        if (d->knownLocations.contains(location)) {
            d->currentLocationId = location;

        } else {
            d->currentLocationId = QString();
        }
    }

    emit currentLocationChanged(d->currentLocationId, d->knownLocations[d->currentLocationId]);
    return d->currentLocationId;
}

QStringList LocationManager::knownLocations() const
{
    return d->knownLocations.keys();
}

void LocationManager::resetCurrentLocation()
{
    setCurrentLocation(QString());
}

void LocationManager::setActiveAccessPoint(const QString & accessPoint, const QString & backend)
{
    kDebug() << accessPoint << backend;
}

LocationManager::Private::Private()
    : config("contourrc"),
      locationsConfig(&config, "LocationManager-Locations"),
      currentLocationId()
{
    // Config syncing
    connect(&configSyncTimer, SIGNAL(timeout()),
            this, SLOT(configSync()));

    configSyncTimer.setSingleShot(true);
    configSyncTimer.setInterval(2 * /*60 **/ 1000);
}

LocationManager::Private::~Private()
{
    configSync();
}

void LocationManager::Private::scheduleConfigSync()
{
    if (!configSyncTimer.isActive()) {
        configSyncTimer.start();
    }
}

void LocationManager::Private::configSync()
{
    configSyncTimer.stop();
    config.sync();
}


} // namespace Contour
