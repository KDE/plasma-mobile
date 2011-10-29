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

#ifndef TIMESETTINGS_H
#define TIMESETTINGS_H

#include <KIconLoader>

#include <QObject>
#include <QIcon>
#include <QVariant>
#include <QStringListModel>

#include "settingsmodule.h"

class TimeSettingsPrivate;

/**
 * @class A class to manage time and date related settings. This class serves two functions:
 * - Provide a plugin implementation
 * - Provide a settings module
 * This is done from one class in order to simplify the code. You can export any QObject-based
 * class through qmlRegisterType(), however.
 */
class TimeSettings : public SettingsModule
{
    Q_OBJECT

    Q_PROPERTY(QString timeFormat READ timeFormat WRITE setTimeFormat NOTIFY timeFormatChanged)
    Q_PROPERTY(bool twentyFour READ twentyFour WRITE setTwentyFour NOTIFY twentyFourChanged)
    Q_PROPERTY(QString timeZone READ timeZone WRITE setTimeZone NOTIFY timeZoneChanged)
    Q_PROPERTY(QList<QObject*> timeZones READ timeZones WRITE setTimeZones NOTIFY timeZonesChanged)
    Q_PROPERTY(QStringListModel* timeZonesModel READ timeZonesModel WRITE setTimeZonesModel NOTIFY timeZonesModelChanged)
    Q_PROPERTY(QString currentTime READ currentTime WRITE setCurrentTime NOTIFY currentTimeChanged)

    public:
        /**
         * @name Plugin Constructor
         *
         * @arg parent The parent object
         * @arg list Arguments, currently unused
         */
        TimeSettings(QObject *parent, const QVariantList &list = QVariantList());
        /**
         * @name Settings Module Constructor
         *
         * @arg parent The parent object
         * @arg list Arguments, currently unused
         */
        TimeSettings();
        virtual ~TimeSettings();

        QString currentTime();
        QString timeFormat();
        QString timeZone();
        QList<QObject*> timeZones();
        QStringListModel* timeZonesModel();
        bool twentyFour();

    public Q_SLOTS:
        void setCurrentTime(const QString &currentTime);
        void setTimeZone(const QString &timezone);
        void setTimeZones(const QList<QObject*> timezones);
        void setTimeZonesModel(QStringListModel *timezones);
        void setTimeFormat(const QString &timeFormat);
        void setTwentyFour(bool t);
        void timeout();
        Q_INVOKABLE void timeZoneFilterChanged(const QString &filter);
        Q_INVOKABLE void saveTimeZone(const QString &newtimezone);

    Q_SIGNALS:
        void currentTimeChanged();
        void twentyFourChanged();
        void timeFormatChanged();
        void timeZoneChanged();
        void timeZonesChanged();
        void timeZonesModelChanged();

    private:
        TimeSettingsPrivate* d;
};

#endif // TIMESETTINGS_H
