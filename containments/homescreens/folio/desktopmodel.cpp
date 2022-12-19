// SPDX-FileCopyrightText: 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

// Self
#include "desktopmodel.h"

// Qt
#include <QByteArray>
#include <QDebug>
#include <QModelIndex>

// KDE
#include <KService>
#include <KSharedConfig>

#include <PlasmaQuick/AppletQuickItem>

const int MAX_FAVORITES = 5;

DesktopModel::DesktopModel(QObject *parent, Plasma::Applet *applet)
    : ApplicationListModel(parent)
    , m_applet{applet}
{
}

DesktopModel::~DesktopModel() = default;

QString DesktopModel::storageToUniqueId(const QString &storageId) const
{
    if (storageId.isEmpty()) {
        return storageId;
    }

    int id = 0;
    QString uniqueId = storageId + QStringLiteral("-") + QString::number(id);

    while (m_appOrder.contains(uniqueId)) {
        uniqueId = storageId + QStringLiteral("-") + QString::number(++id);
    }

    return uniqueId;
}

QString DesktopModel::uniqueToStorageId(const QString &uniqueId) const
{
    if (uniqueId.isEmpty()) {
        return uniqueId;
    }

    return uniqueId.split(QLatin1Char('-')).first();
}

void DesktopModel::loadSettings()
{
    if (!m_applet) {
        return;
    }
    m_favorites = m_applet->config().readEntry("Favorites", QStringList());
    const auto di = m_applet->config().readEntry("DesktopItems", QStringList());
    m_desktopItems = QSet<QString>(di.begin(), di.end());
    m_appOrder = m_applet->config().readEntry("AppOrder", QStringList());

    int i = 0;
    for (const QString &app : qAsConst(m_appOrder)) {
        m_appPositions[app] = i;
        ++i;
    }
}

void DesktopModel::load()
{
    loadSettings();

    // load applications
    beginResetModel();

    m_applicationList.clear();

    QSet<QString> appsToRemove;

    for (const auto &uniqueId : m_appOrder) {
        const QString storageId = uniqueToStorageId(uniqueId);
        if (KService::Ptr service = KService::serviceByStorageId(storageId)) {
            ApplicationData data;
            data.name = service->name();
            data.icon = service->icon();
            data.storageId = service->storageId();
            data.uniqueId = uniqueId;
            data.entryPath = service->exec();
            data.startupNotify = service->property(QStringLiteral("StartupNotify")).toBool();

            if (m_favorites.contains(uniqueId)) {
                data.location = Favorites;
            } else if (m_desktopItems.contains(uniqueId)) {
                data.location = Desktop;
            }

            m_applicationList << data;
        } else {
            appsToRemove.insert(uniqueId);
        }
    }

    bool favChanged = false;

    for (const auto &uniqueId : appsToRemove) {
        m_appOrder.removeAll(uniqueId);
        if (m_favorites.contains(uniqueId)) {
            favChanged = true;
            m_favorites.removeAll(uniqueId);
        }
        m_desktopItems.remove(uniqueId);
    }

    endResetModel();

    Q_EMIT countChanged();

    if (m_applet) {
        m_applet->config().writeEntry("Favorites", m_favorites);
        m_applet->config().writeEntry("AppOrder", m_appOrder);
        m_applet->config().writeEntry("DesktopItems", m_desktopItems.values());
        Q_EMIT m_applet->configNeedsSaving();
    }

    if (favChanged) {
        Q_EMIT favoriteCountChanged();
    }
}

int DesktopModel::count()
{
    return m_applicationList.count();
}

int DesktopModel::favoriteCount()
{
    return m_favorites.count();
}

int DesktopModel::maxFavoriteCount()
{
    return MAX_FAVORITES;
}

