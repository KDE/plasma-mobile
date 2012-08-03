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

#include "alarmsengine.h"
#include "alarmcontainer.h"

#include <KJob>

#include <Akonadi/AttributeFactory>
#include <Akonadi/ChangeRecorder>
#include <Akonadi/Session>
#include <Akonadi/Collection>
#include <Akonadi/ItemFetchScope>
#include <Akonadi/ItemFetchJob>
#include <Akonadi/CollectionFetchJob>


#include <kalarmcal/alarmtext.h>
#include <kalarmcal/collectionattribute.h>
#include <kalarmcal/compatibilityattribute.h>
#include <kalarmcal/eventattribute.h>
#include <kalarmcal/kaevent.h>

K_EXPORT_PLASMA_DATAENGINE(AlarmsEngine, AlarmsEngine)


AlarmsEngine::AlarmsEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent)
{
    Q_UNUSED(args);

    //Monitor the collection for changes
    Akonadi::Monitor * monitor = new Akonadi::Monitor( this );
    monitor->setMimeTypeMonitored(KAlarmCal::MIME_ACTIVE);

    monitor->itemFetchScope().fetchFullPayload(true);
    monitor->itemFetchScope().fetchAttribute<KAlarmCal::EventAttribute>();


    connect(monitor, SIGNAL(collectionChanged(Akonadi::Collection,QSet<QByteArray>)),
            SLOT(collectionChanged(Akonadi::Collection,QSet<QByteArray>)));
    connect(monitor, SIGNAL(collectionRemoved(Akonadi::Collection)),
            SLOT(collectionRemoved(Akonadi::Collection)));

    connect(monitor, SIGNAL(itemAdded(Akonadi::Item,Akonadi::Collection)),
            SLOT(itemAdded(Akonadi::Item,Akonadi::Collection)) );
    connect(monitor, SIGNAL(itemChanged(Akonadi::Item,QSet<QByteArray>)),
            SLOT(itemChanged(Akonadi::Item,QSet<QByteArray>)) );
    connect(monitor, SIGNAL(itemRemoved(Akonadi::Item)),
            SLOT(itemRemoved(Akonadi::Item)) );


    Akonadi::Collection alarmCollection(Akonadi::Collection::root());
    alarmCollection.setContentMimeTypes(QStringList() << KAlarmCal::MIME_ACTIVE);

    Akonadi::CollectionFetchJob* fetch = new Akonadi::CollectionFetchJob( alarmCollection, Akonadi::CollectionFetchJob::Recursive);
    connect( fetch, SIGNAL(result(KJob*)), SLOT(fetchAlarmsCollectionsDone(KJob*)) );
}


AlarmsEngine::~AlarmsEngine()
{
}

void AlarmsEngine::collectionChanged(Akonadi::Collection,QSet<QByteArray>)
{
    kDebug() << "Collection added";
}

void AlarmsEngine::collectionRemoved(Akonadi::Collection)
{
    kDebug() << "Collection removed";
}

void AlarmsEngine::itemAdded(Akonadi::Item item,Akonadi::Collection)
{
    kDebug() << "Got an item";
    if (item.hasPayload<KAlarmCal::KAEvent>()) {
        const KAlarmCal::KAEvent event = item.payload<KAlarmCal::KAEvent>();
        kWarning() << "Item is a KAEvent" << event.firstAlarm().time();
        createContainer(event);
    }
}

void AlarmsEngine::itemChanged(Akonadi::Item item,QSet<QByteArray>)
{
    kDebug() << "Item changed";
    if (item.hasPayload<KAlarmCal::KAEvent>()) {
        const KAlarmCal::KAEvent event = item.payload<KAlarmCal::KAEvent>();
        kWarning() << "Item is a KAEvent" << event.firstAlarm().time();
        createContainer(event);
    }
}

void AlarmsEngine::itemRemoved(Akonadi::Item item)
{
    kDebug() << "Removed an item" << item.id();
    removeSource(QString("Alarm-%1").arg(item.id()));
}

void AlarmsEngine::fetchAlarmsCollectionsDone(KJob* job)
{
    // called when the job fetching contact collections from Akonadi emits result()
    if ( job->error() ) {
        kDebug() << "Job Error:" << job->errorString();
    } else {
        Akonadi::CollectionFetchJob* cjob = static_cast<Akonadi::CollectionFetchJob*>( job );
        int i = 0;
        //normally this loop should be a single one
        foreach( const Akonadi::Collection &collection, cjob->collections() ) {
            if (collection.contentMimeTypes().contains(KAlarmCal::MIME_ACTIVE)) {
                //fetch all alarm items
                Akonadi::ItemFetchJob *itemFetch = new Akonadi::ItemFetchJob(collection, this);
                itemFetch->fetchScope().fetchFullPayload();
                connect(itemFetch, SIGNAL(result(KJob*)),
                        SLOT(fetchAlarmsCollectionDone(KJob*)));
            }
        }
        kDebug() << i << "Alarm collections are in now";
        scheduleSourcesUpdated();
    }
}

void AlarmsEngine::fetchAlarmsCollectionDone(KJob* job)
{
    if ( job->error() ) {
        return;
    }
    Akonadi::Item::List items = static_cast<Akonadi::ItemFetchJob*>( job )->items();
    foreach ( const Akonadi::Item &item, items ) {
        kWarning() << "new item";
        if (item.hasPayload<KAlarmCal::KAEvent>()) {
            const KAlarmCal::KAEvent event = item.payload<KAlarmCal::KAEvent>();
            kWarning() << "Item is a KAEvent" << event.firstAlarm().time();
            createContainer(event);
        }
    }
}

void AlarmsEngine::createContainer(const KAlarmCal::KAEvent &event)
{
    const QString name = QString("Alarm-%1").arg(event.itemId());

    AlarmContainer *container = qobject_cast<AlarmContainer *>(containerForSource(name));

    if (!container) {
        // the name and the url are separate because is not possible to
        // know the original string encoding given a QUrl
        container = new AlarmContainer(name, event, this);
        addSource(container);
    }
}

#include "alarmsengine.moc"
