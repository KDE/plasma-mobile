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
#include <KStandardDirs>
#include <KConfigGroup>


#include <QtDeclarative/qdeclarative.h>
#include <QtCore/QDate>

K_PLUGIN_FACTORY(TimeSettingsFactory, registerPlugin<TimeSettings>();)
K_EXPORT_PLUGIN(TimeSettingsFactory("active_settings_time"))

#define FORMAT24H "%H:%M:%S"
#define FORMAT12H "%l:%M:%S %p"

class TimeSettingsPrivate {
public:
    TimeSettings *q;
    QString timeFormat;
    QString timezone;
    QString currentTime;
    QTimer *timer;

    void initSettings();
    KSharedConfigPtr localeConfig;
    KConfigGroup localeSettings;

    // The current User settings from .kde/share/config/kdeglobals
    // This gets updated with the users changes in the kcm and saved when requested
    KSharedConfigPtr userConfig;
    KConfigGroup userSettings;
    KConfigGroup userCalendarSettings;
    // The kcm config/settings, a merger of C, Country, Group and User settings
    // This is used to build the displayed settings and to initialise the sample locale, but never saved
    KSharedConfigPtr m_kcmConfig;
    KConfigGroup m_kcmSettings;
    KConfigGroup m_kcmCalendarSettings;
    // The currently saved user config/settings
    // This is used to check if anything has changed, but never saved
    KSharedConfigPtr m_currentConfig;
    KConfigGroup m_currentSettings;
    KConfigGroup m_currentCalendarSettings;
    // The KCM Default settings, a merger of C, Country, and Group, i.e. excluding User
    KSharedConfigPtr m_defaultConfig;
    KConfigGroup m_defaultSettings;
    KConfigGroup m_defaultCalendarSettings;

    // The current Group settings, i.e. does NOT include the User or Country settings
    KSharedConfigPtr m_groupConfig;
    KConfigGroup m_groupSettings;
    KConfigGroup m_groupCalendarSettings;
    // The Country Locale config from l10n/<country>/entry.desktop
    KSharedConfigPtr m_countryConfig;
    KConfigGroup m_countrySettings;
    KConfigGroup m_countryCalendarSettings;
    // The default C Locale config/settings from l10n/C/entry.desktop
    KSharedConfigPtr m_cConfig;
    KConfigGroup m_cSettings;
    KConfigGroup m_cCalendarSettings;

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
    d->q = this;
    d->initSettings();
    setModule("org.kde.active.settings.time");
    init();

    // Just for testing that data gets through
    d->timer = new QTimer(this);
    d->timer->setInterval(1000);
    connect(d->timer, SIGNAL(timeout()), SLOT(timeout()));
    d->timer->start();

    kDebug() << "TimeSettings plugin loaded.";
}

TimeSettings::~TimeSettings()
{
    //kDebug() << "time destroy";
    delete d;
}

void TimeSettingsPrivate::initSettings()
{
    localeConfig = KSharedConfig::openConfig("kdeglobals", KConfig::SimpleConfig);
    localeSettings = KConfigGroup(localeConfig, "Locale");
    //setTimeFormat(d->localeSettings.readEntry("TimeFormat", QString(FORMAT24H)));
    //setTimeFormat(d->localeSettings.readEntry("TimeFormat", QString(FORMAT12H)));
//     /*
//     // Setup the KCM Config/Settings
//     // These are the effective settings merging KCM Changes, User, Group, Country, and C settings
//     // This will be used to display current state of settings in the KCM
//     // These settings should never be saved anywhere
//     m_kcmConfig = KSharedConfig::openConfig( "kcmlocale-kcm", KConfig::SimpleConfig );
//     m_kcmSettings = KConfigGroup( m_kcmConfig, "Locale" );
//     m_kcmSettings.deleteGroup();
//     m_kcmSettings.markAsClean();
// 
//     // Setup the Default Config/Settings
//     // These will be a merge of the C, Country and Group settings
//     // If the user clicks on the Defaults button, these are the settings that will be used
//     // These settings should never be saved anywhere
//     m_defaultConfig = KSharedConfig::openConfig( "kcmlocale-default", KConfig::SimpleConfig );
//     m_defaultSettings = KConfigGroup( m_defaultConfig, "Locale" );
// 
//     // Setup the User Config/Settings
//     // These are the User overrides, they exclude any Group, Country, or C settings
//     // This will be used to store the User changes
//     // These are the only settings that should ever be saved
//     userConfig = KSharedConfig::openConfig( "kcmlocale-user", KConfig::IncludeGlobals );
//     userSettings = KConfigGroup( userConfig, "Locale" );
// 
//     // Setup the Current Config/Settings
//     // These are the currently saved User settings
//     // This will be used to check if the kcm settings have been changed
//     // These settings should never be saved anywhere
//     m_currentConfig = KSharedConfig::openConfig( "kcmlocale-current", KConfig::IncludeGlobals );
//     m_currentSettings = KConfigGroup( m_currentConfig, "Locale" );
// 
//     // Setup the Group Config/Settings
//     // These are the Group overrides, they exclude any User, Country, or C settings
//     // This will be used in the merge to obtain the KCM Defaults
//     // These settings should never be saved anywhere
//     m_groupConfig = KSharedConfig::openConfig( "kcmlocale-group", KConfig::NoGlobals );
//     m_groupSettings = KConfigGroup( m_groupConfig, "Locale" );
// 
//     // Setup the C Config Settings
//     // These are the C/Posix defaults and KDE defaults where a setting doesn't exist in Posix
//     // This will be used as the lowest level in the merge to obtain the KCM Defaults
//     // These settings should never be saved anywhere
//     m_cConfig = KSharedConfig::openConfig( KStandardDirs::locate( "locale",
//                                            QString::fromLatin1("l10n/C/entry.desktop") ) );
//     m_cSettings= KConfigGroup( m_cConfig, "KCM Locale" );
// 
//     /*
//     initCountrySettings( KGlobal::locale()->country() );
// 
//     initCalendarSettings();
// 
//     m_kcmLocale = new KLocale( QLatin1String("kcmlocale"), m_kcmConfig );
//     m_defaultLocale = new KLocale( QLatin1String("kcmlocale"), m_defaultConfig );
// 
//     // Find out the system country using a null config
//     m_systemCountry = m_kcmLocale->country();
// 
//     // Set up the initial languages to use
//     m_currentTranslations = m_userSettings.readEntry( "Language", QString() );
//     m_kcmTranslations = m_currentTranslations.split( ':', QString::SkipEmptyParts );
//     */
    
    q->setTimeFormat( localeSettings.readEntry( "TimeFormat", QString() ) );

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

        d->localeSettings.writeEntry("TimeFormat", timeFormat);
        d->localeConfig->sync();

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
