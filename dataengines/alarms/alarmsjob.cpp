/*
 * Copyright 2012 Marco Martin <mart@kde.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License version 2 as
 * published by the Free Software Foundation
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "alarmsjob.h"

#include <QApplication>
#include <QPalette>
#include <QTime>

#include <KDebug>

#include <Akonadi/ItemCreateJob>
#include <Akonadi/ItemDeleteJob>
#include <Akonadi/ItemFetchJob>
#include <Akonadi/ItemFetchScope>
#include <Akonadi/ItemModifyJob>

#include <kalarmcal/kaevent.h>

#include <kcalcore/alarm.h>
#include <kcalcore/event.h>
#include <kcalcore/calformat.h>


AlarmsJob::AlarmsJob(const Akonadi::Collection &collection, const QString &operation, QMap<QString, QVariant> &parameters, QObject *parent)
    : ServiceJob(parent->objectName(), operation, parameters, parent),
      m_collection(collection)
{
}

AlarmsJob::~AlarmsJob()
{
}

void AlarmsJob::start()
{
    const QString operation = operationName();
    if (operation == "add") {
        QTime time = QTime::fromString(parameters()["Time"].toString(), "hh:mm:ss");
        QDate date = QDate::fromString(parameters()["Date"].toString(), "yyyy-MM-dd");

        if (!time.isValid()) {
            kDebug() << "Invalid time";
            setResult(false);
            return;
        }
        if (!date.isValid()) {
            kDebug() << "Invalid date";
            setResult(false);
            return;
        }

        const QString message = parameters()["Message"].toString();


        KAlarmCal::KAEvent kae;

        kae.set(KDateTime(date, time), message, qApp->palette().base().color(), qApp->palette().text().color(), QFont(), KAlarmCal::KAEvent::MESSAGE, 0, 0, false);

        kae.setEventId(KAlarmCal::CalEvent::uid(KCalCore::CalFormat::createUniqueId(), KAlarmCal::CalEvent::ACTIVE ));

        Akonadi::Item item;
        if (!kae.setItemPayload(item, m_collection.contentMimeTypes())) {
            kWarning() << "Invalid mime type for collection";
            setResult(false);
            return;
        }
        kae.setItemId(item.id());

        Akonadi::ItemCreateJob *job = new Akonadi::ItemCreateJob(item, m_collection);
        connect(job, SIGNAL(result(KJob*)), SLOT(itemJobDone(KJob*)));
        return;

    } else if (operation == "delete") {
        Akonadi::Item::Id id = parameters()["Id"].toLongLong();
        Akonadi::Item item(id);

        //we don't want to delete random item, check that is an alarm before
        Akonadi::ItemFetchJob* job = new Akonadi::ItemFetchJob(item);
        job->fetchScope().fetchFullPayload();
        connect(job, SIGNAL(result(KJob*)),
                SLOT(itemFetchJobForDeleteDone(KJob*)));
        return;

    } else if (operation == "modify") {
        Akonadi::Item::Id id = parameters()["Id"].toLongLong();
        Akonadi::Item item(id);

        m_pendingModificationsParameters[id] = parameters();
        Akonadi::ItemFetchJob* job = new Akonadi::ItemFetchJob(item);
        job->fetchScope().fetchFullPayload();
        connect(job, SIGNAL(result(KJob*)),
                SLOT(itemFetchJobForModifyDone(KJob*)));
        return;
    }
    setResult(false);
}

void AlarmsJob::itemJobDone(KJob *job)
{
    setResult(job->error() == 0);
}

void AlarmsJob::itemFetchJobForModifyDone(KJob *job)
{
    if ( job->error() ) {
        setResult(false);
        return;
    }

    //this list should always be only one item
    Akonadi::Item::List items = static_cast<Akonadi::ItemFetchJob*>( job )->items();
    foreach ( Akonadi::Item item, items ) {
        if (item.hasPayload<KAlarmCal::KAEvent>()) {
            KAlarmCal::KAEvent event = item.payload<KAlarmCal::KAEvent>();
            kWarning() << "Item is a KAEvent" << event.firstAlarm().time();

            QTime time = QTime::fromString(parameters()["Time"].toString(), "hh:mm:ss");
            QDate date = QDate::fromString(parameters()["Date"].toString(), "yyyy-MM-dd");

            if (!time.isValid()) {
                kDebug() << "Invalid time";
                setResult(false);
                return;
            }
            if (!date.isValid()) {
                kDebug() << "Invalid date";
                setResult(false);
                return;
            }

            const QString message = parameters()["Message"].toString();

            event.setTime(KDateTime(date, time));

            event.set(KDateTime(date, time), message, qApp->palette().base().color(), qApp->palette().text().color(), QFont(), KAlarmCal::KAEvent::MESSAGE, 0, 0, false);

            if (!event.setItemPayload(item, m_collection.contentMimeTypes())) {
                kWarning() << "Invalid mime type for collection";
                setResult(false);
                return;
            }

            event.setItemId(item.id());
            item.setPayload(event);

            Akonadi::ItemModifyJob *job = new Akonadi::ItemModifyJob(item, this);
            connect(job, SIGNAL(result(KJob*)),
                    SLOT(itemJobDone(KJob*)));

            m_pendingModificationsParameters.remove(item.id());
            return;
        }
    }
    setResult(false);
}

void AlarmsJob::itemFetchJobForDeleteDone(KJob *job)
{
    if ( job->error() ) {
        setResult(false);
        return;
    }

    //this list should always be only one item
    Akonadi::Item::List items = static_cast<Akonadi::ItemFetchJob*>( job )->items();
    foreach (const Akonadi::Item &item, items ) {
        if (item.hasPayload<KAlarmCal::KAEvent>()) {
            Akonadi::ItemDeleteJob *job = new Akonadi::ItemDeleteJob(item);
            connect(job, SIGNAL(result(KJob*)),
                    SLOT(itemJobDone(KJob*)));
            return;
        }
    }
    setResult(false);
}

#include "alarmsjob.moc"
