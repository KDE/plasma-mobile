/*
    Copyright 2012 Marco Martin <mart@kde.org>

    This library is free software; you can redistribute it and/or modify it
    under the terms of the GNU Library General Public License as published by
    the Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    This library is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public
    License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
    02110-1301, USA.
*/


#ifndef ALARMSENGINE_H
#define ALARMSENGINE_H

#include <plasma/dataengine.h>

#include <Akonadi/Collection>
#include <Akonadi/Item>

#include <kalarmcal/kaevent.h>

class KJob;

class AlarmsEngine : public Plasma::DataEngine
{
    Q_OBJECT

public:
    AlarmsEngine(QObject* parent, const QVariantList& args);
    ~AlarmsEngine();

protected:
    void createContainer(const KAlarmCal::KAEvent &event);

protected Q_SLOTS:
    void collectionChanged(Akonadi::Collection,QSet<QByteArray>);
    void collectionRemoved(Akonadi::Collection);
    void itemAdded(Akonadi::Item,Akonadi::Collection);
    void itemChanged(Akonadi::Item item,QSet<QByteArray>);
    void itemRemoved(Akonadi::Item item);
    void fetchAlarmsCollectionsDone(KJob* job);
    void fetchAlarmsCollectionDone(KJob* job);

private:
    
};

#endif
