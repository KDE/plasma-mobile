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

#include "ConnmanNetworkNotifier.h"
#include "connmannetworknotifieradaptor.h"
#include <config-features.h>

#include <QProcess>
#include <QDBusServiceWatcher>
#include <QDBusConnection>

#include <KDebug>

#define CONNMAN_WATCHER_EXEC DATA_INSTALL_DIR"/locationmanager/org.kde.LocationManager.ConnmanWatcher.py"
// #define CONNMAN_DBUS_ADDRESS "org.moblin.connman"
#define CONNMAN_DBUS_ADDRESS "net.connman"

REGISTER_NETWORK_NOTIFIER(ConnmanNetworkNotifier)

class ConnmanNetworkNotifier::Private {
public:
    Private()
        : watcher(NULL), process(NULL)
    {}

    QDBusServiceWatcher * watcher;
    QProcess * process;
};


ConnmanNetworkNotifier::ConnmanNetworkNotifier(QObject * parent)
    : NetworkNotifier(parent), d(new Private())
{
}

void ConnmanNetworkNotifier::init()
{
    kDebug() << "EXECUTABLE:" << CONNMAN_WATCHER_EXEC;

    // Hmh, connman doesn't show up when registered. Lets hope it will be online
    // before the location manager is started

    if (!QDBusConnection::systemBus().interface()->isServiceRegistered(CONNMAN_DBUS_ADDRESS)) {
        kDebug() << "Watching for" << CONNMAN_DBUS_ADDRESS << "to arrive";

        d->watcher = new QDBusServiceWatcher(
                CONNMAN_DBUS_ADDRESS,
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

    d->process = new QProcess(this);
    d->process->setProcessChannelMode(QProcess::ForwardedChannels);
    d->process->start(CONNMAN_WATCHER_EXEC);
}

ConnmanNetworkNotifier::~ConnmanNetworkNotifier()
{
    delete d;
}

void ConnmanNetworkNotifier::setWifiName(const QString & accessPoint)
{
    setActiveAccessPoint(accessPoint);
}

