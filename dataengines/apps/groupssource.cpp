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
 * GNU Library General Public License for more details
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "groupssource.h"

#include <KDebug>
#include <KServiceTypeTrader>
#include <KSycoca>

int GroupsSource::s_depth = 0;

GroupsSource::GroupsSource(const QString &name, QObject *parent)
    : Plasma::DataContainer(parent),
      m_maxDepth(-1)
{
    setObjectName(name);

    QStringList split = name.split(':');
    if (split.length() >= 2) {
        m_group = split[1];
    }
    if (split.length() == 3) {
        m_maxDepth = split[2].toInt();
    }

    if (m_group.isEmpty()) {
        m_group = "/";
    }

    populate();
    connect(KSycoca::self(), SIGNAL(databaseChanged(QStringList)), this, SLOT(sycocaChanged(QStringList)));
}

GroupsSource::~GroupsSource()
{
}

void GroupsSource::sycocaChanged(const QStringList &changes)
{
    if (changes.contains("apps") || changes.contains("xdgdata-apps")) {
        populate();
    }
}

void GroupsSource::populate()
{
    KServiceGroup::Ptr group = KServiceGroup::group(m_group);

    s_depth = 0;
    removeAllData();
    loadGroup(group);
    checkForUpdate();
}

void GroupsSource::loadGroup(KServiceGroup::Ptr group)
{
    if (m_maxDepth >= 0 && s_depth > m_maxDepth) {
        return;
    }
    ++s_depth;

    if (group && group->isValid()) {
        KServiceGroup::List list = group->entries();

        for( KServiceGroup::List::ConstIterator it = list.constBegin();
             it != list.constEnd(); it++) {
            const KSycocaEntry::Ptr p = (*it);

            if (p->isType(KST_KServiceGroup)) {
                const KServiceGroup::Ptr subGroup = KServiceGroup::Ptr::staticCast(p);

                Plasma::DataEngine::Data data;
                data["iconName"] = subGroup->icon();
                data["name"] = subGroup->name();
                data["description"] = subGroup->comment();
                data["relPath"] = subGroup->relPath();
                data["display"] = !subGroup->noDisplay();
                data["childCount"] = subGroup->childCount();
                setData(subGroup->relPath(), data);

                if (!subGroup->noDisplay() && subGroup->childCount() > 0) {
                    loadGroup(subGroup);
                }
            }
        }
    }
}

#include "groupssource.moc"
