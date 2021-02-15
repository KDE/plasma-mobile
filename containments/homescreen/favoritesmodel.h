/*
 *   Copyright (C) 2021 Marco Martin <mart@kde.org>
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

#pragma once

// Qt
#include <QObject>
#include <QAbstractListModel>
#include <QList>
#include <QSet>

#include "homescreen.h"
#include "applicationlistmodel.h"

class QString;

namespace KWayland
{
namespace Client
{
class PlasmaWindowManagement;
class PlasmaWindow;
}
}

class FavoritesModel;

class FavoritesModel : public ApplicationListModel {
    Q_OBJECT

public:
    FavoritesModel(HomeScreen *parent = nullptr);
    ~FavoritesModel() override;


    QString storageToUniqueId(const QString &storageId) const;
    QString uniqueToStorageId(const QString &uniqueId) const;

    Q_INVOKABLE void addFavorite(const QString &storageId, int row, LauncherLocation location);
    Q_INVOKABLE void removeFavorite(int row);

    Q_INVOKABLE void loadApplications() override;


};

