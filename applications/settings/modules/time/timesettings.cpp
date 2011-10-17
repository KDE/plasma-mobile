/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "timesettings.h"

#include <kdebug.h>
#include <KIcon>
#include <KLocale>

#include <QTimer>
#include <QVariant>

#include <kdemacros.h>
#include <KPluginFactory>
#include <KPluginLoader>
#include <KSharedConfig>
#include <KConfigGroup>


#include <QtDeclarative/qdeclarative.h>
#include <QtCore/QDate>

K_PLUGIN_FACTORY(TimeSettingsFactory, registerPlugin<TimeSettings>();)
K_EXPORT_PLUGIN(TimeSettingsFactory("active_settings_time"))

#define FORMAT24H "%H:%M:%S"
#define FORMAT12H "%l:%M:%S %p"

class TimeSettingsPrivate {
public:
    QString timeFormat;
    QString timezone;
    QString currentTime;
    QTimer *timer;

    KSharedConfigPtr localeConfig;
    KConfigGroup localeSettings;
};

TimeSettings::TimeSettings(QObject *parent, const QVariantList &list)
    : SettingsModule(parent, list)
{
    qmlRegisterType<TimeSettings>();
    qmlRegisterType<TimeSettings>("org.kde.active.settings", 0, 1, "TimeSettings");
}

TimeSettings::TimeSettings()
{
    d = new TimeSettingsPrivate;
    setModule("org.kde.active.settings.time");
    init();

    // Just for testing that data gets through
    d->timer = new QTimer(this);
    d->timer->setInterval(1000);
    connect(d->timer, SIGNAL(timeout()), SLOT(timeout()));
    d->timer->start();

    d->localeConfig = KSharedConfig::openConfig("kcmlocale-default", KConfig::SimpleConfig);
    d->localeSettings = KConfigGroup(d->localeConfig, "Locale");
    //setTimeFormat(d->localeSettings.readEntry("TimeFormat", QString(FORMAT24H)));
    setTimeFormat(d->localeSettings.readEntry("TimeFormat", QString(FORMAT12H)));
    kDebug() << "TimeSettings plugin loaded.";
}

TimeSettings::~TimeSettings()
{
    //kDebug() << "time destroy";
    delete d;
}

void TimeSettings::timeout()
{
    setCurrentTime(KGlobal::locale()->formatTime(QTime::currentTime(), true));
}


QString TimeSettings::currentTime()
{
    return d->currentTime;
}

void TimeSettings::setCurrentTime(const QString &currentTime)
{
    if (d->currentTime != currentTime) {
        d->currentTime = currentTime;
        emit currentTimeChanged();
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
        KGlobal::locale()->setTimeFormat(d->timeFormat);
        kDebug() << "TIME" << KGlobal::locale()->formatTime(QTime::currentTime(), false);
        emit timeFormatChanged();
        timeout();
    }
}

QString TimeSettings::timezone()
{
    return d->timezone;
}

void TimeSettings::setTimezone(const QString &timezone)
{
    if (d->timezone != timezone) {
        d->timezone = timezone;
        emit timezoneChanged();
        timeout();
    }
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
