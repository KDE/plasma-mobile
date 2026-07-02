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
#include <KServiceGroup>

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
    Q_PROPERTY(QStringList categories READ categories NOTIFY categoriesChanged)

public:
    enum Roles {
        DelegateRole = Qt::UserRole + 1,
        NameRole,
        CategoryRole,
    };

    explicit ApplicationListModel(HomeScreen *parent = nullptr);
    ~ApplicationListModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QStringList categories() const
    {
        return m_categories;
    }
    void load();

Q_SIGNALS:
    // Emitted when an application was detected to have been removed from the system
    void applicationRemoved(QString storageId);

    void categoriesChanged();

public Q_SLOTS:
    void sycocaDbChanged();

private:
    void fetchAppsFromMenu(const KServiceGroup::Ptr &group,
                           const QString &categoryName,
                           const QStringList &blacklist,
                           QMap<QString, std::pair<KService::Ptr, QStringList>> &appsMap,
                           QStringList &orderedCategories);

    HomeScreen *m_homeScreen{nullptr};
    QList<std::shared_ptr<FolioDelegate>> m_delegates;
    QTimer *m_reloadAppsTimer{nullptr};
    QStringList m_categories;
};

class ApplicationListSearchModel : public QSortFilterProxyModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString categoryFilter READ categoryFilter WRITE setCategoryFilter NOTIFY categoryFilterChanged)
    Q_PROPERTY(QString searchString READ searchString WRITE setSearchString NOTIFY searchStringChanged)

public:
    explicit ApplicationListSearchModel(QObject *parent = nullptr);

    QString categoryFilter() const
    {
        return m_categoryFilter;
    }
    void setCategoryFilter(const QString &category);

    QString searchString() const {
        return m_searchString;
    }
    void setSearchString(const QString &search);

Q_SIGNALS:
    void categoryFilterChanged();
    void searchStringChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:
    QString m_categoryFilter;
    QString m_searchString;
};
