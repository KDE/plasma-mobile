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

#include "NetworkNotifier.h"

#include <QHash>
#include <QString>

NetworkNotifier::NetworkNotifier(QObject * parent)
    : QObject(parent)
{
}

NetworkNotifier::~NetworkNotifier()
{
}

void NetworkNotifier::setSsid(const QString & ssid)
{
    emit ssidChanged(ssid);
}

// NetworkNotifierLoader

class NetworkNotifierLoader::Private {
public:
    QHash < QString, NetworkNotifier * > notifiers;
};

NetworkNotifierLoader * NetworkNotifierLoader::s_instance = NULL;

NetworkNotifierLoader * NetworkNotifierLoader::self()
{
    if (!s_instance) {
        s_instance = new NetworkNotifierLoader();
    }

    return s_instance;
}

NetworkNotifierLoader::NetworkNotifierLoader()
    : d(new Private())
{
}

NetworkNotifierLoader::~NetworkNotifierLoader()
{
    delete d;
}

void NetworkNotifierLoader::registerNetworkNotifier(const QString & name, NetworkNotifier * nn)
{
    d->notifiers[name] = nn;
}

void NetworkNotifierLoader::init()
{
    foreach (NetworkNotifier * nn, d->notifiers.values()) {
        nn->init();
    }
}
