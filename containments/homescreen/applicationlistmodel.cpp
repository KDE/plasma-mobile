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
#include <KShell>
#include <KIOWidgets/KRun>
#include <QDebug>


ApplicationListModel::ApplicationListModel(HomeScreen *parent)
    : QSortFilterProxyModel(parent),
      m_homeScreen(parent)
{
    loadSettings();
}

ApplicationListModel::~ApplicationListModel()
= default;

void ApplicationListModel::loadSettings()
{
    m_favorites = m_homeScreen->config().readEntry("Favorites", QStringList());
    m_desktopItems = m_homeScreen->config().readEntry("DesktopItems", QStringList()).toSet();
    m_appOrder = m_homeScreen->config().readEntry("AppOrder", QStringList());
    m_maxFavoriteCount = m_homeScreen->config().readEntry("MaxFavoriteCount", 5);

    int i = 0;
    for (auto app : m_appOrder) {
        m_appPositions[app] = i;
        ++i;
    }
}

QHash<int, QByteArray> ApplicationListModel::roleNames() const
{
    QHash<int, QByteArray> roleNames;
    if (sourceModel()) {
        roleNames = sourceModel()->roleNames();
    }
    
    roleNames[SortKeyRole] = "SortKeyRole";
    roleNames[ApplicationLocationRole] = "ApplicationLocationRole";

    const_cast<ApplicationListModel *>(this)->m_urlRole = roleNames.key("url");

    return roleNames;
}


QVariant ApplicationListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
    case SortKeyRole: {
        const QString url = QSortFilterProxyModel::data(index, m_urlRole).toString();
        if (m_appOrder.contains(url)) {
            return QString::number(m_appOrder.indexOf(url)) + QStringLiteral("_") + QSortFilterProxyModel::data(index, Qt::DisplayRole).toString();
        } else {
            return QStringLiteral("z_") + QSortFilterProxyModel::data(index, Qt::DisplayRole).toString();
        }
    }

    case ApplicationLocationRole: {
        const QString url = QSortFilterProxyModel::data(index, m_urlRole).toString();
        if (m_favorites.contains(url)) {
            return Favorites;
        } else if (m_desktopItems.contains(url)) {
            return Desktop;
        } else {
            return Grid;
        }
    }

    default:
        return QSortFilterProxyModel::data(index, role);
    }
}

//TODO: remove?
Qt::ItemFlags ApplicationListModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return nullptr;
    return Qt::ItemIsDragEnabled|QSortFilterProxyModel::flags(index);
}


void ApplicationListModel::setLocation(int row, LauncherLocation location)
{
    if (row < 0 || row >= rowCount()) {
        return;
    }

    const QString url = data(index(row, 0), m_urlRole).toString();

    if (url.isEmpty()) {
        return;
    }

    if (location == Favorites && !m_favorites.contains(url)) {
        qWarning()<<"favoriting"<<row;
        // Deny favorites when full
        if (row >= m_maxFavoriteCount || m_favorites.count() >= m_maxFavoriteCount) {
            return;
        }

        m_favorites.insert(row, url);

        m_homeScreen->config().writeEntry("Favorites", m_favorites);
        emit favoriteCountChanged();

    // Out of favorites
    } else  if (m_favorites.contains(url)) {
        m_favorites.removeAll(url);
        m_homeScreen->config().writeEntry("Favorites", m_favorites);
        emit favoriteCountChanged();
    }

    // In Desktop
    if (location == Desktop && m_desktopItems.contains(url)) {
        m_desktopItems.insert(url);
        m_homeScreen->config().writeEntry("DesktopItems", m_desktopItems.toList());

    // Out of Desktop
    } else  if (m_desktopItems.contains(url)) {
        m_desktopItems.remove(url);
        m_homeScreen->config().writeEntry("DesktopItems", m_desktopItems.toList());
    }

    emit m_homeScreen->configNeedsSaving();
    emit dataChanged(index(row, 0), index(row, 0));
}

void ApplicationListModel::moveItem(int row, int destination)
{
    if (row < 0 || destination < 0 || row >= rowCount() ||
        destination >= rowCount() || row == destination) {
        return;
    }
    if (destination > row) {
        ++destination;
    }

    const QString url = data(index(row, 0), m_urlRole).toString();

    if (url.isEmpty()) {
        return;
    }

    if (m_appOrder.length() < qMax(row, destination)) {
        for (int i = m_appOrder.length(); i <= qMax(row, destination); ++i) {
            m_appOrder << data(index(i, 0), m_urlRole).toString();
        }
    }
    if (destination > row) {
        m_appOrder.insert(destination, url);
        m_appOrder.takeAt(row);

    } else {
        m_appOrder.takeAt(row);
        m_appOrder.insert(destination, url);
    }

    m_homeScreen->config().writeEntry("AppOrder", m_appOrder);
}

void ApplicationListModel::runApplication(const QString &storageId)
{
    if (storageId.isEmpty()) {
        return;
    }

    KService::Ptr service = KService::serviceByStorageId(storageId);

    KRun::runService(*service, QList<QUrl>(), nullptr);
}

int ApplicationListModel::maxFavoriteCount() const
{
    return m_maxFavoriteCount;
}

void ApplicationListModel::setMaxFavoriteCount(int count)
{
    if (m_maxFavoriteCount == count) {
        return;
    }

    if (m_maxFavoriteCount > count) {
        while (m_favorites.size() > count && m_favorites.count() > 0) {
            m_favorites.pop_back();
        }
        emit favoriteCountChanged();
/*TODO
        int i = 0;
        for (auto &app : m_applicationList) {
            if (i >= count && app.location == Favorites) {
                app.location = Grid;
                emit dataChanged(index(i, 0), index(i, 0));
            }
            ++i;
        }*/
    }

    m_maxFavoriteCount = count;
    m_homeScreen->config().writeEntry("MaxFavoriteCount", m_maxFavoriteCount);

    emit maxFavoriteCountChanged();
}

#include "moc_applicationlistmodel.cpp"

