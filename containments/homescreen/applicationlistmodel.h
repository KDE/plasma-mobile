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

#ifndef APPLICATIONLISTMODEL_H
#define APPLICATIONLISTMODEL_H

// Qt
#include <QObject>
#include <QAbstractListModel>
#include <QList>
#include <QSet>

#include "homescreen.h"

class QString;

namespace KWayland
{
namespace Client
{
class PlasmaWindowManagement;
class PlasmaWindow;
}
}

class ApplicationListModel;

class ApplicationListModel : public QAbstractListModel {
    Q_OBJECT

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int favoriteCount READ favoriteCount NOTIFY favoriteCountChanged)
    Q_PROPERTY(int maxFavoriteCount READ maxFavoriteCount WRITE setMaxFavoriteCount NOTIFY maxFavoriteCountChanged)

public:
    enum LauncherLocation {
        Grid = 0,
        Favorites,
        Desktop
    };
    Q_ENUM(LauncherLocation)

    struct ApplicationData {
        QString name;
        QString icon;
        QString storageId;
        QString entryPath;
        LauncherLocation location = LauncherLocation::Grid;
        bool startupNotify = true;
        KWayland::Client::PlasmaWindow *window = nullptr;
    };

    enum Roles {
        ApplicationNameRole = Qt::UserRole + 1,
        ApplicationIconRole,
        ApplicationStorageIdRole,
        ApplicationEntryPathRole,
        ApplicationOriginalRowRole,
        ApplicationStartupNotifyRole,
        ApplicationLocationRole,
        ApplicationRunningRole
    };

    ApplicationListModel(HomeScreen *parent = nullptr);
    ~ApplicationListModel() override;

    void loadSettings();

    int rowCount(const QModelIndex &parent = QModelIndex()) const Q_DECL_OVERRIDE;

    void moveRow(const QModelIndex &sourceParent, int sourceRow, const QModelIndex &destinationParent, int destinationChild);

    int count() const { return m_applicationList.count(); }
    int favoriteCount() const { return m_favorites.count();}

    int maxFavoriteCount() const;
    void setMaxFavoriteCount(int count);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;

    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;

    Q_INVOKABLE void setLocation(int row, LauncherLocation location);

    Q_INVOKABLE void moveItem(int row, int destination);

    Q_INVOKABLE void runApplication(const QString &storageId);

    Q_INVOKABLE void loadApplications();

    Q_INVOKABLE void setMinimizedDelegate(int row, QQuickItem *delegate);
    Q_INVOKABLE void unsetMinimizedDelegate(int row, QQuickItem *delegate);

public Q_SLOTS:
     void sycocaDbChanged(const QStringList &change);

Q_SIGNALS:
    void countChanged();
    void favoriteCountChanged();
    void maxFavoriteCountChanged();

private:
    void initWayland();

    QList<ApplicationData> m_applicationList;

    KWayland::Client::PlasmaWindowManagement *m_windowManagement = nullptr;
    HomeScreen *m_homeScreen = nullptr;
    int m_maxFavoriteCount = 0;
    QStringList m_appOrder;
    QStringList m_favorites;
    QSet<QString> m_desktopItems;
    QHash<QString, int> m_appPositions;
};

#endif // APPLICATIONLISTMODEL_H
