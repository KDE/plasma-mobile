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

#include "groupsource.h"

#include <KDebug>
#include <KServiceTypeTrader>
#include <KSycoca>

GroupSource::GroupSource(const QString &name, QObject *parent)
    : Plasma::DataContainer(parent)
{
    setObjectName(name);

    QStringList split = name.split(':');
    if (split.length() == 2) {
        m_group = split.last();
    }

    if (m_group.isEmpty()) {
        m_group = "/";
    }

    populate();
    connect(KSycoca::self(), SIGNAL(databaseChanged(QStringList)), this, SLOT(sycocaChanged(QStringList)));
}

GroupSource::~GroupSource()
{
}

void GroupSource::sycocaChanged(const QStringList &changes)
{
    if (changes.contains("apps") || changes.contains("xdgdata-apps")) {
        populate();
    }
}

void GroupSource::populate()
{
    KServiceGroup::Ptr group = KServiceGroup::group(m_group);

    removeAllData();
    loadGroup(group);
    checkForUpdate();
}

void GroupSource::loadGroup(KServiceGroup::Ptr group)
{
    if (group && group->isValid()) {
        KServiceGroup::List list = group->entries();

        for( KServiceGroup::List::ConstIterator it = list.constBegin();
             it != list.constEnd(); it++) {
            const KSycocaEntry::Ptr p = (*it);

            if (p->isType(KST_KService)) {
                const KService::Ptr service = KService::Ptr::staticCast(p);

                if (!service->noDisplay()) {
                    QString genericName = service->genericName();
                    if (genericName.isNull()) {
                        genericName = service->comment();
                    }
                    QString description;
                    if (!service->genericName().isEmpty() && service->genericName() != service->name()) {
                        description = service->genericName();
                    } else if (!service->comment().isEmpty()) {
                        description = service->comment();
                    }
                    Plasma::DataEngine::Data data;
                    data["iconName"] = service->icon();
                    data["name"] = service->name();
                    data["genericName"] = service->genericName();
                    data["description"] = description;
                    data["storageId"] = service->storageId();
                    data["entryPath"] = service->entryPath();
                    setData(service->storageId(), data);
                }

            } else if (p->isType(KST_KServiceGroup)) {
                const KServiceGroup::Ptr subGroup = KServiceGroup::Ptr::staticCast(p);

                if (!subGroup->noDisplay() && subGroup->childCount() > 0) {
                    loadGroup(subGroup);
                }
            }
        }
    }
}

#include "groupsource.moc"
