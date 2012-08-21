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
#include "alarmsservice.h"
#include "calendarcreator.h"

#include <KJob>

#include <Akonadi/AgentInstance>
#include <Akonadi/AgentManager>
#include <Akonadi/AttributeFactory>
#include <Akonadi/ChangeRecorder>
#include <Akonadi/CollectionFetchScope>
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
    : Plasma::DataEngine(parent),
      m_collectionJobs(0)
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


    //TODO: be really sure what alarm collections are missing
    bool agentFound = false;
    Akonadi::AgentInstance::List agents = Akonadi::AgentManager::self()->instances();
    foreach (const Akonadi::AgentInstance& agent, agents)
    {
        QString type = agent.type().identifier();
        if (type == QLatin1String("akonadi_kalarm_resource")
        ||  type == QLatin1String("akonadi_kalarm_dir_resource")) {
            // Fetch the resource's collection to determine its alarm types
            Akonadi::CollectionFetchJob* job = new Akonadi::CollectionFetchJob(Akonadi::Collection::root(), Akonadi::CollectionFetchJob::FirstLevel);
            ++m_collectionJobs;
            job->fetchScope().setResource(agent.identifier());
            connect(job, SIGNAL(result(KJob*)), SLOT(fetchAlarmsCollectionsDone(KJob*)));
            // Note: Once all collections have been fetched, any missing
            //       default resources will be created.

            //we still aren't sure the found agent is the correct one
            agentFound = true;
        }
    }

    //need to create the agent
    if (!agentFound) {
        CalendarCreator *creator = new CalendarCreator(CalEvent::ACTIVE, QLatin1String("calendar.ics"), i18nc("@info/plain", "Active Alarms"));
        connect(creator, SIGNAL(finished(CalendarCreator*)), SLOT(calendarCreated(CalendarCreator*)));
        //connect(creator, SIGNAL(creating(QString)), SLOT(creatingCalendar(QString)));
        creator->createAgent(QLatin1String("akonadi_kalarm_resource"), this);
    }
}


AlarmsEngine::~AlarmsEngine()
{
}

void AlarmsEngine::calendarCreated(CalendarCreator *creator)
{
    Akonadi::Collection alarmCollection(Akonadi::Collection::root());
    alarmCollection.setContentMimeTypes(QStringList() << KAlarmCal::MIME_ACTIVE);

    Akonadi::CollectionFetchJob* fetch = new Akonadi::CollectionFetchJob( alarmCollection, Akonadi::CollectionFetchJob::Recursive);
    ++m_collectionJobs;
    connect( fetch, SIGNAL(result(KJob*)), SLOT(fetchAlarmsCollectionsDone(KJob*)) );
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
        kWarning() << "Item is a KAEvent" << event.firstAlarm().date() << event.firstAlarm().time();
        createContainer(event);
    }
}

void AlarmsEngine::itemChanged(Akonadi::Item item,QSet<QByteArray>)
{
    kDebug() << "Item changed";
    if (item.hasPayload<KAlarmCal::KAEvent>()) {
        const KAlarmCal::KAEvent event = item.payload<KAlarmCal::KAEvent>();
        kWarning() << "Item is a KAEvent" << event.firstAlarm().date() << event.firstAlarm().time();
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
                m_collection = collection;
                //fetch all alarm items
                Akonadi::ItemFetchJob *itemFetch = new Akonadi::ItemFetchJob(collection, this);
                itemFetch->fetchScope().fetchFullPayload();
                connect(itemFetch, SIGNAL(result(KJob*)),
                        SLOT(fetchAlarmsCollectionDone(KJob*)));
            }
        }
        --m_collectionJobs;
        if (m_collectionJobs <= 0) {
            m_collectionJobs = 0;
            if (!m_collection.isValid()) {
                CalendarCreator *creator = new CalendarCreator(CalEvent::ACTIVE, QLatin1String("calendar.ics"), i18nc("@info/plain", "Active Alarms"));
                connect(creator, SIGNAL(finished(CalendarCreator*)), SLOT(calendarCreated(CalendarCreator*)));
                creator->createAgent(QLatin1String("akonadi_kalarm_resource"), this);
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
            kWarning() << "Item is a KAEvent" << event.firstAlarm().date() << event.firstAlarm().time();
            createContainer(event);
        }
    }
}

void AlarmsEngine::createContainer(const KAlarmCal::KAEvent &event)
{
    const QString name = QString("Alarm-%1").arg(event.itemId());

    AlarmContainer *container = qobject_cast<AlarmContainer *>(containerForSource(name));

    if (container) {
        container->setAlarm(event);
    } else {
        // the name and the url are separate because is not possible to
        // know the original string encoding given a QUrl
        container = new AlarmContainer(name, event, m_collection, this);
        addSource(container);
    }
}

Plasma::Service *AlarmsEngine::serviceForSource(const QString &source)
{
    //since ids change when modifying an alarm we can't attach anything to a source
    if (!source.isEmpty()) {
        return 0;
    }

    if (!m_service) {
        m_service = new AlarmsService(m_collection, this);
    }
    return m_service.data();
}

#include "alarmsengine.moc"
