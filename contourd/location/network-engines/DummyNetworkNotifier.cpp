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

#include "DummyNetworkNotifier.h"

#include <QHash>

#include <KDebug>

#include "dummynetworknotifieradaptor.h"

REGISTER_NETWORK_NOTIFIER(DummyNetworkNotifier)

class DummyNetworkNotifier::Private {
public:

};


DummyNetworkNotifier::DummyNetworkNotifier(QObject * parent)
    : NetworkNotifier(parent), d(new Private())
{
}

void DummyNetworkNotifier::init()
{
    kDebug() << "Dummy";

    (void) new DummyNetworkNotifierAdaptor(this);
    QDBusConnection::sessionBus().registerObject(
            QLatin1String("/dummynn"), this);

}

DummyNetworkNotifier::~DummyNetworkNotifier()
{
    delete d;
}

void DummyNetworkNotifier::setWifiName(const QString & accessPoint)
{
    setActiveAccessPoint(accessPoint);
}

