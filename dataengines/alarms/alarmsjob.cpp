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
#include "alarmcontainer.h"
#include "alarmsengine.h"

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
    m_dataengine = static_cast<AlarmsEngine *>(parent->parent());
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

        if (parameters()["RecursDaily"].toBool()) {
            QBitArray days(6);
            days.fill(true);
            kae.setRecurDaily(1, days, -1, QDate());
        } else {
            kae.setNoRecur();
        }

        kae.setAudioFile(parameters()["AudioFile"].toString(), -1, -1, -1);

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

    }



    //All this operations require an id
    Akonadi::Item::Id id = parameters()["Id"].toLongLong();
    AlarmContainer *container = 0;

    if (id) {
        container = qobject_cast<AlarmContainer *>(m_dataengine->containerForSource(QString("Alarm-%1").arg(id)));
    }

    if (!id || !container) {
        setResult(false);
        return;
    }

    if (operation == "delete") {
        Akonadi::Item item(id);

        Akonadi::ItemDeleteJob *job = new Akonadi::ItemDeleteJob(item);
            connect(job, SIGNAL(result(KJob*)),
                    SLOT(itemJobDone(KJob*)));
        return;

    } else if (operation == "modify") {
        Akonadi::Item item(id);
        KAlarmCal::KAEvent event = container->alarm();

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

        if (parameters()["RecursDaily"].toBool()) {
            QBitArray days(6);
            days.fill(true);
            event.setRecurDaily(1, days, -1, QDate());
        } else {
            event.setNoRecur();
        }

        event.setAudioFile(parameters()["AudioFile"].toString(), -1, -1, -1);

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
        return;


    } else if (operation == "defer") {
        KAlarmCal::KAEvent newEvent(container->alarm());
        newEvent.setItemId(id);
        Akonadi::Item item(id);

        KAlarmCal::DateTime dateTime = newEvent.firstAlarm().dateTime();
        dateTime = dateTime.addMins(parameters()["Minutes"].toInt());

        newEvent.defer(dateTime, (newEvent.firstAlarm().type() & KAlarmCal::KAAlarm::REMINDER_ALARM), true);
        //newEvent.setDeferDefaultMinutes(parameters()["Minutes"].toInt());
        if (!newEvent.setItemPayload(item, m_collection.contentMimeTypes())) {
            kWarning() << "Invalid mime type for collection";
            setResult(false);
            return;
        }

        item.setPayload(newEvent);

        Akonadi::ItemModifyJob *job = new Akonadi::ItemModifyJob(item, this);
        connect(job, SIGNAL(result(KJob*)),
                SLOT(itemJobDone(KJob*)));
        return;

    //Dismissing an alarm will delete it if expired and not recurrent
    } else if (operation == "dismiss") {
        const KDateTime now(KDateTime::currentLocalDateTime());
        KAlarmCal::DateTime dt;
        container->alarm().nextOccurrence(now, dt);

        const KDateTime nextAlarmTime(dt.kDateTime());

        if ((container->alarm().recurrence() && container->alarm().recurrence()->type() == KAlarmCal::KARecurrence::DAILY) ||
            (nextAlarmTime > now)) {

            KAlarmCal::KAEvent newEvent(container->alarm());
            newEvent.setItemId(id);
            Akonadi::Item item(id);

            newEvent.setArchive();
            if (!newEvent.setItemPayload(item, m_collection.contentMimeTypes())) {
                kWarning() << "Invalid mime type for collection";
                setResult(false);
                return;
            }

            item.setPayload(newEvent);

            Akonadi::ItemModifyJob *job = new Akonadi::ItemModifyJob(item, this);
            connect(job, SIGNAL(result(KJob*)),
                    SLOT(itemJobDone(KJob*)));

            container->setActive(false);
        } else {
            Akonadi::Item item(id);

            Akonadi::ItemDeleteJob *job = new Akonadi::ItemDeleteJob(item);
                connect(job, SIGNAL(result(KJob*)),
                        SLOT(itemJobDone(KJob*)));
        }
        return;
    }

    setResult(false);
}

void AlarmsJob::itemJobDone(KJob *job)
{
    setResult(job->error() == 0);
}


#include "alarmsjob.moc"
