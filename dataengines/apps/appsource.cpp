/*
 * Copyright 2009 Chani Armitage <chani@kde.org>
 * Copyright 2011 Marco Martin <mart@kde.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License version 2 as
 * published by the Free Software Foundation
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "appsource.h"

#include <KDebug>
#include <KServiceTypeTrader>
#include <KSycoca>

AppSource::AppSource(const QString &name, QObject *parent)
    : Plasma::DataContainer(parent)
{
    setObjectName(name);

    QStringList names = name.split(':');
    if (names.length() == 2) {
        m_categories = names.last().split('|');
    }

    KSharedConfigPtr ptr = KSharedConfig::openConfig("active-blacklistrc");
    KConfigGroup config = KConfigGroup(ptr, "blacklist");
    m_blackList = config.readEntry("apps", QStringList());
    populate();
    connect(KSycoca::self(), SIGNAL(databaseChanged(QStringList)), this, SLOT(sycocaChanged(QStringList)));
}

AppSource::~AppSource()
{
}

void AppSource::sycocaChanged(const QStringList &changes)
{
    if (changes.contains("apps") || changes.contains("xdgdata-apps")) {
        populate();
    }
}

void AppSource::populate()
{
    QString query = "exist Exec";

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

    //openSUSE: exclude YaST modules from the list
    query += " and (not (exist Categories and 'X-SuSE-YaST' in Categories))";

    // Filter out blacklisted apps as to not show too much crap
    foreach (const QString appName, m_blackList) {
        query += QString(" and (DesktopEntryName != '%1' )").arg(appName);
    }
    kWarning()<<query;
    KService::List services = KServiceTypeTrader::self()->query("Application", query);

    removeAllData();
    Plasma::DataEngine::Data data;

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

        data["iconName"] = service->icon();
        data["name"] = service->name();
        data["genericName"] = service->genericName();
        data["description"] = description;
        data["storageId"] = service->storageId();
        data["entryPath"] = service->entryPath();
        setData(service->storageId(), data);
    }

    checkForUpdate();
}

#include "appsource.moc"
