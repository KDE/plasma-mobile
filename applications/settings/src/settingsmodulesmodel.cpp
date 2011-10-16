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

//#define KDE_DEPRECATED 1

#include "settingsmodulesmodel.h"
#include "settingsmodulesitem.h"

#include <KService>
#include <KServiceTypeTrader>

#include "kdebug.h"

class SettingsModulesModelPrivate {

public:
    QList<QObject*> items;
    bool isPopulated;
};


SettingsModulesModel::SettingsModulesModel(QObject *parent)
    : QObject(parent)
{
    d = new SettingsModulesModelPrivate;
    d->isPopulated = false;
    kDebug() << "New Settings Model, populating...";
    populate();
}

SettingsModulesModel::~SettingsModulesModel()
{
    delete d;
}

QList<QObject*> SettingsModulesModel::items()
{
    QList<QObject*> l;
    l.append(d->items);

    return l;
}

void SettingsModulesModel::populate()
{
    kDebug() << "populating model...";
    if (d->isPopulated) {
        kDebug() << "already populated.";
        return;
    }
    d->isPopulated = true;

    //kDebug() << "FIXME: implement";
    //    X-KDE-PluginInfo-Name=org.kde.active.settings.time

    QString query;
    //query = "exist 'X-KDE-PluginInfo-Name'";
    //query += "and ('org.kde.active.settings.' ~subin 'X-KDE-PluginInfo-Name')";
    /*
    if (!m_categories.isEmpty()) {
        query += " and (";
        bool first = true;
        foreach (const QString &category, m_categories) {
            if (!first) {
                query += " or ";
            }
            first = false;
            query += QString(" (exist Categories and '%1' ~subin Categories)").arg(category);
        }
        query += ")";
    }
    */
    //openSUSE: exclude YaST modules from the list
    //query += " and (not (exist Categories and 'X-SuSE-YaST' in Categories))";
    /*
    // Filter out blacklisted apps as to not show too much crap
    foreach (const QString appName, m_blackList) {
        query += QString(" and (DesktopEntryName != '%1' )").arg(appName);
    }
    */
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
        kDebug() << " ---------> FOUND MODULE: " << service->name() << description;
        /*
        data["iconName"] = service->icon();
        data["name"] = service->name();
        data["genericName"] = service->genericName();
        data["description"] = description;
        data["storageId"] = service->storageId();
        data["entryPath"] = service->entryPath();
        setData(service->storageId(), data);
        */
    }

    //checkForUpdate();
}

#include "settingsmodulesmodel.moc"
