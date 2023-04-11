// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "application.h"
#include "applicationfolder.h"

#include <QAbstractListModel>
#include <QList>
#include <QObject>
#include <QQuickItem>
#include <QSet>

#include <Plasma/Applet>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

/**
 * @short The applications and folders model on the main page.
 */
class PinnedModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(Plasma::Applet *applet READ applet WRITE setApplet NOTIFY appletChanged)

public:
    enum Roles { IsFolderRole = Qt::UserRole + 1, ApplicationRole, FolderRole };

    PinnedModel(QObject *parent = nullptr);
    ~PinnedModel() override;
    static PinnedModel *self();

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addApp(const QString &storageId, int row);
    Q_INVOKABLE void addFolder(QString name, int row);
    Q_INVOKABLE void removeEntry(int row);
    Q_INVOKABLE void moveEntry(int fromRow, int toRow);

    Q_INVOKABLE void createFolderFromApps(int sourceAppRow, int draggedAppRow);
    Q_INVOKABLE void addAppToFolder(int appRow, int folderRow);

    void save();

    Plasma::Applet *applet();
    void setApplet(Plasma::Applet *applet);

public Q_SLOTS:
    void addAppFromFolder(const QString &storageId);

Q_SIGNALS:
    void appletChanged();

private:
    void load();

    QList<Application *> m_applications;
    QList<ApplicationFolder *> m_folders;

    Plasma::Applet *m_applet;
};
