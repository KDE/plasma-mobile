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
    : QObject(parent), d(new Private(this))
{
    kDebug() << "Starting the location manager";

    (void) new LocationManagerAdaptor(this);
    QDBusConnection::sessionBus().registerObject(
            QLatin1String("/LocationManager"), this);
    QDBusConnection::sessionBus().registerService("org.kde.LocationManager");


    foreach (const QString & id, d->locationNames.keyList()) {
        if (id.isEmpty()) continue;

        const QString & name = d->locationNames.readEntry(id, QString());
        d->knownLocationIds[name] = id;

        d->knownLocationInfos[id].name         = name;
        d->knownLocationInfos[id].networks     = d->locationNetworks.readEntry(id, QStringList()).toSet();
        d->knownLocationInfos[id].networkRoots = d->locationNetworkRoots.readEntry(id, QStringList()).toSet();
    }

    connect(NetworkNotifierLoader::self(), SIGNAL(activeAccessPointChanged(QString,QString)),
            this, SLOT(setActiveAccessPoint(QString,QString)));

    NetworkNotifierLoader::self()->init();

#ifdef RUN_LOCATION_TESTS
    d->testRootFinding();
#endif
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

        emit locationAdded(id, name);
    }

    return id;
}

void LocationManager::removeLocation(const QString & id)
{
    if (!d->knownLocationInfos.contains(id)) return;

    if (id == d->currentLocationId) {
        d->setCurrentLocation(QString());
    }

    d->knownLocationIds.remove(d->knownLocationInfos[id].name);
    d->knownLocationInfos.remove(id);

    d->locationNetworks.deleteEntry(id);
    d->locationNetworkRoots.deleteEntry(id);
    d->locationNames.deleteEntry(id);

    d->scheduleConfigSync();

    emit locationRemoved(id, d->knownLocationInfos[id].name);
}

void LocationManager::setLocationName(const QString & id, const QString & name)
{
    if (!d->knownLocationInfos.contains(id)) return;

    emit locationNameChanged(id, d->knownLocationInfos[id].name, name);

    d->knownLocationIds.remove(d->knownLocationInfos[id].name);
    d->knownLocationInfos[id].name = name;
    d->knownLocationIds[name] = id;

    d->locationNames.writeEntry(id, name);

    d->scheduleConfigSync();
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

QString LocationManager::locationName(const QString & id) const
{
    if (!d->knownLocationInfos.contains(id))
        return QString();

    return d->knownLocationInfos[id].name;
}

void LocationManager::setCurrentLocation(const QString & location)
{
    QMetaObject::invokeMethod(
            d,
            "setCurrentLocation",
            Qt::QueuedConnection,
            Q_ARG(QString, location)
        );
}

void LocationManager::Private::setCurrentLocation(const QString & location)
{
    if (location.isEmpty()) {
        currentLocationId.clear();
        emit q->currentLocationChanged(currentLocationId, currentLocationId);
        return;
    }

    kDebug() << "Setting the current location to" << location;

    if (QUuid(location).isNull()) {
        // We got passed a name for the location, not an id
        // addLocation will not create a new location if already exists:
        currentLocationId = q->addLocation(location);

    } else {
        // We got an UUID
        if (knownLocationInfos.contains(location)) {
            currentLocationId = location;

        } else {
            currentLocationId.clear();
        }
    }

    if (!currentNetworkName.isEmpty()) {
        kDebug() << "Current network name is" << currentNetworkName;
        addNetworkToLocation(currentLocationId, currentNetworkName);
    }

    emit q->currentLocationChanged(currentLocationId, knownLocationInfos[currentLocationId].name);
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

LocationManager::Private::Private(LocationManager * parent)
    : config("locationmanagerrc"),
      locationNames(&config, "Names"),
      locationNetworks(&config, "Networks"),
      locationNetworkRoots(&config, "NetworkRoots"),
      currentLocationId(),
      q(parent)
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

    // we first need to test whether there is already a network
    // with the same root/name. If yes, we need to remove it and set
    // the root/name as unknown location (aka empty)

    const QString & root = networkRoot(network);
    bool rootAlreadyRegistered = false;

    QMutableHashIterator <QString, Private::LocationInfo> item(knownLocationInfos);
    while (item.hasNext()) {
        item.next();

        const QString & testLocation = item.key();

        if (testLocation == location) continue;

        Private::LocationInfo & info = item.value();

        kDebug() << testLocation << "has networks" << info.networks << info.networkRoots;

        if (info.networks.contains(network)) {
            info.networks.remove(network);
            locationNetworks.writeEntry(testLocation, info.networks.toList());
            kDebug() << "Name is already registered";
        }

        if (info.networkRoots.contains(root)) {
            info.networkRoots.remove(root);
            locationNetworkRoots.writeEntry(testLocation, info.networkRoots.toList());
            rootAlreadyRegistered = true;
            kDebug() << "Root is already registered";
        }
    }

    knownLocationInfos[location].networks     << network;

    if (!rootAlreadyRegistered) {
        kDebug() << "Root was not registered";
        knownLocationInfos[location].networkRoots << root;
    }

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

    lastLetter++;

    if (lastLetter == name.size()) {
        // Letters are till the end of the name

        if (lastDash > name.size() / 2 || lastDash > 5) {
            // The last dash is in the second half of the name, or the
            // main name is longer than 5 characters
            // considering it and the rest of the name as a suffix
            kDebug() << "Returning (1) " << result.left(lastDash);
            return result.left(lastDash);

        } else {
            // The letters are going to the end of the name, and
            // there are no dashes or we are ignoring them
            kDebug() << "Returning (2) " << result;
            return result;

        }

    } else {
        // We want to remove the end of the name

        int last = lastDash;

        if (last <= 0) {
            last = lastLetter;
        }

        if (last >= name.size() / 2) {
            kDebug() << "Returning (3) " << result.left(last);
            return result.left(last);
        }

        kDebug() << "Returning (4) " << result;
        return result;
    }
}


#ifdef RUN_LOCATION_TESTS
void LocationManager::Private::testRootFinding()
{
    foreach (const QString & network,
            QStringList()
                << "kde"
                << "kde3"
                << "kde4.2"
                << "kde-4.3"
                << "kde-4b"
                << "kde-12"
                << "kdesc-42"
                << "kdesc-35"
                << "kdesc"
    ) {
        kDebug()
            << "Network" << network
            << "root is" << networkRoot(network);
    }
}
#endif


} // namespace Contour
