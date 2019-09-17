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
#include <QSortFilterProxyModel>
#include <QList>

#include "homescreen.h"

class QString;

class ApplicationListModel;

class ApplicationListModel : public QSortFilterProxyModel {
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

    enum Roles {
        SortKeyRole = Qt::UserRole + 100,
        ApplicationLocationRole
    };

    ApplicationListModel(HomeScreen *parent = nullptr);
    ~ApplicationListModel() override;

    void loadSettings();

    int count() const { return rowCount(); }
    int favoriteCount() const { return m_favorites.count();}

    int maxFavoriteCount() const;
    void setMaxFavoriteCount(int count);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;

    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;

    Q_INVOKABLE void setLocation(int row, LauncherLocation location);

    Q_INVOKABLE void moveItem(int row, int order);

    Q_INVOKABLE void runApplication(const QString &storageId);

public Q_SLOTS:

Q_SIGNALS:
    void countChanged();
    void favoriteCountChanged();
    void maxFavoriteCountChanged();

private:
    HomeScreen *m_homeScreen = nullptr;
    int m_maxFavoriteCount = 0;
    int m_urlRole = 0;
    QStringList m_appOrder;
    QStringList m_favorites;
    QSet<QString> m_desktopItems;
    QHash<QString, int> m_appPositions;
};

#endif // APPLICATIONLISTMODEL_H
