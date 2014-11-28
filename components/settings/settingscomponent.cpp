/*
    Copyright 2011 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#include "settingscomponent.h"
#include "settingsmodule.h"

#include <QQmlEngine>
#include <QQmlComponent>

#include <KService>
#include <KServiceTypeTrader>
#include <QDebug>

#include <Plasma/Package>
#include <Plasma/PluginLoader>

class SettingsComponentPrivate {

public:
    QString module;
    SettingsModule *settingsModule;
    Plasma::Package package;
};


SettingsComponent::SettingsComponent(QQuickItem *parent)
    : QQuickItem(parent)
{
    d = new SettingsComponentPrivate;
    d->package = Plasma::PluginLoader::self()->loadPackage(QStringLiteral("Plasma/Generic"));
    d->settingsModule = 0;
}

SettingsComponent::~SettingsComponent()
{
}

void SettingsComponent::loadModule(const QString &name)
{
    delete d->settingsModule;
    d->settingsModule = 0;

    d->package.setPath(name);
    //KGlobal::locale()->insertCatalog("plasma_package_" + name);
#warning "Re-enable translation catalog, port insertCatalog"
    QString pluginName = name;
    QString query;
    if (pluginName.isEmpty()) {
        //qDebug() << "Not loading plugin ..." << pluginName;
        return;
    }
    query = QString("[X-KDE-PluginInfo-Name] == '%1'").arg(pluginName);
    KService::List offers = KServiceTypeTrader::self()->query("Active/SettingsModule", query);
    KService::List::const_iterator iter;
    for(iter = offers.constBegin(); iter < offers.constEnd(); ++iter) {
       QString error;
       KService::Ptr service = *iter;

        KPluginFactory *factory = KPluginLoader(service->library()).factory();

        QString description;
        if (!service->genericName().isEmpty() && service->genericName() != service->name()) {
            description = service->genericName();
        } else if (!service->comment().isEmpty()) {
            description = service->comment();
        }
        d->settingsModule = new SettingsModule(this);
        if (factory) {
            // Load binary plugin
            const QString query = QString("exist Library and Library == '%1'").arg(service->library());
            qDebug() << "loading binary plugin from query: " << service->name();
            KServiceTypeTrader::createInstanceFromQuery<QObject>("Active/SettingsModule", query, d->settingsModule);
        } else {
            qDebug() << "QML only plugin";
        }


        connect(d->settingsModule, SIGNAL(nameChanged()), SIGNAL(nameChanged()));
        connect(d->settingsModule, SIGNAL(descriptionChanged()), SIGNAL(descriptionChanged()));

        d->settingsModule->setName(service->name());
        d->settingsModule->setDescription(description);
        d->settingsModule->setModule(pluginName);

       if (d->settingsModule) {
           qDebug() << "Successfully loaded plugin:" << service->name();
           //emit pluginLoaded(plugin);
       } else {
           qDebug() << error;
       }
    }

}

QString SettingsComponent::description() const
{
    if (d->settingsModule) {    
        return d->settingsModule->description();
    }
    return QString();
}

void SettingsComponent::setDescription(const QString &description)
{
    if (d->settingsModule && d->settingsModule->description() != description) {
        d->settingsModule->setDescription(description);
        emit descriptionChanged();
    }
}

QString SettingsComponent::module() const
{
    return d->module;
}

void SettingsComponent::setModule(const QString &module)
{
    qDebug() << "setmo" << module;
    if (d->module != module) {
        d->module = module;
        loadModule(module);
        emit moduleChanged();
    }
}

QString SettingsComponent::name() const
{
    if (d->settingsModule) {
        return d->settingsModule->name();
    }
    return QString();
}

void SettingsComponent::setName(const QString &name)
{
    if (d->settingsModule && d->settingsModule->name() != name) {
        d->settingsModule->setName(name);
        emit nameChanged();
    }
}


#include "settingscomponent.moc"

