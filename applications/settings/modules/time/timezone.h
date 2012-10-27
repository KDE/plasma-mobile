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

#ifndef TIMEZONE_H
#define TIMEZONE_H

#include <QObject>
#include <QString>
#include <KTimeZone>

class TimeZonePrivate;

class TimeZone : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

    public:
        explicit TimeZone(const KTimeZone &zone, QObject *parent = 0);
        virtual ~TimeZone();

        QString name();
    public Q_SLOTS:
        void setName(const QString &n);

    Q_SIGNALS:
        void nameChanged();

    private:
        TimeZonePrivate* d;
};

#endif // TIMEZONE_H
