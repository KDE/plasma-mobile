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

#include <QDeclarativeContext>
#include <QDeclarativeEngine>

#include <KIcon>
#include <KService>
#include <KServiceTypeTrader>

#include "kdebug.h"

class SettingsModulesModelPrivate {

public:
//     QList<QObject*> items;
    QList<SettingsModule*> settingsModules;
    bool isPopulated;
};


SettingsModulesModel::SettingsModulesModel(QDeclarativeComponent *parent)
    : QDeclarativeComponent(parent)
{
    kDebug() << "Creating SettingsModel";
    d = new SettingsModulesModelPrivate;
    d->isPopulated = false;
    populate();
}

SettingsModulesModel::~SettingsModulesModel()
{
    delete d;
}

QDeclarativeListProperty<SettingsModule> SettingsModulesModel::settingsModules()
{
    return QDeclarativeListProperty<SettingsModule>(this, d->settingsModules);
}

void SettingsModulesModel::populate()
{
    if (d->isPopulated) {
        //kDebug() << "already populated.";
        return;
    }
    d->isPopulated = true;

    QString query;
    KService::List services = KServiceTypeTrader::self()->query("Active/SettingsModule", query);

    //kDebug() << "Found " << services.count() << " modules";
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
        SettingsModule* item = new SettingsModule(this);

        item->setName(service->name());
        item->setDescription(description);
        item->setIconName(service->icon());
        item->setModule(service->property("X-KDE-PluginInfo-Name").toString());
        d->settingsModules.append(item);
    }
    //emit dataChanged();
    emit settingsModulesChanged();
}

#include "settingsmodulesmodel.moc"
