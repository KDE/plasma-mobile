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

#include <KServiceTypeTrader>
#include <KDebug>

SettingsModuleLoader::SettingsModuleLoader(QObject * parent)
  : QObject(parent)
{
}

SettingsModuleLoader::~SettingsModuleLoader()
{
}

void SettingsModuleLoader::loadAllPlugins()
{
    kDebug() << "Load all plugins";
    KService::List offers = KServiceTypeTrader::self()->query("Active/SettingsModule");

    KService::List::const_iterator iter;
    for(iter = offers.begin(); iter < offers.end(); ++iter) {
       QString error;
       KService::Ptr service = *iter;

        KPluginFactory *factory = KPluginLoader(service->library()).factory();

        if (!factory) {
            kError(5001) << "KPluginFactory could not load the plugin:" << service->name() << service->library();
            kError(5001) << "That's OK, it's probably a QML only plugin";
            continue;
        }

        //SettingsModule *plugin = factory->create<SettingsModule>(this);
        //SettingsModule *plugin = factory->createInstance<SettingsModule>(0);
        const QString query = QString("exist Library and Library == '%1'").arg(service->library());
        kDebug() << "query: " << query;
        SettingsModule *plugin  = KServiceTypeTrader::createInstanceFromQuery<SettingsModule>("Active/SettingsModule", query, this);


       if (plugin) {
           kDebug() << "Load plugin:" << service->name();
           emit pluginLoaded(plugin);
       } else {
           kDebug() << error;
       }
    }
}
