/*
    Copyright 2005 S.R.Haque <srhaque@iee.org>.
    Copyright 2009 David Faure <faure@kde.org>
    Copyright 2011 Sebastian Kügler <sebas@kde.org>

    This file is part of the KDE project

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License version 2, as published by the Free Software Foundation.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#include "timezone.h"

#include <kdebug.h>
#include <KLocale>
#include <KSystemTimeZone>
#include <KTimeZone>


class TimeZonePrivate {
public:
    TimeZone *q;
    KTimeZone zone;
    QString name;
};

TimeZone::TimeZone(const KTimeZone &zone, QObject* parent)
    : QObject(parent)
{
    d = new TimeZonePrivate;
    d->q = this;
    d->zone = zone;
    setName(zone.name());
    //kDebug() << "new tz: " << d->name;
}

TimeZone::~TimeZone()
{
    delete d;
}

QString TimeZone::name()
{
    return d->name;
}

void TimeZone::setName(const QString &n)
{
    d->name = n;
    emit nameChanged();
}

#include "timezone.moc"