void DesktopModel::setLocation(int row, LauncherLocation location)
{
    if (row < 0 || row >= m_applicationList.length()) {
        return;
    }

    ApplicationData data = m_applicationList.at(row);
    if (data.location == location) {
        return;
    }

    if (location == Favorites) {
        qWarning() << "favoriting" << row << data.name;
        // Deny favorites when full
        if (row >= maxFavoriteCount() || m_favorites.count() >= maxFavoriteCount() || m_favorites.contains(data.uniqueId)) {
            return;
        }

        m_favorites.insert(row, data.uniqueId);

        if (m_applet) {
            m_applet->config().writeEntry("Favorites", m_favorites);
        }
        Q_EMIT favoriteCountChanged();

        // Out of favorites
    } else if (data.location == Favorites) {
        m_favorites.removeAll(data.uniqueId);
        if (m_applet) {
            m_applet->config().writeEntry("Favorites", m_favorites);
        }
        Q_EMIT favoriteCountChanged();
    }

    // In Desktop
    if (location == Desktop) {
        m_desktopItems.insert(data.uniqueId);
        if (m_applet) {
            m_applet->config().writeEntry("DesktopItems", m_desktopItems.values());
        }

        // Out of Desktop
    } else if (data.location == Desktop) {
        m_desktopItems.remove(data.uniqueId);
        if (m_applet) {
            m_applet->config().writeEntry(QStringLiteral("DesktopItems"), m_desktopItems.values());
        }
    }

    data.location = location;
    if (m_applet) {
        Q_EMIT m_applet->configNeedsSaving();
    }
    Q_EMIT dataChanged(index(row, 0), index(row, 0));
}

void DesktopModel::moveItem(int row, int destination)
{
    if (row < 0 || destination < 0 || row >= m_applicationList.length() || destination >= m_applicationList.length() || row == destination) {
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
    for (const ApplicationData &app : qAsConst(m_applicationList)) {
        m_appOrder << app.uniqueId;
        m_appPositions[app.uniqueId] = i;
        ++i;
    }

    if (m_applet) {
        m_applet->config().writeEntry("AppOrder", m_appOrder);
    }

    endMoveRows();
}

void DesktopModel::addFavorite(const QString &storageId, int row, LauncherLocation location)
{
    if (row < 0 || row > m_applicationList.count()) {
        return;
    }

    if (KService::Ptr service = KService::serviceByStorageId(storageId)) {
        const QString uniqueId = storageToUniqueId(service->storageId());
        ApplicationData data;
        data.name = service->name();
        data.icon = service->icon();
        data.storageId = service->storageId();
        data.uniqueId = uniqueId;
        data.entryPath = service->exec();
        data.startupNotify = service->property(QStringLiteral("StartupNotify")).toBool();

        bool favChanged = false;
        if (location == Favorites) {
            data.location = Favorites;
            m_favorites.insert(qMin(row, m_favorites.count()), uniqueId);
            favChanged = true;
        } else {
            data.location = location;
            m_desktopItems.insert(data.uniqueId);
        }

        beginInsertRows(QModelIndex(), row, row);
        m_applicationList.insert(row, data);
        m_appOrder.insert(row, uniqueId);
        endInsertRows();
        if (favChanged) {
            Q_EMIT favoriteCountChanged();
        }

        if (m_applet) {
            m_applet->config().writeEntry("Favorites", m_favorites);
            m_applet->config().writeEntry("AppOrder", m_appOrder);
            m_applet->config().writeEntry("DesktopItems", m_desktopItems.values());
            Q_EMIT m_applet->configNeedsSaving();
        }
    }
}

void DesktopModel::removeFavorite(int row)
{
    if (row < 0 || row >= m_applicationList.count()) {
        return;
    }

    beginRemoveRows(QModelIndex(), row, row);
    const QString uniqueId = m_applicationList[row].uniqueId;
    m_appOrder.removeAll(uniqueId);

    const bool favChanged = m_favorites.contains(uniqueId);
    m_favorites.removeAll(uniqueId);
    m_desktopItems.remove(uniqueId);
    m_appPositions.remove(uniqueId);
    m_applicationList.removeAt(row);
    endRemoveRows();

    if (favChanged) {
        Q_EMIT favoriteCountChanged();
    }

    if (m_applet) {
        m_applet->config().writeEntry("Favorites", m_favorites);
        m_applet->config().writeEntry("AppOrder", m_appOrder);
        m_applet->config().writeEntry("DesktopItems", m_desktopItems.values());
        Q_EMIT m_applet->configNeedsSaving();
    }
}
