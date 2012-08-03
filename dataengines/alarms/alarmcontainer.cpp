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



AlarmContainer::AlarmContainer(const QString &name,
                               const KAlarmCal::KAEvent &alarm,
                               QObject *parent)
    : Plasma::DataContainer(parent),
      m_alarmEvent(alarm)
{
    setObjectName(name);
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
    setData("enabled", alarm.enabled());
    setData("message", alarm.message());
    setData("audioFile", alarm.audioFile());
    setData("recurs", alarm.recurs());
    
}

KAlarmCal::KAEvent AlarmContainer::alarm() const
{
    return m_alarmEvent;
}

#include "alarmcontainer.moc"
