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


    foreach (const QString & id, d->locationNames.keyList()) {
        const QString & name = d->locationNames.readEntry(id, QString());
        d->knownLocationIds[name] = id;

        d->knownLocationInfos[id].name         = name;
        d->knownLocationInfos[id].networks     = d->locationNetworks.readEntry(id, QStringList()).toSet();
        d->knownLocationInfos[id].networkRoots = d->locationNetworkRoots.readEntry(id, QStringList()).toSet();
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

    QString id = d->knownLocationIds.value(name);

    if (id.isEmpty()) {
        // We don't have a location with that name

        // Checking whether the name is an UUID. It shouldn't be
        if (!QUuid(name).isNull()) {
            return QString();
        }

        id = QUuid::createUuid();

        d->knownLocationIds[name] = id;
        d->knownLocationInfos[id].name = name;
        d->locationNames.writeEntry(id, name);

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

    return d->knownLocationInfos[d->currentLocationId].name;
}

QString LocationManager::setCurrentLocation(const QString & location)
{
    if (location.isEmpty()) {
        d->currentLocationId = QString();
        emit currentLocationChanged(d->currentLocationId, d->currentLocationId);
        return d->currentLocationId;
    }

    kDebug() << "Setting the current location to" << location;

    if (QUuid(location).isNull()) {
        // We got passed a name for the location, not an id
        // addLocation will not create a new location if already exists:
        d->currentLocationId = addLocation(location);

    } else {
        // We got an UUID
        if (d->knownLocationInfos.contains(location)) {
            d->currentLocationId = location;

        } else {
            d->currentLocationId = QString();
        }
    }

    if (!d->currentNetworkName.isEmpty()) {
        kDebug() << "Current network name is" << d->currentNetworkName;
        d->addNetworkToLocation(d->currentLocationId, d->currentNetworkName);
    }

    emit currentLocationChanged(d->currentLocationId, d->knownLocationInfos[d->currentLocationId].name);
    return d->currentLocationId;
}

QStringList LocationManager::knownLocations() const
{
    return d->knownLocationInfos.keys();
}

void LocationManager::resetCurrentLocation()
{
    setCurrentLocation(QString());
}

void LocationManager::setActiveAccessPoint(const QString & accessPoint, const QString & backend)
{
    kDebug() << accessPoint << backend;
    d->currentNetworkName = accessPoint;

    // TODO: do stuff :)

    // Checking whether we already have this access point
    // tied to a location

    kDebug() << "Checking whether we already have this access point tied to a location";

    QHashIterator <QString, Private::LocationInfo> item(d->knownLocationInfos);
    while (item.hasNext()) {
        item.next();

        kDebug() << item.key() << "has networks" << item.value().networks;

        if (item.value().networks.contains(accessPoint)) {
            setCurrentLocation(item.key());
            return;
        }
    }

    // Checking whether we have a location that was tied
    // to a similarly named access point

    const QString & accessPointRoot = d->networkRoot(accessPoint);

    item.toFront();
    while (item.hasNext()) {
        item.next();

        if (item.value().networkRoots.contains(accessPointRoot)) {
            setCurrentLocation(item.key());
            return;
        }
    }

    // Nothing found
    resetCurrentLocation();
}

LocationManager::Private::Private()
    : config("contourrc"),
      locationNames(&config, "LocationManager-Location-Names"),
      locationNetworks(&config, "LocationManager-Location-Networks"),
      locationNetworkRoots(&config, "LocationManager-Location-NetworkRoots"),
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

void LocationManager::Private::addNetworkToLocation(const QString & location, const QString & network)
{
    if (!knownLocationInfos.contains(location) || network.isEmpty()) return;

    knownLocationInfos[location].networks     << network;
    knownLocationInfos[location].networkRoots << networkRoot(network);

    kDebug()
        << "Setting networks for"
        << location
        << knownLocationInfos[location].name
        << knownLocationInfos[location].networks
        << knownLocationInfos[location].networkRoots
        ;

    locationNetworks.writeEntry(location, knownLocationInfos[location].networks.toList());
    locationNetworkRoots.writeEntry(location, knownLocationInfos[location].networkRoots.toList());

    scheduleConfigSync();
}

QString LocationManager::Private::networkRoot(const QString & name)
{
    // We are going to try to strip all the suffix data from
    // the network name
    QString result = name.toLower();

    int lastDash = -1;
    int lastLetter = -1;

    for (int i = 0; i < name.size(); i++) {
        if (name[i] == '-' || name[i] == '_') {
            lastDash = i;

        } else if (name[i] > '9') {
            lastLetter = i;

        }
    }

    if (lastLetter == name.size() - 1) {
        // Letters are till the end of the name

        if (lastDash > name.size() / 2) {
            // The last dash is in the second half of the name,
            // considering it and the rest of the name as a suffix
            return result.left(lastDash);

        } else {
            // The letters are going to the end of the name, and
            // there are no dashes or we are ignoring them
            return result;

        }

    } else {
        // We want to remove the end of the name

        int last = qMin(lastDash, lastLetter);

        if (last <= name.size()) {
            last = qMax(lastDash, lastLetter);
        }

        if (last > name.size() / 2) {
            return result.left(last);
        }

        return result;
    }
}


} // namespace Contour
