/*
    Copyright 2005 S.R.Haque <srhaque@iee.org>.
    Copyright 2009 David Faure <faure@kde.org>
    Copyright 2011 Sebastian Kügler <sebas@kde.org>

    This file is part of the KDE project

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License version 2, as published by the Free Software Foundation.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#include "timesettings.h"
#include "timezone.h"
#include "timezonesmodel.h"

#include <kdebug.h>
#include <KIcon>
#include <KLocale>

#include <QStandardItemModel>
#include <QTimer>
#include <QVariant>

#include <kauthaction.h>
#include <kdemacros.h>
#include <KPluginFactory>
#include <KPluginLoader>
#include <KSharedConfig>
#include <KStandardDirs>
#include <KConfigGroup>
#include <KGlobalSettings>
#include <KSystemTimeZone>
#include <KTimeZone>

#include <QtDeclarative/qdeclarative.h>
#include <QtDeclarative/QDeclarativeItem>
#include <QtCore/QDate>

#define FORMAT24H "%H:%M:%S"
#define FORMAT12H "%l:%M:%S %p"

class TimeSettingsPrivate {
public:
    TimeSettings *q;
    QString timeFormat;
    QString timezone;
    QObject *timeZonesModel;
    QString timeZoneFilter;
    QString currentTimeText;
    QTime currentTime;
    QDate currentDate;
    QTimer *timer;
    QString ntpServer;

    void initSettings();
    void initTimeZones();
    QString displayName(const KTimeZone &zone);


    KSharedConfigPtr localeConfig;
    KConfigGroup localeSettings;
    KTimeZones *timeZones;
    QList<QObject*> timezones;
};

TimeSettings::TimeSettings()
{
    d = new TimeSettingsPrivate;
    d->q = this;
    d->timeZones = 0;
    d->timeZonesModel = 0;
    setTimeZone(KSystemTimeZones::local().name());

    d->initSettings();

    // Just for testing that data gets through
    d->timer = new QTimer(this);
    d->timer->setInterval(1000);
    connect(d->timer, SIGNAL(timeout()), SLOT(timeout()));
    d->timer->start();

    kDebug() << "TimeSettings module loaded.";
}

TimeSettings::~TimeSettings()
{
    kDebug() << "========================== timesettings destroy";
    delete d;
}

void TimeSettingsPrivate::initTimeZones()
{
    // Collect zones by localized city names, so that they can be sorted properly.
    QStringList cities;
    QStringList tz;
    QHash<QString, KTimeZone> zonesByCity;

    if (!timeZones) {
        timeZones = KSystemTimeZones::timeZones();

        // add UTC to the defaults default
        KTimeZone utc = KTimeZone::utc();
        cities.append(utc.name());
        zonesByCity.insert(utc.name(), utc);
    }
    //kDebug() << " TZ: cities: " << cities;

    const KTimeZones::ZoneMap zones = timeZones->zones();

    QList<QObject*> _zones;
    QStandardItemModel *_zonesModel = new TimeZonesModel(q);

    for ( KTimeZones::ZoneMap::ConstIterator it = zones.begin(); it != zones.end(); ++it ) {
        const KTimeZone zone = it.value();
        if (timeZoneFilter.isEmpty() || zone.name().contains(timeZoneFilter, Qt::CaseInsensitive)) {
            TimeZone *_zone = new TimeZone(zone);
            _zones.append(_zone);
            QStandardItem *item = new QStandardItem(_zone->name());
            item->setData(_zone->name().split("/").first(), Qt::UserRole+1);
            _zonesModel->appendRow(item);
        }
    }
    kDebug() << "Found: " << _zones.count() << " timezones.";
    //qSort( cities.begin(), cities.end(), localeLessThan );
    q->setTimeZones(_zones);
    q->setTimeZonesModel(_zonesModel);
}

QString TimeSettingsPrivate::displayName( const KTimeZone &zone )
{
    return i18n( zone.name().toUtf8() ).replace( '_', ' ' );
}

void TimeSettingsPrivate::initSettings()
{
    localeConfig = KSharedConfig::openConfig("kdeglobals", KConfig::SimpleConfig);
    localeSettings = KConfigGroup(localeConfig, "Locale");

    //setTimeFormat(d->localeSettings.readEntry("TimeFormat", QString(FORMAT24H)));
    //setTimeFormat(d->localeSettings.readEntry("TimeFormat", QString(FORMAT12H)));
    q->setTimeFormat( localeSettings.readEntry( "TimeFormat", QString() ) );

    KConfig _config( "kcmclockrc", KConfig::NoGlobals );
    KConfigGroup config(&_config, "NTP");
    QStringList servers = config.readEntry("servers",
        QString()).split(',', QString::SkipEmptyParts);
    if (!servers.isEmpty()) {
        ntpServer = servers.first();
    }
    //FIXME: why?
    if (ntpServer.length() < 3) {
        ntpServer = QString();
    }
}


void TimeSettings::timeout()
{
    setCurrentTime(QTime::currentTime());
    setCurrentDate(QDate::currentDate());
}


QString TimeSettings::currentTimeText()
{
    return d->currentTimeText;
}

QTime TimeSettings::currentTime() const
{
    return d->currentTime;
}

void TimeSettings::setCurrentTime(const QTime &currentTime)
{
    if (d->currentTime != currentTime) {
        d->currentTime = currentTime;
        d->currentTimeText = KGlobal::locale()->formatTime(QTime::currentTime(), true);
        emit currentTimeChanged();
    }
}

QDate TimeSettings::currentDate() const
{
    return d->currentDate;
}

void TimeSettings::setCurrentDate(const QDate &currentDate)
{
    if (d->currentDate != currentDate) {
        d->currentDate = currentDate;
        emit currentDateChanged();
    }
}

QString TimeSettings::ntpServer() const
{
    return d->ntpServer;
}

void TimeSettings::setNtpServer(const QString &server)
{
    if (d->ntpServer != server) {
        d->ntpServer = server;
        emit ntpServerChanged();
    }
}

QStringList TimeSettings::availableNtpServers() const
{
    QStringList servers;
    servers << "pool.ntp.org" << "asia.pool.ntp.org" << "europe.pool.ntp.org" << "north-america.pool.ntp.org" << "oceania.pool.ntp.org";
    return servers;
}

QString TimeSettings::findNtpUtility()
{
    QByteArray envpath = qgetenv("PATH");
    if (!envpath.isEmpty() && envpath[0] == ':') {
        envpath = envpath.mid(1);
    }

    QString path = "/sbin:/usr/sbin:";
    if (!envpath.isEmpty()) {
        path += QString::fromLocal8Bit(envpath);
    } else {
        path += QLatin1String("/bin:/usr/bin");
    }

    QString ntpUtility;
    foreach (const QString &possible_ntputility, QStringList() << "ntpdate" << "rdate" ) {
        if (!((ntpUtility = KStandardDirs::findExe(possible_ntputility, path)).isEmpty())) {
        kDebug() << "ntpUtility = " << ntpUtility;
        return ntpUtility;
        }
    }

    kDebug() << "ntpUtility not found!";
    return QString();
}

void TimeSettings::saveTime()
{
    QVariantMap helperargs;


    //TODO: enable NTP
    // Save the order, but don't duplicate!
    QStringList list;
    list << d->ntpServer;
    helperargs["ntp"] = true;
    helperargs["ntpServers"] = list;
    helperargs["ntpEnabled"] = !d->ntpServer.isEmpty();
    QString ntpUtility = findNtpUtility();
    helperargs["ntpUtility"] = ntpUtility;

    if (!d->ntpServer.isEmpty() && !ntpUtility.isEmpty()) {
        // NTP Time setting - done in helper
        kDebug() << "Setting date from time server " << list;
    } else {
        // User time setting
        QDateTime dt(d->currentDate, d->currentTime);

        kDebug() << "Set date " << dt;

        helperargs["date"] = true;
        helperargs["newdate"] = QString::number(dt.toTime_t());
        helperargs["olddate"] = QString::number(::time(0));
    }

    /*TODO: enable timeZones
    QStringList selectedZones(tzonelist->selection());

    if (selectedZones.count() > 0) {
        QString selectedzone(selectedZones[0]);
        helperargs["tz"] = true;
        helperargs["tzone"] = selectedzone;
    } else {
        helperargs["tzreset"] = true; // // make the helper reset the timezone
    }*/

    KAuth::Action writeAction("org.kde.active.clockconfig.save");
    writeAction.setHelperID("org.kde.active.clockconfig");
    writeAction.setArguments(helperargs);

    KAuth::ActionReply reply = writeAction.execute();
    if (reply.failed()) {
        kWarning()<< "KAuth returned an error code:" << reply.errorCode();
    }
}

