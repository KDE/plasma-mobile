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

#include <QCoroDBus>
#include <QCoroTask>

#define FORMAT24H "HH:mm:ss"
#define FORMAT12H "h:mm:ss ap"

K_PLUGIN_CLASS_WITH_JSON(TimeSettings, "kcm_mobile_time.json")

TimeSettings::TimeSettings(QObject *parent, const KPluginMetaData &metaData)
    : KQuickConfigModule(parent, metaData)
    , m_useNtp(true)
    , m_localeConfig{KSharedConfig::openConfig(QStringLiteral("kdeglobals"), KConfig::SimpleConfig)}
    , m_localeSettings{KConfigGroup(m_localeConfig, "Locale")}
    , m_timedateIface{std::make_shared<OrgFreedesktopTimedate1Interface>(QStringLiteral("org.freedesktop.timedate1"),
                                                                         QStringLiteral("/org/freedesktop/timedate1"),
                                                                         QDBusConnection::systemBus())}
{
    setButtons({});

    m_timeZonesModel = nullptr;
    setTimeZone(QTimeZone::systemTimeZone().id());

    qmlRegisterAnonymousType<TimeZoneModel>("org.kde.timesettings", 1);
    qmlRegisterAnonymousType<TimeZoneFilterProxy>("org.kde.timesettings", 1);

    m_useNtp = m_timedateIface->nTP();
    setTimeFormat(m_localeSettings.readEntry("TimeFormat", QStringLiteral(FORMAT24H))); // FIXME?!
    initTimeZones();

    qDebug() << "TimeSettings module loaded.";
}

void TimeSettings::initTimeZones()
{
    auto *filterModel = new TimeZoneFilterProxy(this);
    filterModel->setSourceModel(new TimeZoneModel(filterModel));
    setTimeZonesModel(filterModel);
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
    if (m_currentTime == currentTime) {
        return;
    }

    m_currentTime = currentTime;
    m_currentTimeText = QLocale().toString(QTime::currentTime(), m_timeFormat);
    Q_EMIT currentTimeChanged();
}

QDate TimeSettings::currentDate() const
{
    return m_currentDate;
}

void TimeSettings::setCurrentDate(const QDate &currentDate)
{
    if (m_currentDate == currentDate) {
        return;
    }

    m_currentDate = currentDate;
    Q_EMIT currentDateChanged();
}

bool TimeSettings::useNtp() const
{
    return m_useNtp;
}

void TimeSettings::setUseNtp(bool ntp)
{
    if (m_useNtp == ntp) {
        return;
    }

    auto reply = m_timedateIface->SetNTP(ntp, true);
    auto r = reply;
    QCoro::connect(std::move(reply), this, [=, this]() {
        if (r.isError()) {
            m_errorString = i18n("Unable to change NTP settings");
            Q_EMIT errorStringChanged();
            qWarning() << "Failed to enable NTP" << r.error().name() << r.error().message();
        }

        m_useNtp = m_timedateIface->nTP();
        Q_EMIT useNtpChanged();
    });
}

void TimeSettings::saveTime()
{
    if (useNtp()) {
        return;
    }

    QDateTime userTime;
    userTime.setTime(currentTime());
    userTime.setDate(currentDate());
    qDebug() << "Setting userTime: " << userTime;
    qint64 timeDiff = userTime.toMSecsSinceEpoch() - QDateTime::currentMSecsSinceEpoch();

    //*1000 for milliseconds -> microseconds
    auto reply = m_timedateIface->SetTime(timeDiff * 1000, true, true);
    auto r = reply;
    QCoro::connect(std::move(reply), this, [=, this]() {
        if (r.isError()) {
            m_errorString = i18n("Unable to set current time");
            Q_EMIT errorStringChanged();
            qWarning() << "Failed to set current time" << r.error().name() << r.error().message();
        }
    });
}

void TimeSettings::saveTimeZone(const QString &newtimezone)
{
    qDebug() << "Saving timezone to config: " << newtimezone;

    if (newtimezone.isEmpty()) {
        return;
    }

    qDebug() << "Setting timezone: " << newtimezone;
    auto reply = m_timedateIface->SetTimezone(newtimezone, true);
    auto r = reply;
    QCoro::connect(std::move(reply), this, [=, this]() {
        if (r.isError()) {
            m_errorString = i18n("Unable to set timezone");
            Q_EMIT errorStringChanged();
            qWarning() << "Failed to set timezone" << r.error().name() << r.error().message();
        } else {
            setTimeZone(newtimezone);
            Q_EMIT timeZoneChanged();
            notify();
        }
    });
}

QString TimeSettings::timeFormat()
{
    return m_timeFormat;
}

void TimeSettings::setTimeFormat(const QString &timeFormat)
{
    if (m_timeFormat == timeFormat) {
        return;
    }

    m_timeFormat = timeFormat;

    m_localeSettings.writeEntry("TimeFormat", timeFormat, KConfigGroup::Notify);
    m_localeConfig->sync();

    QDBusMessage msg =
        QDBusMessage::createSignal(QStringLiteral("/org/kde/kcmshell_clock"), QStringLiteral("org.kde.kcmshell_clock"), QStringLiteral("clockUpdated"));
    QDBusConnection::sessionBus().send(msg);

    qDebug() << "time format is now: " << QLocale().toString(QTime::currentTime(), m_timeFormat);
    Q_EMIT timeFormatChanged();
    timeout();
}

QString TimeSettings::timeZone()
{
    return m_timezone;
}

void TimeSettings::setTimeZone(const QString &timezone)
{
    if (m_timezone == timezone) {
        return;
    }

    m_timezone = timezone;
    qDebug() << "timezone changed to: " << timezone;
    Q_EMIT timeZoneChanged();
    timeout();
}

TimeZoneFilterProxy *TimeSettings::timeZonesModel()
{
    return m_timeZonesModel;
}

void TimeSettings::setTimeZonesModel(TimeZoneFilterProxy *timezones)
{
    m_timeZonesModel = timezones;
    Q_EMIT timeZonesModelChanged();
}

bool TimeSettings::twentyFour()
{
    return timeFormat() == QStringLiteral(FORMAT24H);
}

void TimeSettings::setTwentyFour(bool t)
{
    if (twentyFour() == t) {
        return;
    }

    if (t) {
        setTimeFormat(FORMAT24H);
    } else {
        setTimeFormat(FORMAT12H);
    }
    qDebug() << "T24 toggled: " << t << m_timeFormat;
    Q_EMIT twentyFourChanged();
    Q_EMIT currentTimeChanged();
    timeout();
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
