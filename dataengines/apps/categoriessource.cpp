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

#include "categoriessource.h"

#include <KDebug>
#include <KServiceTypeTrader>
#include <KSycoca>

CategoriesSource::CategoriesSource(const QString &name, QObject *parent)
    : Plasma::DataContainer(parent)
{
    setObjectName(name);

    populate();
    connect(KSycoca::self(), SIGNAL(databaseChanged(QStringList)), this, SLOT(sycocaChanged(QStringList)));
}

CategoriesSource::~CategoriesSource()
{
}

void CategoriesSource::sycocaChanged(const QStringList &changes)
{
    if (changes.contains("apps") || changes.contains("xdgdata-apps")) {
        populate();
    }
}

void CategoriesSource::populate()
{
    QString query = "exist Exec";

    //openSUSE: exclude YaST modules from the list
    query += " and (not (exist Categories and 'X-SuSE-YaST' in Categories))";

    KService::List services = KServiceTypeTrader::self()->query("Application", query);

    removeAllData();

    QMap<QString, int> categoryWeights;

    foreach (const KService::Ptr &service, services) {
        if (service->noDisplay()) {
            continue;
        }

        foreach (const QString &category, service->categories()) {
            categoryWeights[category] = categoryWeights[category]+1;
        }
    }


    QMap<QString, int>::const_iterator i = categoryWeights.constBegin();
    while (i != categoryWeights.constEnd()) {
        if (i.key().startsWith("X-") || i.key() == "KDE" || i.key() == "GNOME" || i.key() == "GTK" || i.key() == "Qt") {
            ++i;
            continue;
        }

        Plasma::DataEngine::Data data;
        data["name"] = i.key();
        data["items"] = i.value();

        setData(i.key(), data);

        ++i;
    }

    checkForUpdate();
}

#include "categoriessource.moc"
