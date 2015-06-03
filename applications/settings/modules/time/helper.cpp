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

#include <config.h>

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

#if defined(USE_SOLARIS)
#include <ktemporaryfile.h>
#include <sys/param.h>
#include <sys/types.h>
#include <sys/stat.h>
#endif

// We cannot rely on the $PATH environment variable, because D-Bus activation
// clears it. So we have to use a reasonable default.
static const QString exePath = QLatin1String("/usr/sbin:/usr/bin:/sbin:/bin");

int ClockHelper::ntp( const QStringList& ntpServers, bool ntpEnabled )
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

    QString ntpUtility = QStandardPaths::findExecutable("ntpdate");
    if (ntpUtility.isEmpty()) {
        ntpUtility = QStandardPaths::findExecutable("rdate");
    }

    if ( ntpEnabled && !ntpUtility.isEmpty() ) {
        // NTP Time setting
        QString timeServer = ntpServers.first();
        if( timeServer.indexOf( QRegExp(".*\\(.*\\)$") ) != -1 ) {
            timeServer.replace( QRegExp(".*\\("), "" );
            timeServer.replace( QRegExp("\\).*"), "" );
            // Would this be better?: s/^.*\(([^)]*)\).*$/\1/
        }

        KProcess proc;
        proc << ntpUtility << timeServer;
        if ( proc.execute() != 0 ) {
            ret |= NTPError;
        } else {
            toHwclock();
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
    if (settimeofday(&tv, 0)) {
        return DateError;
    }

    toHwclock();
    return 0;
}

// on non-Solaris systems which do not use /etc/timezone?
int ClockHelper::tz( const QString& selectedzone )
{
    int ret = 0;

    //only allow letters, numbers hyphen underscore plus and forward slash
    //allowed pattern taken from time-util.c in systemd
    if (!QRegExp("[a-zA-Z0-9-_+/]*").exactMatch(selectedzone)) {
        return ret;
    }

    QString val;
#if defined(USE_SOLARIS)	// MARCO
    KTemporaryFile tf;
    tf.setPrefix("kde-tzone");
    tf.open();
    QTextStream ts(&tf);

    QFile fTimezoneFile(INITFILE);
    bool updatedFile = false;

    if (fTimezoneFile.open(QIODevice::ReadOnly))
    {
        bool found = false;

        QTextStream is(&fTimezoneFile);

        for (QString line = is.readLine(); !line.isNull();
             line = is.readLine())
        {
            if (line.find("TZ=") == 0)
            {
                ts << "TZ=" << selectedzone << endl;
                found = true;
            }
            else
            {
                ts << line << endl;
            }
        }

        if (!found)
        {
            ts << "TZ=" << selectedzone << endl;
        }

        updatedFile = true;
        fTimezoneFile.close();
    }

    if (updatedFile)
    {
        ts.device()->reset();
        fTimezoneFile.remove();

        if (fTimezoneFile.open(QIODevice::WriteOnly | QIODevice::Truncate))
        {
            QTextStream os(&fTimezoneFile);

            for (QString line = ts->readLine(); !line.isNull();
                 line = ts->readLine())
            {
                os << line << endl;
            }

            fchmod(fTimezoneFile.handle(),
                   S_IXUSR | S_IRUSR | S_IRGRP | S_IXGRP |
                   S_IROTH | S_IXOTH);
            fTimezoneFile.close();
        }
    }


    val = selectedzone;
#else
    QString tz = "/usr/share/zoneinfo/" + selectedzone;

    if (QFile::exists(tz)) { // make sure the new TZ really exists
        QFile::remove("/etc/localtime");
    } else {
        return TimezoneError;
    }

    if (!QFile::link(tz, "/etc/localtime")) { // fail if we can't setup the new timezone
        return TimezoneError;
    }

    QFile fTimezoneFile("/etc/timezone");

    if (fTimezoneFile.exists() && fTimezoneFile.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QTextStream t(&fTimezoneFile);
        t << selectedzone;
        fTimezoneFile.close();
    }
#endif // !USE_SOLARIS
    val = ':' + selectedzone;

    setenv("TZ", val.toLocal8Bit().constData(), 1);
    tzset();

    return ret;
}

int ClockHelper::tzreset()
{
#if !defined(USE_SOLARIS) // Do not update the System!
    unlink( "/etc/timezone" );
    unlink( "/etc/localtime" );

    setenv("TZ", "", 1);
    tzset();
#endif // !USE SOLARIS
    return 0;
}

void ClockHelper::toHwclock()
{
    QString hwclock = KStandardDirs::findExe("hwclock", exePath);
    if (!hwclock.isEmpty()) {
        KProcess::execute(hwclock, QStringList() << "--systohc");
    }
}

ActionReply ClockHelper::save(const QVariantMap &args)
{
    bool _ntp = args.value("ntp").toBool();
    bool _date = args.value("date").toBool();
    bool _tz = args.value("tz").toBool();
    bool _tzreset = args.value("tzreset").toBool();

    KComponentData data( "activedatetimehelper" );

    int ret = 0; // error code
    //  The order here is important
    if( _ntp )
        ret |= ntp( args.value("ntpServers").toStringList(), args.value("ntpEnabled").toBool());
    if( _date )
        ret |= date( args.value("newdate").toString(), args.value("olddate").toString() );
    if( _tz )
        ret |= tz( args.value("tzone").toString() );
    if( _tzreset )
        ret |= tzreset();

    if (ret == 0) {
        return ActionReply::SuccessReply();
    } else {
        ActionReply reply(ActionReply::HelperErrorReply());
        reply.setErrorCode(static_cast<ActionReply::Error>(ret));
        return reply;
    }
}

KAUTH_HELPER_MAIN("org.kde.active.clockconfig", ClockHelper)
