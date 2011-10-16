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


#include "settingsmoduleloader.h"
#include "settingsmodule.h"

#include <QDeclarativeContext>

#include <KServiceTypeTrader>
#include <KDebug>

SettingsModuleLoader::SettingsModuleLoader(QObject * parent)
  : QObject(parent),
    m_plugin(0)
{
}

SettingsModuleLoader::~SettingsModuleLoader()
{
}

void SettingsModuleLoader::loadAllPlugins(const QString &pluginName, QDeclarativeContext* ctx)
{
    QString query;
    if (pluginName.isEmpty() || (m_pluginName == pluginName)) {
        kDebug() << "Not loading plugin ..." << pluginName;
        return;
    }
    delete m_plugin;
    query = QString("exist Library and [X-KDE-PluginInfo-Name] == '%1'").arg(pluginName);
    KService::List offers = KServiceTypeTrader::self()->query("Active/SettingsModule", query);
    //kDebug() << "QUERY: " << offers.count() << query;
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
        if (ctx) {
            ctx->setContextProperty("moduleName", pluginName);
            ctx->setContextProperty("moduleTitle", service->name());
            ctx->setContextProperty("moduleDescription", description);
        }
        if (!factory) {
            kError(5001) << "KPluginFactory could not load the plugin:" << service->name() << service->library();
            kError(5001) << "That's OK, it's probably a QML only plugin";
            continue;
        }

        const QString query = QString("exist Library and Library == '%1'").arg(service->library());
        //kDebug() << "query: " << query;
        SettingsModule *plugin  = KServiceTypeTrader::createInstanceFromQuery<SettingsModule>("Active/SettingsModule", query, this);


        plugin->setName(service->name());
        plugin->setDescription(description);
        plugin->setModule(pluginName);


       if (plugin) {
           //kDebug() << "Load plugin:" << service->name();
           emit pluginLoaded(plugin);
       } else {
           kDebug() << error;
       }
    }
}