QString TimeSettings::timeFormat()
{
    return d->timeFormat;
}

void TimeSettings::setTimeFormat(const QString &timeFormat)
{
    if (d->timeFormat != timeFormat) {
        d->timeFormat = timeFormat;

        d->localeSettings.writeEntry("TimeFormat", timeFormat);
        d->localeConfig->sync();

        KGlobal::locale()->setTimeFormat(d->timeFormat);
        KGlobalSettings::self()->emitChange(KGlobalSettings::SettingsChanged, KGlobalSettings::SETTINGS_LOCALE);
        kDebug() << "TIME" << KGlobal::locale()->formatTime(QTime::currentTime(), false);
        emit timeFormatChanged();
        timeout();
    }
}

QString TimeSettings::timeZone()
{
    return d->timezone;
}

void TimeSettings::setTimeZone(const QString &timezone)
{
    if (d->timezone != timezone) {
        d->timezone = timezone;
        kDebug() << "booyah";
        emit timeZoneChanged();
        timeout();
    }
}

QList<QObject*> TimeSettings::timeZones()
{
    if (!d->timeZones) {
        d->initTimeZones();
    }
    return d->timezones;
}

void TimeSettings::setTimeZones(QList<QObject*> timezones)
{
    //if (d->timezones != timezones) {
        d->timezones = timezones;
        emit timeZonesChanged();
    //}
}

