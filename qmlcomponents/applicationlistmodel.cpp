/*
 *   Copyright (C) 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

// Self
#include "applicationlistmodel.h"

// Qt
#include <QByteArray>
#include <QModelIndex>
#include <QProcess>

// KDE
#include <KPluginInfo>
#include <KService>
#include <KServiceGroup>
#include <KServiceTypeTrader>
#include <KSycocaEntry>
#include <QDebug>

ApplicationListModel::ApplicationListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    loadApplications();
}

ApplicationListModel::~ApplicationListModel()
{
}

QHash<int, QByteArray> ApplicationListModel::roleNames() const
{
    QHash<int, QByteArray> roleNames;
    roleNames[ApplicationNameRole] = "ApplicationNameRole";
    roleNames[ApplicationIconRole] = "ApplicationIconRole";
    roleNames[ApplicationStorageIdRole] = "ApplicationStorageIdRole";
    roleNames[ApplicationEntryPathRole] = "ApplicationEntryPathRole";
    roleNames[ApplicationOriginalRowRole] = "ApplicationOriginalRowRole";

    return roleNames;
}


void ApplicationListModel::loadApplications()
{
    beginResetModel();

    KServiceGroup::Ptr group = KServiceGroup::root();
    if (!group || !group->isValid()) return;
    KServiceGroup::List subGroupList = group->entries(true);

    // Iterate over all entries in the group
    for(KServiceGroup::List::ConstIterator it = subGroupList.begin();it != subGroupList.end(); it++) {
        KSycocaEntry::Ptr groupEntry = (*it);

        if (groupEntry->isType(KST_KServiceGroup) && groupEntry->name() != "System") {
            KServiceGroup::Ptr serviceGroup(static_cast<KServiceGroup* >(groupEntry.data()));

            if (!serviceGroup->noDisplay()) {
                KServiceGroup::List entryGroupList = serviceGroup->entries(true);

                for(KServiceGroup::List::ConstIterator it = entryGroupList.begin();  it != entryGroupList.end(); it++) {
                    KSycocaEntry::Ptr entry = (*it);
                    ApplicationData data;
                    if (entry->isType(KST_KService)) {
                        KService::Ptr service(static_cast<KService* >(entry.data()));
                        if (service->isApplication()) {
                            KPluginInfo plugin(service);
                            if (!plugin.isValid()) {
                                continue;
                            }
                            data.name = plugin.name();
                            data.icon = plugin.icon();
                            data.storageId = service->storageId();
                            data.entryPath = plugin.entryPath();
                            m_applicationList << data;
                        }
                    }
                }
            }
        }
    }

    endResetModel();
    emit countChanged();
}

QVariant ApplicationListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
    case Qt::DisplayRole:
    case ApplicationNameRole:
        return m_applicationList.at(index.row()).name;
    case ApplicationIconRole:
        return m_applicationList.at(index.row()).icon;
    case ApplicationStorageIdRole:
        return m_applicationList.at(index.row()).storageId;
    case ApplicationEntryPathRole:
        return m_applicationList.at(index.row()).entryPath;
    case ApplicationOriginalRowRole:
        return index.row();

    default:
        return QVariant();
    }
}

int ApplicationListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_applicationList.count();
}

Q_INVOKABLE void ApplicationListModel::moveItem(int row, int destination)
{
    if (row < 0 || destination < 0 || row >= m_applicationList.length() ||
        destination >= m_applicationList.length() || row == destination) {
        return;
    }
    if (destination > row) {
        ++destination;
    }

    beginMoveRows(QModelIndex(), row, row, QModelIndex(), destination);
    ApplicationData data = m_applicationList.takeAt(row);
    m_applicationList.insert(destination, data);
    endMoveRows();
}

void ApplicationListModel::runApplication(const QString &storageId)
{
    if (storageId.isEmpty()) {
        return;
    }

    KService::Ptr service = KService::serviceByStorageId(storageId);

    QProcess::startDetached(service->exec());
}

#include "applicationlistmodel.moc"
