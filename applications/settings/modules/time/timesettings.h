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

class TimeSettings : public SettingsModule
{
    Q_OBJECT

    public:
        TimeSettings(QObject *parent, const QVariantList &list = QVariantList());
        TimeSettings();
        virtual ~TimeSettings();

    public Q_SLOTS:
        void timeout();

    private:
        TimeSettingsPrivate* d;

};

#endif // TIMESETTINGS_H
