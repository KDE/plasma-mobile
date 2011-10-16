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

#include <KIcon>
#include <kdebug.h>
#include <QVariant>

#include <kdemacros.h>
#include "settingsmodule_macros.h"

//SETTINGSMODULE_PLUGIN_EXPORT("TimeSettings");

K_PLUGIN_FACTORY(TimeSettingsFactory, registerPlugin<TimeSettings>();)
K_EXPORT_PLUGIN(TimeSettingsFactory("active_settings_time"))

class TimeSettingsPrivate {
public:
    QString name;
    QString description;
    QString module;
    QString iconName;
    QIcon icon;
};

/*
TimeSettings::TimeSettings(const QString &n, const QString &i, const QString &m, QObject *parent)
    : SettingsModule(parent, QVariantList())
{
    d = new TimeSettingsPrivate;
    d->name = n;
    d->module = m;
    d->icon = KIcon(i);
    kDebug() << " @@@@@ Loaded Module Successfully: " << d->name << d->module;
}
*/
TimeSettings::TimeSettings(QObject *parent, const QVariantList &list)
    : SettingsModule(parent, list)
{
    d = new TimeSettingsPrivate;
    d->name = QString();
    d->module = QString();
    kDebug() << " @@@@@@@@@@@@@@@@ Loaded Module Successfully: " << d->name << d->module;
}

TimeSettings::~TimeSettings()
{
    delete d;
}

QString TimeSettings::name()
{
    return d->name;
}

QString TimeSettings::description()
{
    return d->description;
}

QString TimeSettings::module()
{
    return d->module;
}

QString TimeSettings::iconName()
{
    return d->iconName;
}

QIcon TimeSettings::icon()
{
    return d->icon;
}

void TimeSettings::setName(const QString &name)
{
    d->name = name;
}

void TimeSettings::setDescription(const QString &description)
{
    d->description = description;
}

void TimeSettings::setIconName(const QString &iconName)
{
    d->iconName = iconName;
}

void TimeSettings::setModule(const QString &module)
{
    d->module = module;
}

void TimeSettings::setIcon(const QIcon &icon)
{
    d->icon = icon;
}

#include "timesettings.moc"
