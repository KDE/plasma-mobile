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

#include <kdebug.h>
#include <KIcon>
#include <KLocale>

#include <QStringListModel>
#include <QTimer>
#include <QVariant>

#include <kauthaction.h>
#include <kdemacros.h>
#include <KPluginFactory>
#include <KPluginLoader>
#include <KSharedConfig>
#include <KStandardDirs>
#include <KConfigGroup>
#include <KSystemTimeZone>
#include <KTimeZone>

#include <QtDeclarative/qdeclarative.h>
#include <QtDeclarative/QDeclarativeItem>
#include <QtCore/QDate>

K_PLUGIN_FACTORY(TimeSettingsFactory, registerPlugin<TimeSettings>();)
K_EXPORT_PLUGIN(TimeSettingsFactory("active_settings_time"))

#define FORMAT24H "%H:%M:%S"
#define FORMAT12H "%l:%M:%S %p"

// static bool localeLessThan (const QString &a, const QString &b)
// {
//     return QString::localeAwareCompare(a, b) < 0;
// }

class TimeSettingsPrivate {
public:
    TimeSettings *q;
    QString timeFormat;
    QString timezone;
    QObject *timeZonesModel;
    QString timeZoneFilter;
    QString currentTimeText;
    QTime currentTime;
    QTimer *timer;

    void initSettings();
    void initTimeZones();
    QString displayName(const KTimeZone &zone);


    KSharedConfigPtr localeConfig;
    KConfigGroup localeSettings;
    KTimeZones *timeZones;
    QList<QObject*> timezones;
};

TimeSettings::TimeSettings(QObject *parent, const QVariantList &list)
    : SettingsModule(parent, list)
{
    qmlRegisterType<TimeSettings>();
    qmlRegisterType<TimeZone>();
    qmlRegisterType<TimeSettings>("org.kde.active.settings", 0, 1, "TimeSettings");
}

TimeSettings::TimeSettings()
{
    d = new TimeSettingsPrivate;
    d->q = this;
    d->timeZones = 0;
    d->timeZonesModel = 0;
    setTimeZone(KSystemTimeZones::local().name());

    d->initSettings();
    //d->initTimeZones();
    setModule("org.kde.active.settings.time");
    init();

    // Just for testing that data gets through
    d->timer = new QTimer(this);
    d->timer->setInterval(1000);
    connect(d->timer, SIGNAL(timeout()), SLOT(timeout()));
    d->timer->start();

    kDebug() << "TimeSettings module loaded.";
}

TimeSettings::~TimeSettings()
{
    kDebug() << "time destroy";
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
    QStringList _zonesList;
    for ( KTimeZones::ZoneMap::ConstIterator it = zones.begin(); it != zones.end(); ++it ) {
        const KTimeZone zone = it.value();
        if (timeZoneFilter.isEmpty() || zone.name().contains(timeZoneFilter, Qt::CaseInsensitive)) {
            TimeZone *_zone = new TimeZone(zone);
            _zones.append(_zone);
            _zonesList << _zone->name();
        }
    }
    kDebug() << "Found: " << _zones.count() << " timezones.";
    //qSort( cities.begin(), cities.end(), localeLessThan );
    q->setTimeZones(_zones);
    q->setTimeZonesModel(new QStringListModel(_zonesList, q));
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

}


void TimeSettings::timeout()
{
    setCurrentTime(QTime::currentTime());
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

void TimeSettings::saveTime()
{
    QVariantMap helperargs;


    //TODO: enable NTP
    // Save the order, but don't duplicate!
    /*QStringList list;
    if (timeServerList->count() != 0) {
        list.append(timeServerList->currentText());
    for (int i=0; i<timeServerList->count();i++) {
        QString text = timeServerList->itemText(i);
        if( !list.contains(text) )
        list.append(text);
        // Limit so errors can go away and not stored forever
        if( list.count() == 10)
        break;
    }

    helperargs["ntp"] = true;
    helperargs["ntpServers"] = list;
    helperargs["ntpEnabled"] = setDateTimeAuto->isChecked();
    helperargs["ntpUtility"] = ntpUtility;

    if (setDateTimeAuto->isChecked() && !ntpUtility.isEmpty()) {
        // NTP Time setting - done in helper
        timeServer = timeServerList->currentText();
        kDebug() << "Setting date from time server " << timeServer;
    } else*/ {
        // User time setting
        QDateTime dt(QDate::currentDate(), d->currentTime);

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
    kDebug() << "TODO: saving timezone to config: " << newtimezone;
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
