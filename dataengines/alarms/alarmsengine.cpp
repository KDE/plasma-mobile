/*
    Copyright 2011 Sebastian Kügler <sebas@kde.org>
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

    //Akonadi::Session *session = new Akonadi::Session("PlasmaAlarmsEngine", this);
    Akonadi::ChangeRecorder* monitor = new Akonadi::ChangeRecorder(this);

    // Restrict monitoring to collections containing the KAlarm mime types
    //monitor->setSession(session);
    monitor->setCollectionMonitored(Akonadi::Collection::root());
    monitor->setResourceMonitored("akonadi_kalarm_resource");
    monitor->setResourceMonitored("akonadi_kalarm_dir_resource");
    monitor->setMimeTypeMonitored(KAlarmCal::MIME_ACTIVE);
    monitor->setMimeTypeMonitored(KAlarmCal::MIME_ARCHIVED);
    monitor->setMimeTypeMonitored(KAlarmCal::MIME_TEMPLATE);
    monitor->itemFetchScope().fetchFullPayload(true);
    monitor->itemFetchScope().fetchAttribute<KAlarmCal::EventAttribute>();

    Akonadi::AttributeFactory::registerAttribute<KAlarmCal::CollectionAttribute>();
    Akonadi::AttributeFactory::registerAttribute<KAlarmCal::CompatibilityAttribute>();
    Akonadi::AttributeFactory::registerAttribute<KAlarmCal::EventAttribute>();

    connect(monitor, SIGNAL(collectionChanged(Akonadi::Collection,QSet<QByteArray>)),
            SLOT(collectionChanged(Akonadi::Collection,QSet<QByteArray>)));
    connect(monitor, SIGNAL(collectionRemoved(Akonadi::Collection)),
            SLOT(collectionRemoved(Akonadi::Collection)));

    connect(monitor, SIGNAL(itemAdded(Akonadi::Item,Akonadi::Collection)),
            SLOT(itemAdded(Akonadi::Item,Akonadi::Collection)) );
    connect(monitor, SIGNAL(itemChanged(Akonadi::Item,QSet<QByteArray>)),
            SLOT(itemChanged(Akonadi::Item,QSet<QByteArray>)) );
    
    Akonadi::Collection alarmCollection(Akonadi::Collection::root());
    alarmCollection.setContentMimeTypes(QStringList() << KAlarmCal::MIME_ACTIVE << KAlarmCal::MIME_ARCHIVED << KAlarmCal::MIME_TEMPLATE);

    Akonadi::CollectionFetchJob* fetch = new Akonadi::CollectionFetchJob( alarmCollection, Akonadi::CollectionFetchJob::Recursive);
    connect( fetch, SIGNAL(result(KJob*)), SLOT(fetchAlarmsCollectionsDone(KJob*)) );
    
    Akonadi::ItemFetchJob *itemFetch = new Akonadi::ItemFetchJob( Akonadi::Collection( 175 ), this );
    itemFetch->fetchScope().fetchFullPayload();
    connect( itemFetch, SIGNAL(result(KJob*)), SLOT(fetchAlarmsCollectionDone(KJob*)) );
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
        
    }
}

void AlarmsEngine::itemChanged(Akonadi::Item item,QSet<QByteArray>)
{
    kDebug() << "Item changed";
    if (item.hasPayload<KAlarmCal::KAEvent>()) {
        const KAlarmCal::KAEvent event = item.payload<KAlarmCal::KAEvent>();
        
    }
}

void AlarmsEngine::fetchAlarmsCollectionsDone(KJob* job)
{
    // called when the job fetching contact collections from Akonadi emits result()
    if ( job->error() ) {
        kDebug() << "Job Error:" << job->errorString();
    } else {
        Akonadi::CollectionFetchJob* cjob = static_cast<Akonadi::CollectionFetchJob*>( job );
        int i = 0;
        foreach( const Akonadi::Collection &collection, cjob->collections() ) {
            
            if (collection.contentMimeTypes().contains(KAlarmCal::MIME_ACTIVE)) {
                kDebug() << "ContactCollection setting data:" << collection.id() << collection.name() << collection.url() << collection.contentMimeTypes();
                i++;
                setData("ContactCollections", QString("ContactCollection-%1").arg(collection.id()), collection.name());
            }
        }
        kDebug() << i << "Contact collections are in now";
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
        }
    }
}

bool AlarmsEngine::sourceRequestEvent(const QString &name)
{
    /*
    // Check if the url is valid
    QUrl url = QUrl(name);
    if (!url.isValid() || url.scheme() == "akonadi") {
        kWarning() << "Not a useful URL:" << name;
        return false;
    }

    AlarmContainer *container = qobject_cast<AlarmContainer *>(containerForSource(name));

    if (!container) {
        // the name and the url are separate because is not possible to
        // know the original string encoding given a QUrl
        container = new AlarmContainer(name, url, this);
        addSource(container);
        container->init();
    }
*/
    return true;
}

#include "alarmsengine.moc"
