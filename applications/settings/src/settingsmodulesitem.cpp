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

#include "settingsmodulesitem.h"

#include <KIcon>
#include <kdebug.h>

class SettingsModulesItemPrivate {
public:
    QString name;
    QString description;
    QString module;
    QString iconName;
    QIcon icon;
};


SettingsModulesItem::SettingsModulesItem(const QString &n, const QString &i, const QString &m, QObject *parent)
    : QObject(parent)
{
    d = new SettingsModulesItemPrivate;
    d->name = n;
    d->module = m;
    d->icon = KIcon(i);
}

SettingsModulesItem::SettingsModulesItem(QObject *parent)
    : QObject(parent)
{
    d = new SettingsModulesItemPrivate;
    d->name = QString();
    d->module = QString();
}

SettingsModulesItem::~SettingsModulesItem()
{
    delete d;
}

QString SettingsModulesItem::name()
{
    return d->name;
}

QString SettingsModulesItem::description()
{
    return d->description;
}

QString SettingsModulesItem::module()
{
    return d->module;
}

QString SettingsModulesItem::iconName()
{
    return d->iconName;
}

QIcon SettingsModulesItem::icon()
{
    return d->icon;
}

void SettingsModulesItem::setName(const QString &name)
{
    d->name = name;
}

void SettingsModulesItem::setDescription(const QString &description)
{
    d->description = description;
}

void SettingsModulesItem::setIconName(const QString &iconName)
{
    d->iconName = iconName;
}

void SettingsModulesItem::setModule(const QString &module)
{
    d->module = module;
}

void SettingsModulesItem::setIcon(const QIcon &icon)
{
    d->icon = icon;
}

#include "settingsmodulesitem.moc"
