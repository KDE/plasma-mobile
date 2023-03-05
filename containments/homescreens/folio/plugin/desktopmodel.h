// SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

// Qt
#include <QAbstractListModel>
#include <QList>
#include <QObject>
#include <QSet>

// KDE
#include <Plasma/Applet>

#include "applicationlistmodel.h"

/**
 * @short Filtered application list for applications on the desktop and pinned bar.
 */
class DesktopModel : public ApplicationListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int favoriteCount READ favoriteCount NOTIFY favoriteCountChanged)
    Q_PROPERTY(int maxFavoriteCount READ maxFavoriteCount CONSTANT)

public:
    DesktopModel(QObject *parent = nullptr, Plasma::Applet *applet = nullptr);
    ~DesktopModel() override;

    QString storageToUniqueId(const QString &storageId) const;
    QString uniqueToStorageId(const QString &uniqueId) const;

    void loadSettings();

    int count();
    int favoriteCount();
    int maxFavoriteCount();

    Q_INVOKABLE void setLocation(int row, LauncherLocation location);
    Q_INVOKABLE void moveItem(int row, int destination);

    Q_INVOKABLE void addFavorite(const QString &storageId, int row, LauncherLocation location);
    Q_INVOKABLE void removeFavorite(int row);

Q_SIGNALS:
    void countChanged();
    void favoriteCountChanged();

private:
    void load() override;

    QStringList m_appOrder;
    QStringList m_favorites;
    QSet<QString> m_desktopItems;
    QHash<QString, int> m_appPositions;

    Plasma::Applet *m_applet = nullptr;
};
