// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QProcess>

#include "timezonemodel.h"

class TimeUtil : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool is24HourTime READ is24HourTime WRITE setIs24HourTime NOTIFY is24HourTimeChanged);
    Q_PROPERTY(QString currentTimeZone READ currentTimeZone WRITE setCurrentTimeZone NOTIFY currentTimeZoneChanged);
    Q_PROPERTY(TimeZoneFilterProxy *timeZones READ timeZones CONSTANT);

public:
    TimeUtil(QObject *parent = nullptr);

    bool is24HourTime() const;
    void setIs24HourTime(bool is24HourTime);

    QString currentTimeZone() const;
    void setCurrentTimeZone(QString timeZone);

    TimeZoneFilterProxy *timeZones() const;

Q_SIGNALS:
    void is24HourTimeChanged();
    void currentTimeZoneChanged();

private:
    bool m_is24HourTime;

    TimeZoneModel *m_timeZoneModel;
    TimeZoneFilterProxy *m_filterModel;
};
