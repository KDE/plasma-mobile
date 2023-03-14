/*

    SPDX-FileCopyrightText: 2005 S.R.Haque <srhaque@iee.org>.
    SPDX-FileCopyrightText: 2009 David Faure <faure@kde.org>
    SPDX-FileCopyrightText: 2011-2015 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2015 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "timesettings.h"
#include "timezonemodel.h"

#include <QDebug>
#include <QtCore/QDate>

#include <QDBusConnection>
#include <QDBusMessage>
#include <QStandardItemModel>
#include <QTimer>
#include <QVariant>

#include <KConfigGroup>
#include <KLocalizedString>
#include <KPluginFactory>
#include <KSharedConfig>
#include <utility>

#include "timedated_interface.h"

#define FORMAT24H "HH:mm:ss"
#define FORMAT12H "h:mm:ss ap"

K_PLUGIN_FACTORY_WITH_JSON(TimeSettingsFactory, "timesettings.json", registerPlugin<TimeSettings>();)

TimeSettings::TimeSettings(QObject *parent, const KPluginMetaData &metaData, const QVariantList &args)
    : KQuickAddons::ConfigModule(parent, metaData, args)
    , m_useNtp(true)
{
    qDebug() << "time settings init";
    m_timeZonesModel = nullptr;
    setTimeZone(QTimeZone::systemTimeZone().id());

    setButtons(Apply | Default);

    qmlRegisterAnonymousType<TimeZoneModel>("org.kde.timesettings", 1);
    qmlRegisterAnonymousType<TimeZoneFilterProxy>("org.kde.timesettings", 1);

    initSettings();
    initTimeZones();
    qDebug() << "TimeSettings module loaded.";
}

TimeSettings::~TimeSettings()
{
}

void TimeSettings::initTimeZones()
{
    auto *filterModel = new TimeZoneFilterProxy(this);
    filterModel->setSourceModel(new TimeZoneModel(filterModel));
    setTimeZonesModel(filterModel);
}

void TimeSettings::initSettings()
{
    m_localeConfig = KSharedConfig::openConfig(QStringLiteral("kdeglobals"), KConfig::SimpleConfig);
    m_localeSettings = KConfigGroup(m_localeConfig, "Locale");

    setTimeFormat(m_localeSettings.readEntry("TimeFormat", QStringLiteral(FORMAT24H))); // FIXME?!

    OrgFreedesktopTimedate1Interface timeDatedIface(QStringLiteral("org.freedesktop.timedate1"),
                                                    QStringLiteral("/org/freedesktop/timedate1"),
                                                    QDBusConnection::systemBus());
    // the server list is not relevant for timesyncd, it fetches it from the network
    m_useNtp = timeDatedIface.nTP();
}

void TimeSettings::timeout()
{
    setCurrentTime(QTime::currentTime());
    setCurrentDate(QDate::currentDate());
    notify();
}

QString TimeSettings::currentTimeText()
{
    return m_currentTimeText;
}

QTime TimeSettings::currentTime() const
{
    return m_currentTime;
}

void TimeSettings::setCurrentTime(const QTime &currentTime)
{
    if (m_currentTime != currentTime) {
        m_currentTime = currentTime;
        m_currentTimeText = QLocale().toString(QTime::currentTime(), m_timeFormat);
        emit currentTimeChanged();
    }
}

QDate TimeSettings::currentDate() const
{
    return m_currentDate;
}

void TimeSettings::setCurrentDate(const QDate &currentDate)
{
    if (m_currentDate != currentDate) {
        m_currentDate = currentDate;
        emit currentDateChanged();
    }
}

bool TimeSettings::useNtp() const
{
    return m_useNtp;
}

void TimeSettings::setUseNtp(bool ntp)
{
    if (m_useNtp != ntp) {
        m_useNtp = ntp;
        saveTime();
        emit useNtpChanged();
    }
}

bool TimeSettings::saveTime()
{
    OrgFreedesktopTimedate1Interface timedateIface(QStringLiteral("org.freedesktop.timedate1"),
                                                   QStringLiteral("/org/freedesktop/timedate1"),
                                                   QDBusConnection::systemBus());

    bool rc = true;
    // final arg in each method is "user-interaction" i.e whether it's OK for polkit to ask for auth

    // we cannot send requests up front then block for all replies as we need NTP to be disabled before we can make a call to SetTime
    // timedated processes these in parallel and will return an error otherwise

    auto reply = timedateIface.SetNTP(m_useNtp, true);
    reply.waitForFinished();
    if (reply.isError()) {
        m_errorString = i18n("Unable to change NTP settings");
        emit errorStringChanged();
        qWarning() << "Failed to enable NTP" << reply.error().name() << reply.error().message();
        rc = false;
    }

    if (!useNtp()) {
        QDateTime userTime;
        userTime.setTime(currentTime());
        userTime.setDate(currentDate());
        qDebug() << "Setting userTime: " << userTime;
        qint64 timeDiff = userTime.toMSecsSinceEpoch() - QDateTime::currentMSecsSinceEpoch();
        //*1000 for milliseconds -> microseconds
        auto reply = timedateIface.SetTime(timeDiff * 1000, true, true);
        reply.waitForFinished();
        if (reply.isError()) {
            m_errorString = i18n("Unable to set current time");
            emit errorStringChanged();
            qWarning() << "Failed to set current time" << reply.error().name() << reply.error().message();
            rc = false;
        }
    }
    saveTimeZone(m_timezone);

    return rc;
}

void TimeSettings::saveTimeZone(const QString &newtimezone)
{
    qDebug() << "Saving timezone to config: " << newtimezone;
    OrgFreedesktopTimedate1Interface timedateIface(QStringLiteral("org.freedesktop.timedate1"),
                                                   QStringLiteral("/org/freedesktop/timedate1"),
                                                   QDBusConnection::systemBus());

    if (!newtimezone.isEmpty()) {
        qDebug() << "Setting timezone: " << newtimezone;
        auto reply = timedateIface.SetTimezone(newtimezone, true);
        reply.waitForFinished();
        if (reply.isError()) {
            m_errorString = i18n("Unable to set timezone");
            emit errorStringChanged();
            qWarning() << "Failed to set timezone" << reply.error().name() << reply.error().message();
        }
    }

    setTimeZone(newtimezone);
    emit timeZoneChanged();
    notify();
}

QString TimeSettings::timeFormat()
{
    return m_timeFormat;
}

void TimeSettings::setTimeFormat(const QString &timeFormat)
{
    if (m_timeFormat != timeFormat) {
        m_timeFormat = timeFormat;

        m_localeSettings.writeEntry("TimeFormat", timeFormat, KConfigGroup::Notify);
        m_localeConfig->sync();

        QDBusMessage msg =
            QDBusMessage::createSignal(QStringLiteral("/org/kde/kcmshell_clock"), QStringLiteral("org.kde.kcmshell_clock"), QStringLiteral("clockUpdated"));
        QDBusConnection::sessionBus().send(msg);

        qDebug() << "time format is now: " << QLocale().toString(QTime::currentTime(), m_timeFormat);
        emit timeFormatChanged();
        timeout();
    }
}

QString TimeSettings::timeZone()
{
    return m_timezone;
}

void TimeSettings::setTimeZone(const QString &timezone)
{
    if (m_timezone != timezone) {
        m_timezone = timezone;
        qDebug() << "timezone changed to: " << timezone;
        emit timeZoneChanged();
        timeout();
    }
}

TimeZoneFilterProxy *TimeSettings::timeZonesModel()
{
    return m_timeZonesModel;
}

void TimeSettings::setTimeZonesModel(TimeZoneFilterProxy *timezones)
{
    m_timeZonesModel = timezones;
    emit timeZonesModelChanged();
}

bool TimeSettings::twentyFour()
{
    return timeFormat() == QStringLiteral(FORMAT24H);
}

void TimeSettings::setTwentyFour(bool t)
{
    if (twentyFour() != t) {
        if (t) {
            setTimeFormat(FORMAT24H);
        } else {
            setTimeFormat(FORMAT12H);
        }
        qDebug() << "T24 toggled: " << t << m_timeFormat;
        emit twentyFourChanged();
        emit currentTimeChanged();
        timeout();
    }
}

QString TimeSettings::errorString()
{
    return m_errorString;
}

void TimeSettings::notify()
{
    const QDBusMessage msg =
        QDBusMessage::createSignal(QStringLiteral("/org/kde/kcmshell_clock"), QStringLiteral("org.kde.kcmshell_clock"), QStringLiteral("clockUpdated"));
    QDBusConnection::sessionBus().send(msg);
}

#include "timesettings.moc"