QObject* TimeSettings::timeZonesModel()
{
    if (!d->timeZones) {
        d->initTimeZones();
    }
    return d->timeZonesModel;
}

void TimeSettings::setTimeZonesModel(QObject* timezones)
{
    //if (d->timezones != timezones) {
        d->timeZonesModel = timezones;
        emit timeZonesModelChanged();
    //}
}

void TimeSettings::timeZoneFilterChanged(const QString &filter)
{
    kDebug() << "new filter: " << filter;
    d->timeZoneFilter = filter;
    d->timeZoneFilter.replace( ' ', '_' );
    d->initTimeZones();
    emit timeZonesChanged();
}

void TimeSettings::saveTimeZone(const QString &newtimezone)
{
    kDebug() << "Saving timezone to config: " << newtimezone;

    QVariantMap helperargs;
    helperargs["tz"] = true;
    helperargs["tzone"] = newtimezone;

    KAuth::Action writeAction("org.kde.active.clockconfig.save");
    writeAction.setHelperID("org.kde.active.clockconfig");
    writeAction.setArguments(helperargs);

    KAuth::ActionReply reply = writeAction.execute();
    if (reply.failed()) {
        kWarning()<< "KAuth returned an error code:" << reply.errorCode();
    }

    setTimeZone(newtimezone);
    emit timeZoneChanged();
}

bool TimeSettings::twentyFour()
{
    return timeFormat() == FORMAT24H;
}

void TimeSettings::setTwentyFour(bool t)
{
    if (twentyFour() != t) {
        if (t) {
            setTimeFormat(FORMAT24H);
        } else {
            setTimeFormat(FORMAT12H);
        }
        kDebug() << "T24 toggled: " << t << d->timeFormat;
        emit twentyFourChanged();
        emit currentTimeChanged();
        timeout();
    }
}


#include "timesettings.moc"
