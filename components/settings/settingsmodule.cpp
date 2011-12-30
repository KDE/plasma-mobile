/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "settingsmodule.h"

#include <kdebug.h>
#include <KIcon>
#include <KLocale>
#include <KService>
#include <KServiceTypeTrader>

class SettingsModulePrivate {

public:
    SettingsModulePrivate(SettingsModule *q):
                  q(q) {}

    QString name;
    QString description;
    QString module;
    QString iconName;
    SettingsModule *q;
};

SettingsModule::SettingsModule(QObject *parent, const QVariantList &v) : QObject(parent),
                                  d(new SettingsModulePrivate(this))
{
    d = new SettingsModulePrivate(this);
    Q_UNUSED(v);
}

SettingsModule::~SettingsModule()
{
    delete d;
}

QString SettingsModule::name()
{
    return d->name;
}

QString SettingsModule::description()
{
    return d->description;
}

QString SettingsModule::module()
{
    return d->module;
}

QString SettingsModule::iconName()
{
    return d->iconName;
}

void SettingsModule::setName(const QString &name)
{
    if (d->name != name) {
        d->name = name;
        emit nameChanged();
    }
}

void SettingsModule::setDescription(const QString &description)
{
    if (d->description != description) {
        d->description = description;
        emit descriptionChanged();
    }
}

void SettingsModule::setIconName(const QString &iconName)
{
    if (d->iconName != iconName) {
        d->iconName = iconName;
        emit iconNameChanged();
    }
}

void SettingsModule::setModule(const QString &module)
{
    if (d->module != module) {
        d->module = module;
        emit moduleChanged();
    }
}

#include "settingsmodule.moc"