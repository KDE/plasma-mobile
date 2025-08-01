// SPDX-FileCopyrightText: 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QObject>
#include <QQuickItem>
#include <QSet>

#include <KService>

#include "foliodelegate.h"
#include "homescreen.h"

class HomeScreen;
class FolioDelegate;

/**
 * @short The base application list, used directly by the app drawer.
 */
class ApplicationListModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")

public:
    enum Roles {
        DelegateRole = Qt::UserRole + 1,
        NameRole,
    };

    ApplicationListModel(HomeScreen *parent = nullptr);
    ~ApplicationListModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const Q_DECL_OVERRIDE;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;

    void load();

Q_SIGNALS:
    // Emitted when an application was detected to have been removed from the system
    void applicationRemoved(QString storageId);

public Q_SLOTS:
    void sycocaDbChanged();

protected:
    KService::List queryApplications();

    HomeScreen *m_homeScreen{nullptr};

    QList<std::shared_ptr<FolioDelegate>> m_delegates;
    QTimer *m_reloadAppsTimer{nullptr};
};

class ApplicationListSearchModel : public QSortFilterProxyModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")

public:
    ApplicationListSearchModel(HomeScreen *parent = nullptr, ApplicationListModel *model = nullptr);
};
