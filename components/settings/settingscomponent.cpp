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


#include <QDeclarativeEngine>
#include <QDeclarativeComponent>

#include <KService>
#include <KServiceTypeTrader>
#include <KDebug>

#include <Plasma/Package>

class SettingsComponentPrivate {

public:
//     QList<QObject*> items;
    QString module;
    SettingsModule *settingsModule;
//     QDeclarativeEngine *engine;
//     QDeclarativeComponent *component;
    Plasma::Package* package;
    QUrl mainScript;
};


SettingsComponent::SettingsComponent(QDeclarativeItem *parent)
    : QDeclarativeItem(parent)
{
    d = new SettingsComponentPrivate;
    d->package = 0;
    d->settingsModule = 0;
//     d->engine = new QDeclarativeEngine(this);
//     kDebug() << "Creating settings component";
//     d->component = new QDeclarativeComponent(d->engine, this);
    //QObject *myObject = component->create();
}

SettingsComponent::~SettingsComponent()
{
}

void SettingsComponent::loadModule(const QString &name)
{

    delete d->package;
    //delete d->settingsModule;

    Plasma::PackageStructure::Ptr structure = Plasma::PackageStructure::load("Plasma/Generic");
    //structure->setPath(path);
    d->package = new Plasma::Package(QString(), name, structure);
    KGlobal::locale()->insertCatalog("plasma_package_" + name);
    //setMainScript(QUrl::fromLocalFile(d->package->filePath("mainscript")));
    //kDebug() << "QML FILE: " << d->mainScript;
    //d->component->loadUrl(qmlFile);
    QString pluginName = name;
    QString query;
    if (pluginName.isEmpty()) {
        kDebug() << "Not loading plugin ..." << pluginName;
        return;
    }
//     delete m_plugin;
//     if (ctx) {
//         ctx->setContextProperty("moduleName", pluginName);
//     }
    query = QString("[X-KDE-PluginInfo-Name] == '%1'").arg(pluginName);
    KService::List offers = KServiceTypeTrader::self()->query("Active/SettingsModule", query);
    kDebug() << "QUERY: " << offers.count() << query;
    KService::List::const_iterator iter;
    for(iter = offers.begin(); iter < offers.end(); ++iter) {
       QString error;
       KService::Ptr service = *iter;

        KPluginFactory *factory = KPluginLoader(service->library()).factory();

        QString description;
        if (!service->genericName().isEmpty() && service->genericName() != service->name()) {
            description = service->genericName();
        } else if (!service->comment().isEmpty()) {
            description = service->comment();
        }
//         if (ctx) {
//             ctx->setContextProperty("moduleName", pluginName);
//             ctx->setContextProperty("moduleTitle", service->name());
//             ctx->setContextProperty("moduleDescription", description);
//         }
        d->settingsModule = new SettingsModule(this);
        if (factory) {
            // Load binary plugin
            const QString query = QString("exist Library and Library == '%1'").arg(service->library());
            kDebug() << "loading binary plugin from query: " << query;
            QObject *p  = KServiceTypeTrader::createInstanceFromQuery<QObject>("Active/SettingsModule", query, this);
        } else {
            kDebug() << "QML only plugin";
        }


        connect(d->settingsModule, SIGNAL(nameChanged()), SIGNAL(nameChanged()));
        connect(d->settingsModule, SIGNAL(descriptionChanged()), SIGNAL(descriptionChanged()));

        d->settingsModule->setName(service->name());
        d->settingsModule->setDescription(description);
        d->settingsModule->setModule(pluginName);

       if (d->settingsModule) {
           kDebug() << "Successfully loaded plugin:" << service->name();
           //emit pluginLoaded(plugin);
       } else {
           kDebug() << error;
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
    kDebug() << "setmo" << module;
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

