// SPDX-FileCopyrightText: 2023 by Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "timeutil.h"

#include <QDebug>
#include <QRegularExpression>
#include <QTimeZone>

#include <KConfigGroup>
#include <KSharedConfig>

#define FORMAT24H "HH:mm:ss"
#define FORMAT12H "h:mm:ss ap"

TimeUtil::TimeUtil(QObject *parent)
    : QObject{parent}
    , m_timeZoneModel{new TimeZoneModel{this}}
    , m_filterModel{new TimeZoneFilterProxy{this}}
{
    m_filterModel->setSourceModel(m_timeZoneModel);

    // retrieve is24HourTime
    auto config = KSharedConfig::openConfig(QStringLiteral("kdeglobals"), KConfig::SimpleConfig);
    auto group = KConfigGroup(config, "Locale");
    m_is24HourTime = group.readEntry(QStringLiteral("TimeFormat"), FORMAT24H) == FORMAT24H;
}

bool TimeUtil::is24HourTime() const
{
    return m_is24HourTime;
}

void TimeUtil::setIs24HourTime(bool is24HourTime)
{
    if (is24HourTime != m_is24HourTime) {
        auto config = KSharedConfig::openConfig(QStringLiteral("kdeglobals"), KConfig::SimpleConfig);
        auto group = KConfigGroup(config, "Locale");
        group.writeEntry(QStringLiteral("TimeFormat"), is24HourTime ? FORMAT24H : FORMAT12H, KConfig::Notify);
        config->sync();

        m_is24HourTime = is24HourTime;
        Q_EMIT is24HourTimeChanged();
    }
}

QString TimeUtil::currentTimeZone() const
{
    return QString{QTimeZone::systemTimeZoneId()};
}

void TimeUtil::setCurrentTimeZone(QString timeZone)
{
    QProcess::execute("timedatectl", {"set-timezone", timeZone});
    Q_EMIT currentTimeZoneChanged();
}

TimeZoneFilterProxy *TimeUtil::timeZones() const
{
    return m_filterModel;
}
