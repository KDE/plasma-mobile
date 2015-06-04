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

#include <QDebug>
#include <KIcon>
#include <KLocale>

#include <QStandardItemModel>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QTimer>
#include <QVariant>

#include <kauthaction.h>

#include <kauthexecutejob.h>

#include <kdemacros.h>
#include <KAboutData>
#include <KPluginFactory>
#include <KPluginLoader>
#include <KSharedConfig>
#include <KStandardDirs>
#include <KConfigGroup>
#include <KGlobalSettings>
#include <KGlobal>
#include <KSystemTimeZone>
#include <KTimeZone>

#include <QtCore/QDate>

#define FORMAT24H "HH:mm:ss"
#define FORMAT12H "h:mm:ss ap"

K_PLUGIN_FACTORY_WITH_JSON(TimeSettingsFactory, "metadata.json", registerPlugin<TimeSettings>();)


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

TimeSettings::TimeSettings(QObject* parent, const QVariantList& args)
    : KQuickAddons::ConfigModule(parent, args)
{
    qDebug() << "time settings init";
    d = new TimeSettingsPrivate;
    d->q = this;
    d->timeZones = 0;
    d->timeZonesModel = 0;
    setTimeZone(KSystemTimeZones::local().name());

    KAboutData* about = new KAboutData("kcm_mobile_time", i18n("Configure Date and Time"),
                                       "0.1", QString(), KAboutLicense::LGPL);
    about->addAuthor(i18n("Sebastian Kügler"), QString(), "sebas@kde.org");
    setAboutData(about);
    setButtons(Apply | Default);

    d->initSettings();

    // Just for testing that data gets through
    d->timer = new QTimer(this);
    d->timer->setInterval(1000);
    connect(d->timer, &QTimer::timeout, this, &TimeSettings::timeout);
    d->timer->start();

    qDebug() << "TimeSettings module loaded.";
}

TimeSettings::~TimeSettings()
{
    qDebug() << "========================== timesettings destroy";
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
    //qDebug() << " TZ: cities: " << cities;

    const KTimeZones::ZoneMap zones = timeZones->zones();

    QList<QObject*> _zones;
    QStandardItemModel *_zonesModel = new TimeZonesModel(q);

    for ( KTimeZones::ZoneMap::ConstIterator it = zones.begin(); it != zones.end(); ++it ) {
        const KTimeZone zone = it.value();
        if (timeZoneFilter.isEmpty() || zone.name().contains(timeZoneFilter, Qt::CaseInsensitive)) {
            TimeZone *_zone = new TimeZone(zone);
            _zones.append(_zone);
            QStandardItem *item = new QStandardItem(_zone->name());
            item->setData(_zone->name().split('/').first(), Qt::UserRole+1);
            _zonesModel->appendRow(item);
        }
    }
    qDebug() << "Found: " << _zones.count() << " timezones.";
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
    q->setTimeFormat( localeSettings.readEntry( "TimeFormat", QString() ) ); // FIXME?!

    KConfig _config( "kcmclockrc", KConfig::NoGlobals );
    KConfigGroup config(&_config, "NTP");
    QStringList servers = config.readEntry("servers",
        QString()).split(',', QString::SkipEmptyParts);
    if (!servers.isEmpty()) {
        ntpServer = servers.first();
    }
    //FIXME: why?
    if (ntpServer.length() < 3) {
        ntpServer.clear();
    }
}


void TimeSettings::timeout()
{
    qDebug() << "timeout";
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
        d->currentTimeText = QLocale().toString(QTime::currentTime(), d->timeFormat);
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
        qDebug() << "ntpUtility = " << ntpUtility;
        return ntpUtility;
        }
    }

    qDebug() << "ntpUtility not found!";
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

    if (!d->ntpServer.isEmpty()) {
        // NTP Time setting - done in helper
        qDebug() << "Setting date from time server " << list;
    } else {
        // User time setting
        QDateTime dt(d->currentDate, d->currentTime);

        qDebug() << "Set date " << dt;

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
    writeAction.setHelperId("org.kde.active.clockconfig");
    writeAction.setArguments(helperargs);

    auto job = writeAction.execute();
    if (!job->exec()) {
        qWarning()<< "KAuth returned an error code:" << job->errorString();
    }
}

QString TimeSettings::timeFormat()
{
    return d->timeFormat;
}

void TimeSettings::setTimeFormat(const QString &timeFormat)
{
    qDebug() << "setTimeFormat: " << timeFormat;
    if (d->timeFormat != timeFormat) {
        d->timeFormat = timeFormat;

        d->localeSettings.writeEntry("TimeFormat", timeFormat);
        d->localeConfig->sync();

        QDBusMessage msg = QDBusMessage::createSignal("/org/kde/kcmshell_clock", "org.kde.kcmshell_clock", "clockUpdated");
        QDBusConnection::sessionBus().send(msg);

        qDebug() << "TIME" << QLocale().toString(QTime::currentTime(), d->timeFormat);
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
        qDebug() << "booyah";
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
    qDebug() << "new filter: " << filter;
    d->timeZoneFilter = filter;
    d->timeZoneFilter.replace( ' ', '_' );
    d->initTimeZones();
    emit timeZonesChanged();
}

void TimeSettings::saveTimeZone(const QString &newtimezone)
{
    qDebug() << "Saving timezone to config: " << newtimezone;

    QVariantMap helperargs;
    helperargs["tz"] = true;
    helperargs["tzone"] = newtimezone;

    KAuth::Action writeAction("org.kde.active.clockconfig.save");
    writeAction.setHelperId("org.kde.active.clockconfig");
    writeAction.setArguments(helperargs);

    auto job = writeAction.execute();
    if (!job->exec()) {
        qWarning()<< "KAuth returned an error code:" << job->errorString();
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
        qDebug() << "T24 toggled: " << t << d->timeFormat;
        emit twentyFourChanged();
        emit currentTimeChanged();
        timeout();
    }
}


#include "timesettings.moc"
