/*
 *   SPDX-FileCopyrightText: 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
 *   SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

// Qt
#include <QAbstractListModel>
#include <QList>
#include <QObject>
#include <QSet>

#include "homescreenutils.h"

class QString;

namespace KWayland
{
namespace Client
{
class PlasmaWindowManagement;
class PlasmaWindow;
}
}

namespace PlasmaQuick
{
class AppletQuickItem;
}

class ApplicationListModel;

class ApplicationListModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(PlasmaQuick::AppletQuickItem *applet READ applet WRITE setApplet NOTIFY appletChanged)

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int favoriteCount READ favoriteCount NOTIFY favoriteCountChanged)
    Q_PROPERTY(int maxFavoriteCount READ maxFavoriteCount WRITE setMaxFavoriteCount NOTIFY maxFavoriteCountChanged)

public:
    enum LauncherLocation { Grid = 0, Favorites, Desktop };
    Q_ENUM(LauncherLocation)

    struct ApplicationData {
        QString uniqueId;
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
        ApplicationRunningRole,
        ApplicationUniqueIdRole
    };

    ApplicationListModel(QObject *parent = nullptr);
    ~ApplicationListModel() override;

    static ApplicationListModel *instance()
    {
        static ApplicationListModel *model = new ApplicationListModel;
        return model;
    }

    void loadSettings();

    int rowCount(const QModelIndex &parent = QModelIndex()) const Q_DECL_OVERRIDE;

    void moveRow(const QModelIndex &sourceParent, int sourceRow, const QModelIndex &destinationParent, int destinationChild);

    int count() const
    {
        return m_applicationList.count();
    }
    int favoriteCount() const
    {
        return m_favorites.count();
    }

    int maxFavoriteCount() const;
    void setMaxFavoriteCount(int count);

    void setApplet(PlasmaQuick::AppletQuickItem *applet);
    PlasmaQuick::AppletQuickItem *applet() const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;

    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;

    Q_INVOKABLE void setLocation(int row, LauncherLocation location);

    Q_INVOKABLE void moveItem(int row, int destination);

    Q_INVOKABLE void runApplication(const QString &storageId);

    Q_INVOKABLE virtual void loadApplications();

    Q_INVOKABLE void setMinimizedDelegate(int row, QQuickItem *delegate);
    Q_INVOKABLE void unsetMinimizedDelegate(int row, QQuickItem *delegate);

public Q_SLOTS:
    void sycocaDbChanged(const QStringList &change);
    void windowCreated(KWayland::Client::PlasmaWindow *window);

Q_SIGNALS:
    void countChanged();
    void favoriteCountChanged();
    void maxFavoriteCountChanged();
    void appletChanged();
    void launchError(const QString &msg);

protected:
    QList<ApplicationData> m_applicationList;

    PlasmaQuick::AppletQuickItem *m_applet = nullptr;
    int m_maxFavoriteCount = 0;
    QStringList m_appOrder;
    QStringList m_favorites;
    QSet<QString> m_desktopItems;
    QHash<QString, int> m_appPositions;
};
