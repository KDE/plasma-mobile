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

    const KDateTime now(KDateTime::currentLocalDateTime());
    const KDateTime startAlarmTime(alarm.startDateTime().kDateTime());

    KAlarmCal::DateTime dt;
    alarm.nextOccurrence(now, dt);

    const KDateTime nextAlarmTime(dt.kDateTime());
    alarm.previousOccurrence(now, dt);
    const KDateTime previousAlarmTime(dt.kDateTime());


    setData("id", alarm.itemId());
    setData("time", nextAlarmTime.time());
    setData("date", nextAlarmTime.date());
    setData("startTime", startAlarmTime.time());
    setData("startDate", startAlarmTime.date());
    setData("enabled", alarm.enabled());
    setData("message", alarm.message());
    setData("audioFile", alarm.audioFile());
    setData("recurs", alarm.recurs());
    setData("deferMinutes", alarm.deferDefaultMinutes());
    setData("lateCancelMinutes", alarm.lateCancel());



    //Is it daily and has been triggered today?
    if (alarm.recurrence() && alarm.recurrence()->type() == KAlarmCal::KARecurrence::DAILY) {
        //has been triggered today?
        if (previousAlarmTime.date() == now.date() &&
            previousAlarmTime.time() <= now.time() &&
            (alarm.lateCancel() == (uint)0 ||
                (now.toTime_t() - nextAlarmTime.toTime_t())/(uint)60 <= (uint)alarm.lateCancel())) {

            setData("active", true);
        } else {
            setData("active", false);
        }
        m_timer->start((nextAlarmTime.toTime_t() - now.toTime_t()) * 1000);

    //Is the alarm in the past?
    } else if (!nextAlarmTime.isValid() || nextAlarmTime <= now) {

        m_timer->stop();

        //Does the alarm have a lateCancel time? is it expired?
        if (alarm.lateCancel() == (uint)0 ||
        (now.toTime_t() - nextAlarmTime.toTime_t())/(uint)60 <= (uint)alarm.lateCancel()) {
            //Trigger the alarm
            setData("active", true);
        } else {
            setData("active", false);
            Akonadi::Item item(m_alarmEvent.itemId());

            //Kill the expired timer
            new Akonadi::ItemDeleteJob(item, this);
        }

    //Is the alarm in the future?
    } else {
        m_timer->start((nextAlarmTime.toTime_t() - now.toTime_t()) * 1000);
        setData("active", false);
    }

    checkForUpdate();
}

KAlarmCal::KAEvent AlarmContainer::alarm() const
{
    return m_alarmEvent;
}

void AlarmContainer::setActive(bool active)
{
    setData("active", active);
    checkForUpdate();
}

bool AlarmContainer::active() const
{
    return data().value("active").toBool();
}

void AlarmContainer::alarmActivated()
{
    kDebug() << "Alarm triggered";

    KAlarmCal::DateTime dt;
    m_alarmEvent.nextOccurrence(KDateTime::currentLocalDateTime(), dt);

    const KDateTime nextAlarmTime(dt.kDateTime());
    setData("time", nextAlarmTime.time());
    setData("date", nextAlarmTime.date());
    setActive(true);
}

#include "alarmcontainer.moc"
