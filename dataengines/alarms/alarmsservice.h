/*
 *   Copyright 2012 Marco MArtin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef ALARMS_SERVICE_H
#define ALARMS_SERVICE_H

#include "alarmsengine.h"

#include <Akonadi/Collection>

#include <Plasma/Service>
#include <Plasma/ServiceJob>


class AlarmsService : public Plasma::Service
{
    Q_OBJECT

public:
    AlarmsService(const Akonadi::Collection &collection, QObject *parent = 0);
    Plasma::ServiceJob *createJob(const QString &operation,
                          QMap<QString, QVariant> &parameters);

private:
    Akonadi::Collection m_collection;
};

#endif // ALARMS_SERVICE_H
