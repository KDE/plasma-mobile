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

#include <QtDeclarative/qdeclarative.h>
#include <QtCore/QDate>

K_PLUGIN_FACTORY(TimeSettingsFactory, registerPlugin<TimeSettings>();)
K_EXPORT_PLUGIN(TimeSettingsFactory("active_settings_time"))

class TimeSettingsPrivate {
public:
    QString timezone;
    QString currentTime;
    QTimer *timer;
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
    //d->module = "org.kde.active.settings.time"
    init();

    // Just for testing that data gets through
    d->timer = new QTimer(this);
    d->timer->setInterval(1000);
    connect(d->timer, SIGNAL(timeout()), SLOT(timeout()));
    d->timer->start();
}

TimeSettings::~TimeSettings()
{
    kDebug() << "time destroy";
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

QString TimeSettings::timezone()
{
    return d->timezone;
}


void TimeSettings::setCurrentTime(const QString &currentTime)
{
    if (d->currentTime != currentTime) {
        d->currentTime = currentTime;
        emit currentTimeChanged();
    }
}

void TimeSettings::setTimezone(const QString &timezone)
{
    if (d->timezone != timezone) {
        d->timezone = timezone;
        emit timezoneChanged();
    }
}


#include "timesettings.moc"
