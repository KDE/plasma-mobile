// SPDX-FileCopyrightText: 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QObject>
#include <QQuickItem>
#include <QSet>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

/**
 * @short The base application list, used directly by the app drawer.
 *
 * Items that are displayed on the desktop/pinned are done by DesktopModel, which is a subclass.
 */
class ApplicationListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    // this enum is solely used by DesktopModel
    enum LauncherLocation { None = 0, Favorites, Desktop };
    Q_ENUM(LauncherLocation)

    struct ApplicationData {
        QString uniqueId;
        QString name;
        QString icon;
        QString storageId;
        QString entryPath;
        bool startupNotify = true;
        KWayland::Client::PlasmaWindow *window = nullptr;
        LauncherLocation location = LauncherLocation::None; // only for DesktopModel
    };

    enum Roles {
        ApplicationNameRole = Qt::UserRole + 1,
        ApplicationIconRole,
        ApplicationStorageIdRole,
        ApplicationEntryPathRole,
        ApplicationStartupNotifyRole,
        ApplicationRunningRole,
        ApplicationUniqueIdRole,
        ApplicationLocationRole // only valid for DesktopModel
    };

    ApplicationListModel(QObject *parent = nullptr);
    ~ApplicationListModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const Q_DECL_OVERRIDE;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;

    Q_INVOKABLE virtual void load();

    Q_INVOKABLE void setMinimizedDelegate(int row, QQuickItem *delegate);
    Q_INVOKABLE void unsetMinimizedDelegate(int row, QQuickItem *delegate);

public Q_SLOTS:
    void sycocaDbChanged();
    void windowCreated(KWayland::Client::PlasmaWindow *window);

Q_SIGNALS:
    void launchError(const QString &msg);

protected:
    QList<ApplicationData> m_applicationList;

    KWayland::Client::PlasmaWindowManagement *m_windowManagement = nullptr;
};
