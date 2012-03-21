/*
 *   Copyright (C) 2011, 2012 Ivan Cukic <ivan.cukic(at)kde.org>
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

#include "connman-manager.h"
#include "connman-service.h"

#include "ConnmanNetworkNotifier.h"
#include "connmannetworknotifieradaptor.h"
#include <config-features.h>

#include <KDebug>

// #define CONNMAN_DBUS_SERVICE "org.moblin.connman"
#define CONNMAN_DBUS_SERVICE "net.connman"

REGISTER_NETWORK_NOTIFIER(ConnmanNetworkNotifier)

class ConnmanNetworkNotifier::Private {
public:
    Private()
        : iface(0), watcher(0)
    {}

    NetConnmanManagerInterface * iface;
    QDBusServiceWatcher * watcher;
};


ConnmanNetworkNotifier::ConnmanNetworkNotifier(QObject * parent)
    : NetworkNotifier(parent), d(new Private())
{
}

ConnmanNetworkNotifier::~ConnmanNetworkNotifier()
{
    delete d;
}

void ConnmanNetworkNotifier::init()
{
    // Hmh, connman doesn't show up when registered. Lets hope it will be online
    // before the location manager is started

    if (!QDBusConnection::systemBus().interface()->isServiceRegistered(CONNMAN_DBUS_SERVICE)) {
        kDebug() << "Watching for" << CONNMAN_DBUS_SERVICE << "to arrive";

        d->watcher = new QDBusServiceWatcher(
                CONNMAN_DBUS_SERVICE,
                QDBusConnection::systemBus(),
                QDBusServiceWatcher::WatchForRegistration |
                    QDBusServiceWatcher::WatchForUnregistration |
                    QDBusServiceWatcher::WatchForOwnerChange,
                this
            );

        kDebug() << "Connecting" <<
        connect(d->watcher, SIGNAL(serviceRegistered(QString)),
                this, SLOT(enable()));
    } else {
        enable();
    }
}

void ConnmanNetworkNotifier::enable()
{
    kDebug() << "Starting connman listener";

    (void) new ConnmanNetworkNotifierAdaptor(this);
    QDBusConnection::sessionBus().registerObject(
            QLatin1String("/ConnmanInterface"), this);

    delete d->iface;
    d->iface = new NetConnmanManagerInterface(CONNMAN_DBUS_SERVICE, QLatin1String("/"), QDBusConnection::systemBus(), this);
    connect(d->iface, SIGNAL(PropertyChanged(QString,QDBusVariant)), SLOT(propertyChanged(QString,QDBusVariant)));

    QDBusReply<QVariantMap> reply = d->iface->GetProperties();
    if (!reply.isValid()) {
        kDebug() << "GetProperties reply was invalid";
        return;
    }
    QVariantMap properties = reply.value();
    //kDebug() << "Initial state: " << properties["State"].toString();
    propertyChanged("State", QDBusVariant(properties["State"]));
}

// monitor when connman connects to a network, or disconnects from it.
// On those events, this method passes the info to the locationmanager daemon
// via the dummy network notifier.
void ConnmanNetworkNotifier::propertyChanged(const QString &name, const QDBusVariant &value)
{
    //kDebug() << name << ": " << value.variant().toString();
    if (name != QLatin1String("State")) {
        kDebug() << "Property" << name << "ignored";
        return;
    }

    // we are offline
    if (value.variant().toString() != QLatin1String("online")) {
        kDebug() << "OFFLINE";
        setWifiName("");
        return;
    }

    QDBusReply<QVariantMap> reply = d->iface->GetProperties();
    if (!reply.isValid()) {
        kDebug() << "GetProperties failed" << reply.error().message();
        return;
    }

    QVariantMap properties = reply.value();
    //kDebug() << "got properties:" << properties.count();
    //kDebug() << "Services ==" << properties["Services"];
    QList<QDBusObjectPath> services = qdbus_cast<QList<QDBusObjectPath> >(properties["Services"]);
    //kDebug() << services.count() << "services";

    // searching for active wifi info
    foreach (const QDBusObjectPath &s, services) {
        kDebug() << "testing service" << s.path();

        NetConnmanServiceInterface service(CONNMAN_DBUS_SERVICE, s.path(), QDBusConnection::systemBus());

        if (!service.isValid()) {
            kDebug() << "Service" << s.path() << "is not valid";
            continue;
        }

        QDBusReply<QVariantMap> reply = service.GetProperties();
        if (!reply.isValid()) {
            kDebug() << "GetProperties failed for";
            continue;
        }

        QVariantMap serviceProperties = reply.value();
        if (serviceProperties["State"].toString() == QLatin1String("ready")) {
            kDebug() << "CONNECTED TO:" << serviceProperties["Name"];
            setWifiName(serviceProperties["Name"].toString());
            return;
        }
    }
}

void ConnmanNetworkNotifier::setWifiName(const QString & accessPoint)
{
    setActiveAccessPoint(accessPoint);
}

