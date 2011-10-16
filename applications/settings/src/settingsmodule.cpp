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
#include "settingsmodule_macros.h"

#include <kdebug.h>
#include <KIcon>
#include <KLocale>
#include <KService>
#include <KServiceTypeTrader>

class SettingsModulePrivate {

public:
    SettingsModulePrivate(SettingsModule *q):
                  q(q),
                  m_settings(0){}

    QString name;
    QString description;
    QString module;
    QString iconName;
    QIcon icon;
    SettingsModule *q;
    QObject *m_settings;
};

SettingsModule::SettingsModule(QObject *parent, const QVariantList &v) : QObject(parent),
                                  d(new SettingsModulePrivate(this))
{
    //setProperty("objectName", QString("settingsObject"));
}

SettingsModule::~SettingsModule()
{
    delete d;
}

QString SettingsModule::name()
{
    return d->name;
}

void SettingsModule::init()
{
    QString query;
    kDebug()<<query;
    KService::List services = KServiceTypeTrader::self()->query("Active/SettingsModule", query);

    kDebug() << "Found " << services.count() << " modules";
    foreach (const KService::Ptr &service, services) {
        if (service->noDisplay()) {
            continue;
        }

        QString description;
        if (!service->genericName().isEmpty() && service->genericName() != service->name()) {
            description = service->genericName();
        } else if (!service->comment().isEmpty()) {
            description = service->comment();
        }
        setName(service->name());
        setDescription(description);
        setModule(service->property("X-KDE-PluginInfo-Name").toString());
        setIconName(service->icon());
        setIcon(KIcon(service->icon()));
    }

    emit dataChanged();
}

QObject* SettingsModule::settingsObject()
{
    return d->m_settings;
}

void SettingsModule::setSettingsObject(QObject *settings)
{
    d->m_settings = settings;
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

QIcon SettingsModule::icon()
{
    return d->icon;
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
    d->iconName = iconName;
}

void SettingsModule::setModule(const QString &module)
{
    d->module = module;
}

void SettingsModule::setIcon(const QIcon &icon)
{
    d->icon = icon;
}

#include "settingsmodule.moc"