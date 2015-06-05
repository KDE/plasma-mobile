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

#include <KPluginTrader>
#include <KService>
#include <KServiceTypeTrader>
#include <QDebug>
#include <KPluginMetaData>

#include <Plasma/Package>
#include <Plasma/PluginLoader>
#include <kquickaddons/configmodule.h>

class SettingsComponentPrivate {

public:
    QString module;
    QString icon;
    SettingsModule *settingsModule;
    KQuickAddons::ConfigModule *kcm;
    bool valid : 1;
    Plasma::Package package;
};


SettingsComponent::SettingsComponent(QQuickItem *parent)
    : QQuickItem(parent)
{
    d = new SettingsComponentPrivate;
    d->package = Plasma::PluginLoader::self()->loadPackage(QStringLiteral("Plasma/Generic"));
    d->settingsModule = 0;
    d->kcm = 0;
    d->valid = false;
}

SettingsComponent::~SettingsComponent()
{
}

void SettingsComponent::loadModule(const QString &name)
{
    delete d->settingsModule;
    d->settingsModule = 0;
    delete d->kcm;
    d->kcm = 0;

    d->package.setPath(name);
    //KGlobal::locale()->insertCatalog("plasma_package_" + name);
#warning "Re-enable translation catalog, port insertCatalog"
    QString pluginName = name;
    QString query;
    if (pluginName.isEmpty()) {
        qDebug() << "Not loading plugin ..." << pluginName;
        return;
    }
    query = QString("[X-KDE-PluginInfo-Name] == '%1'").arg(pluginName);
    KService::List offers = KServiceTypeTrader::self()->query("Active/SettingsModule", query);
    KService::List::const_iterator iter;
    for(iter = offers.constBegin(); iter < offers.constEnd(); ++iter) {
        QString error;
        KService::Ptr service = *iter;

        //KPluginFactory *factory = KPluginLoader(service->library()).factory();

        QString description;
        if (!service->genericName().isEmpty() && service->genericName() != service->name()) {
            description = service->genericName();
        } else if (!service->comment().isEmpty()) {
            description = service->comment();
        }
        qDebug() << "Found plugin" << description << service->library();


        d->settingsModule = new SettingsModule(this);

        if (!service->library().isEmpty()) {
            // Load binary plugin
            qDebug() << "\n\nloading binary plugin from query: " << service->name();
            KPluginLoader loader(KPluginLoader::findPlugin("active/settingsmodule/"+service->library()));
            KPluginFactory* factory = loader.factory();
            if (!factory) {
                qWarning() << "Error loading plugin:" << loader.errorString();
            } else {
                QObject* obj = factory->create<QObject>();
                if (!obj) {
                    qWarning() << "Error creating object from plugin" << loader.fileName();
                    d->valid = true;
                }
            }
        } else {
            qDebug() << "QML only plugin";
        }

        connect(d->settingsModule, &SettingsModule::nameChanged, this, &SettingsComponent::nameChanged);
        connect(d->settingsModule, &SettingsModule::descriptionChanged,
                this, &SettingsComponent::descriptionChanged);

        d->settingsModule->setName(service->name());
        setIcon(service->icon());
        d->settingsModule->setDescription(description);
        d->settingsModule->setModule(pluginName);

       if (d->settingsModule) {
           //qDebug() << "Successfully loaded plugin:" << service->name();
           //emit pluginLoaded(plugin);
       } else {
           qDebug() << error;
       }
    }

   /* if (!d->settingsModule) {
        return;
    }*/

    //qml-kcm mode
    KPluginLoader loader(KPluginLoader::findPlugin(QLatin1String("kcms/") + name));

    KPluginFactory* factory = loader.factory();
    if (!factory) {
        qWarning() << "Error loading KCM plugin:" << loader.errorString();
    } else {
        d->kcm = factory->create<KQuickAddons::ConfigModule >();
        if (!d->kcm) {
            qWarning() << "Error creating object from plugin" << loader.fileName();
            d->valid = false;
            emit validChanged();
            return;
        }

        d->settingsModule = new SettingsModule(this);
        connect(d->settingsModule, &SettingsModule::nameChanged, this, &SettingsComponent::nameChanged);
        connect(d->settingsModule, &SettingsModule::descriptionChanged,
                this, &SettingsComponent::descriptionChanged);
        d->kcm->mainUi()->setParentItem(this);

        {
            //set anchors
            QQmlExpression expr(QtQml::qmlContext(d->kcm->mainUi()), d->kcm->mainUi(), "parent");
            QQmlProperty prop(d->kcm->mainUi(), "anchors.fill");
            prop.write(expr.evaluate());
        }

        d->kcm->load();
        //instant apply
        connect(d->kcm, &KQuickAddons::ConfigModule::needsSaveChanged, [=]() {
            if (d->kcm->needsSave()) {
                d->kcm->save();
            }
        });

        KPluginMetaData info(loader.fileName());
        d->settingsModule->setName(info.name());
        setIcon(info.iconName());
        d->settingsModule->setDescription(info.description());
        d->settingsModule->setModule(info.pluginId());
        d->valid = true;
    }

    emit validChanged();
}

bool SettingsComponent::isValid() const
{
    return d->valid;
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

QString SettingsComponent::icon() const
{
    return d->icon;
}

void SettingsComponent::setIcon(const QString& name)
{
    if (name != d->icon) {
        d->icon = name;
        emit iconChanged();
    }
}


QString SettingsComponent::module() const
{
    return d->module;
}

void SettingsComponent::setModule(const QString &module)
{
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

