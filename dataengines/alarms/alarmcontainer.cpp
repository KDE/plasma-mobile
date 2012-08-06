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
 * GNU Library General Public License for more details
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "alarmcontainer.h"
#include "alarmsengine.h"

#include <Akonadi/ItemDeleteJob>
#include <Akonadi/ItemModifyJob>

#include <kalarmcal/datetime.h>


AlarmContainer::AlarmContainer(const QString &name,
                               const KAlarmCal::KAEvent &alarm,
                               const Akonadi::Collection &collection,
                               QObject *parent)
    : Plasma::DataContainer(parent),
      m_alarmEvent(alarm),
      m_collection(collection)
{
    setObjectName(name);
    m_timer = new QTimer(this);
    m_timer->setSingleShot(true);
    connect(m_timer, SIGNAL(timeout()),
            this, SLOT(alarmActivated()));

    setAlarm(alarm);
}



AlarmContainer::~AlarmContainer()
{
}

void AlarmContainer::setAlarm(const KAlarmCal::KAEvent &alarm)
{
    m_alarmEvent = alarm;

    setData("id", alarm.itemId());
    setData("time", alarm.firstAlarm().time());
    setData("date", alarm.firstAlarm().date());
    setData("enabled", alarm.enabled());
    setData("message", alarm.message());
    setData("audioFile", alarm.audioFile());
    setData("recurs", alarm.recurs());
    setData("deferMinutes", alarm.deferDefaultMinutes());
    setData("lateCancelMinutes", alarm.lateCancel());

    KDateTime alarmTime(alarm.firstAlarm().date(), alarm.firstAlarm().time());

    //Is the alarm in the past?
    if (alarmTime <= KDateTime::currentLocalDateTime()) {
        //Is this timer to be deleted?
        bool toDelete = true;

        m_timer->stop();

        //Does the alarm have a lateCancel time? is it expired?
        if (alarm.lateCancel() == (uint)0 ||
        (KDateTime::currentLocalDateTime().toTime_t() - alarmTime.toTime_t())/(uint)60 <= (uint)alarm.lateCancel()) {
            //Trigger the alarm
            setData("active", true);
            toDelete = false;
        } else {
            setData("active", false);
        }

        //Is it expired but daily?
        if (alarm.recurrence()->type() == KAlarmCal::KARecurrence::DAILY) {
            KAlarmCal::KAEvent newEvent(m_alarmEvent);
            newEvent.setItemId(m_alarmEvent.itemId());
            Akonadi::Item item(m_alarmEvent.itemId());

            KDateTime dateTime = newEvent.firstAlarm().dateTime().kDateTime();
            newEvent.setTime(dateTime.addDays(1));

            if (!newEvent.setItemPayload(item, m_collection.contentMimeTypes())) {
                kWarning() << "Invalid mime type for collection";
                checkForUpdate();
                return;
            }

            item.setPayload(newEvent);

            new Akonadi::ItemModifyJob(item, this);
            setData("active", false);
            toDelete = false;
        }

        //Kill the expired timer
        if (toDelete) {
            Akonadi::Item item(m_alarmEvent.itemId());

            new Akonadi::ItemDeleteJob(item, this);
            setData("active", false);
        }

    //Is the alarm in the future?
    } else {
        m_timer->start((alarmTime.toTime_t() - KDateTime::currentLocalDateTime().toTime_t()) * 1000);
        setData("active", false);
    }

    checkForUpdate();
}

KAlarmCal::KAEvent AlarmContainer::alarm() const
{
    return m_alarmEvent;
}


void AlarmContainer::alarmActivated()
{
    kDebug() << "Alarm triggered";
    setData("active", true);
    checkForUpdate();
}

#include "alarmcontainer.moc"
