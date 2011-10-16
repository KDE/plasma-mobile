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

    Q_PROPERTY(QString currentTime READ currentTime WRITE setCurrentTime NOTIFY currentTimeChanged)
    Q_PROPERTY(QString timezone READ timezone WRITE setTimezone NOTIFY timezoneChanged)

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
        QString timezone();

    public Q_SLOTS:
        void setCurrentTime(const QString &currentTime);
        void setTimezone(const QString &timezone);
        void timeout();

    Q_SIGNALS:
        void currentTimeChanged();
        void timezoneChanged();

    private:
        TimeSettingsPrivate* d;

};

#endif // TIMESETTINGS_H
