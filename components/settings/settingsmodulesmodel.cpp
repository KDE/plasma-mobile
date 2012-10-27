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
#include <QTimer>

#include <KIcon>
#include <KPluginInfo>
#include <KService>
#include <KServiceTypeTrader>

#include "kdebug.h"

class SettingsModulesModelPrivate {

public:
    SettingsModulesModelPrivate(SettingsModulesModel *parent)
        : isPopulated(false),
          populateTimer(new QTimer(parent))
    {}

    bool isPopulated;
    QList<SettingsModule*> settingsModules;
    QTimer *populateTimer;
    QString appName;
};


SettingsModulesModel::SettingsModulesModel(QDeclarativeComponent *parent)
    : QDeclarativeComponent(parent),
      d(new SettingsModulesModelPrivate(this))
{
    kDebug() << "Creating SettingsModel";
    d->populateTimer->setInterval(0);
    d->populateTimer->setSingleShot(true);
    connect(d->populateTimer, SIGNAL(timeout()), this, SLOT(populate()));
    d->populateTimer->start();
}

SettingsModulesModel::~SettingsModulesModel()
{
    delete d;
}

QDeclarativeListProperty<SettingsModule> SettingsModulesModel::settingsModules()
{
    return QDeclarativeListProperty<SettingsModule>(this, d->settingsModules);
}

QString SettingsModulesModel::application() const
{
    return d->appName;
}

void SettingsModulesModel::setApplication(const QString &appName)
{
    kDebug() << "setting application to" << appName;
    if (d->appName != appName) {
        d->appName = appName;
        emit applicationChanged();
        d->settingsModules.clear();
        emit settingsModulesChanged();
        d->isPopulated = false;
        d->populateTimer->start();
    }
}

bool compareModules(const SettingsModule *l, const SettingsModule *r)
{
    if (l == r) {
        return false;
    }

    if (!l) {
        return false;
    } else if (!r) {
        return true;
    }

    // base it on the category weighting; if neither has a category weight the compare
    // strings
    KConfigGroup orderConfig(KGlobal::config(), "SettingsCategoryWeights");
    const int lG = orderConfig.readEntry(l->category(), -1);
    const int rG = orderConfig.readEntry(r->category(), -1);
    //kDebug() << l->name() << l->category() << lG << " vs " << r->name() << r->category() << rG;

    if (lG < 0) {
        if (rG > 0) {
            return false;
        }

        int rv = l->category().compare(r->category(), Qt::CaseInsensitive);
        if (rv == 0) {
            rv = l->name().compare(r->name(), Qt::CaseInsensitive);
        }
        return rv < 0;
    } else if (rG < 0) {
        return true;
    }

    if (lG == rG) {
        return l->name().compare(r->name(), Qt::CaseInsensitive) < 0;
    }

    return lG > rG;
}

void SettingsModulesModel::populate()
{
    if (d->isPopulated) {
        kDebug() << "already populated.";
        return;
    }

    d->isPopulated = true;

    QString constraint;
    if (d->appName.isEmpty()) {
        constraint.append("not exist [X-KDE-ParentApp]");
    } else {
        constraint.append("[X-KDE-ParentApp] == '").append(d->appName).append("'");
    }

    KService::List services = KServiceTypeTrader::self()->query("Active/SettingsModule", constraint);
    QSet<QString> seen;
    //kDebug() << "Found " << services.count() << " modules";
    foreach (const KService::Ptr &service, services) {
        if (service->noDisplay()) {
            continue;
        }

        KPluginInfo info(service);
        if (seen.contains(info.pluginName())) {
            continue;
        }

        seen.insert(info.pluginName());
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
        item->setModule(info.pluginName());
        item->setCategory(info.category());
        d->settingsModules.append(item);
    }

    qStableSort(d->settingsModules.begin(), d->settingsModules.end(), compareModules);
    //emit dataChanged();
    emit settingsModulesChanged();
}

#include "settingsmodulesmodel.moc"
