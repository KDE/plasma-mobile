/*
 *  tzone.cpp
 *
 *  Copyright (C) 1998 Luca Montecchiani <m.luca@usa.net>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

/*

 A helper that's run using KAuth and does the system modifications.

*/

#include "helper.h"
#include "config.h"

#include <sys/time.h>
#include <time.h>
#include <unistd.h>

#include <kcomponentdata.h>
#include <kconfig.h>
#include <kconfiggroup.h>
#include <kstandarddirs.h>
#include <kprocess.h>
#include <QFile>
#include <QDebug>



int ClockHelper::ntp( const QStringList& ntpServers, bool ntpEnabled,
                      const QString& ntpUtility )
{
  int ret = 0;

  // write to the system config file
  QFile config_file(KDE_CONFDIR "/kcmclockrc");
  if(!config_file.exists()) {
    config_file.open(QIODevice::WriteOnly);
    config_file.close();
    config_file.setPermissions(QFile::ReadOwner | QFile::WriteOwner | QFile::ReadGroup | QFile::ReadOther);
  }
  KConfig _config(config_file.fileName(), KConfig::SimpleConfig);
  KConfigGroup config(&_config, "NTP");
  config.writeEntry("servers", ntpServers );
  config.writeEntry("enabled", ntpEnabled );

  if ( ntpEnabled && !ntpUtility.isEmpty() ) {
    // NTP Time setting
    QString timeServer = ntpServers.first();
    if( timeServer.indexOf( QRegExp(".*\\(.*\\)$") ) != -1 ) {
      timeServer.replace( QRegExp(".*\\("), '' );
      timeServer.replace( QRegExp("\\).*"), '' );
      // Would this be better?: s/^.*\(([^)]*)\).*$/\1/
    }

    KProcess proc;
    proc << ntpUtility << timeServer;
    if ( proc.execute() != 0 ) {
      ret |= NTPError;
    }
  } else if( ntpEnabled ) {
    ret |= NTPError;
  }

  return ret;
}

int ClockHelper::date( const QString& newdate, const QString& olddate )
{
    struct timeval tv;

    tv.tv_sec = newdate.toULong() - olddate.toULong() + time(0);
    tv.tv_usec = 0;
#ifndef Q_OS_WIN32
    if (settimeofday(&tv, 0)) {
        return DateError;
    }
#else
    return DateError;
#endif
    if (!KStandardDirs::findExe("hwclock").isEmpty()) {
        KProcess::execute("hwclock", QStringList() << "--systohc");
    }
    return 0;
}

// on non-Solaris systems which do not use /etc/timezone?
int ClockHelper::tz( const QString& selectedzone )
{
    int ret = 0;

    QString tz = "/usr/share/zoneinfo/" + selectedzone;

    if( !KStandardDirs::findExe( "zic" ).isEmpty()) {
        KProcess::execute("zic", QStringList() << "-l" << selectedzone);
    } else if (!QFile::remove("/etc/localtime")) {
        ret |= TimezoneError;
    } else if (!QFile::copy(tz, "/etc/localtime")) {
        ret |= TimezoneError;
    }

    QFile fTimezoneFile("/etc/timezone");

    if (fTimezoneFile.exists() && fTimezoneFile.open(QIODevice::WriteOnly | QIODevice::Truncate) ) {
        QTextStream t(&fTimezoneFile);
        t << selectedzone;
        fTimezoneFile.close();
    }

    QString val = ':' + tz;


        setenv("TZ", val.toAscii(), 1);
        tzset();

    return ret;
}

int ClockHelper::tzreset()
{
    return 0;
}

ActionReply ClockHelper::save(const QVariantMap &args)
{
  bool _ntp = args.value("ntp").toBool();
  bool _date = args.value("date").toBool();
  bool _tz = args.value("tz").toBool();
  bool _tzreset = args.value("tzreset").toBool();

  KComponentData data( "kcmdatetimehelper" );

  int ret = 0; // error code
//  The order here is important
  if( _ntp )
    ret |= ntp( args.value("ntpServers").toStringList(), args.value("ntpEnabled").toBool(), args.value("ntpUtility").toString() );
  if( _date )
    ret |= date( args.value("newdate").toString(), args.value("olddate").toString() );
  if( _tz )
    ret |= tz( args.value("tzone").toString() );
  if( _tzreset )
    ret |= tzreset();

  if (ret == 0) {
    return ActionReply::SuccessReply;
  } else {
    ActionReply reply(ActionReply::HelperError);
    reply.setErrorCode(ret);
    return reply;
  }
}

KDE4_AUTH_HELPER_MAIN("org.kde.active.clockconfig", ClockHelper)
