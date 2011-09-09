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

#include "RankingsClient.h"
#include "rankingsclientadaptor.h"

class RankingsClient::Private {
public:

};


RankingsClient::RankingsClient()
    : d(new Private())
{
    QDBusConnection dbus = QDBusConnection::sessionBus();
    new RankingsClientAdaptor(this);
    dbus.registerObject("/Rankings", this);
}

RankingsClient::~RankingsClient()
{
    delete d;
}

void RankingsClient::updated(const QVariantList & data)
{
}

void RankingsClient::inserted(int position, const QVariantList & item)
{
}

void RankingsClient::removed(int position)
{
}

void RankingsClient::changed(int position, const QVariantList & item)
{
}

