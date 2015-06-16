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
#include <KSharedConfig>
#include <KSycoca>
#include <KSycocaEntry>
#include <QDebug>

ApplicationListModel::ApplicationListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    //can't use the new syntax as this signal is overloaded
    connect(KSycoca::self(), SIGNAL(databaseChanged(const QStringList &)),
            this, SLOT(sycocaDbChanged(const QStringList &)));
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

void ApplicationListModel::sycocaDbChanged(const QStringList &changes)
{
    if (!changes.contains("apps") && !changes.contains("xdgdata-apps")) {
        return;
    }

    m_applicationList.clear();

    loadApplications();
}

bool appNameLessThan(const ApplicationData &a1, const ApplicationData &a2)
{
    return a1.name.toLower() < a2.name.toLower();
}

void ApplicationListModel::loadApplications()
{
    auto cfg = KSharedConfig::openConfig("applications-blacklistrc");
    auto blgroup = KConfigGroup(cfg, QStringLiteral("Applications"));
    QStringList blacklist = blgroup.readEntry("blacklist", QStringList());

    beginResetModel();

    m_applicationList.clear();

    KServiceGroup::Ptr group = KServiceGroup::root();
    if (!group || !group->isValid()) return;
    KServiceGroup::List subGroupList = group->entries(true);

    QMap<int, ApplicationData> orderedList;
    QList<ApplicationData> unorderedList;

    // Iterate over all entries in the group
    for(KServiceGroup::List::ConstIterator it = subGroupList.begin();it != subGroupList.end(); it++) {
        KSycocaEntry::Ptr groupEntry = (*it);

        if (groupEntry->isType(KST_KServiceGroup) && groupEntry->name() != "System/" && groupEntry->name() != "Settingsmenu/") {
            KServiceGroup::Ptr serviceGroup(static_cast<KServiceGroup* >(groupEntry.data()));

            if (!serviceGroup->noDisplay()) {
                KServiceGroup::List entryGroupList = serviceGroup->entries(true);

                for(KServiceGroup::List::ConstIterator it = entryGroupList.begin();  it != entryGroupList.end(); it++) {
                    KSycocaEntry::Ptr entry = (*it);
                    ApplicationData data;

                    if (entry->property("Exec").isValid()) {
                        KService::Ptr service(static_cast<KService* >(entry.data()));
                        if (service->isApplication() &&
                            !blacklist.contains(service->desktopEntryName() + QStringLiteral(".desktop")) &&
                            !service->showOnCurrentPlatform() &&
                            !service->property("Terminal", QVariant::Bool).toBool()) {

                            data.name = service->name();
                            data.icon = service->icon();
                            data.storageId = service->storageId();
                            data.entryPath = service->exec();

                            if (m_appPositions.contains(service->storageId())) {
                                orderedList[m_appPositions.value(service->storageId())] = data;
                            } else {
                                unorderedList << data;
                            }
                        }
                    }
                }
            }
        }
    }

    std::sort(unorderedList.begin(), unorderedList.end(), appNameLessThan);
    m_applicationList << orderedList.values();
    m_applicationList << unorderedList;

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

Qt::ItemFlags ApplicationListModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return 0;
    return Qt::ItemIsDragEnabled|QAbstractItemModel::flags(index);
}

int ApplicationListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_applicationList.count();
}

void ApplicationListModel::moveRow(const QModelIndex &sourceParent, int sourceRow, const QModelIndex &destinationParent, int destinationChild)
{
    moveItem(sourceRow, destinationChild);
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
    if (destination > row) {
        ApplicationData data = m_applicationList.at(row);
        m_applicationList.insert(destination, data);
        m_applicationList.takeAt(row);
    } else {
        ApplicationData data = m_applicationList.takeAt(row);
        m_applicationList.insert(destination, data);
    }


    m_appOrder.clear();
    m_appPositions.clear();
    int i = 0;
    for (auto app : m_applicationList) {
        m_appOrder << app.storageId;
        m_appPositions[app.storageId] = i;
        ++i;
    }


    emit appOrderChanged();
    endMoveRows();
}

void ApplicationListModel::runApplication(const QString &storageId)
{
    if (storageId.isEmpty()) {
        return;
    }

    KService::Ptr service = KService::serviceByStorageId(storageId);

    //ignore parameters like %u
    QProcess::startDetached(service->exec().replace(QRegExp("%\\w"), ""));
}

QStringList ApplicationListModel::appOrder() const
{
    return m_appOrder;
}

void ApplicationListModel::setAppOrder(const QStringList &order)
{
    if (m_appOrder == order) {
        return;
    }

    m_appOrder = order;
    m_appPositions.clear();
    int i = 0;
    for (auto app : m_appOrder) {
        m_appPositions[app] = i;
        ++i;
    }
    emit appOrderChanged();
}

#include "applicationlistmodel.moc"
