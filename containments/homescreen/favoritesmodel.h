/*
 *   SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

// Qt
#include <QAbstractListModel>
#include <QList>
#include <QObject>
#include <QSet>

#include "applicationlistmodel.h"
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

class FavoritesModel;

class FavoritesModel : public ApplicationListModel
{
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
