// SPDX-FileCopyrightText: 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
// SPDX-FileCopyrightText: 2022-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "applicationlistmodel.h"

#include <QByteArray>
#include <QDebug>
#include <QModelIndex>
#include <QProcess>
#include <QQuickWindow>

#include <KApplicationTrader>
#include <KConfigGroup>
#include <KIO/ApplicationLauncherJob>
#include <KLocalizedString>
#include <KNotificationJobUiDelegate>
#include <KService>
#include <KSharedConfig>
#include <KSycoca>

#include <chrono>

using namespace std::chrono_literals;

ApplicationListModel::ApplicationListModel(HomeScreen *parent)
    : QAbstractListModel(parent)
    , m_homeScreen{parent}
    , m_reloadAppsTimer{new QTimer{this}}
{
    m_reloadAppsTimer->setSingleShot(true);
    m_reloadAppsTimer->setInterval(100ms);
    connect(m_reloadAppsTimer, &QTimer::timeout, this, &ApplicationListModel::sycocaDbChanged);

    connect(KSycoca::self(), &KSycoca::databaseChanged, m_reloadAppsTimer, static_cast<void (QTimer::*)()>(&QTimer::start));

    // initialize wayland window checking
    KWayland::Client::ConnectionThread *connection = KWayland::Client::ConnectionThread::fromApplication(this);
    if (!connection) {
        return;
    }

    load();
}

ApplicationListModel::~ApplicationListModel() = default;

QHash<int, QByteArray> ApplicationListModel::roleNames() const
{
    return {{DelegateRole, QByteArrayLiteral("delegate")}, {NameRole, QByteArrayLiteral("name")}, {CategoryRole, QByteArrayLiteral("category")}};
}

void ApplicationListModel::sycocaDbChanged()
{
    load();
}

void ApplicationListModel::fetchAppsFromMenu(const KServiceGroup::Ptr &serviceGroup,
                                             const QString &categoryName,
                                             const QStringList &blacklist,
                                             QMap<QString, std::pair<KService::Ptr, QStringList>> &applicationsMap,
                                             QStringList &orderedCategories)
{
    if (!serviceGroup) {
        return;
    }

    const KSycocaEntry::List entries = serviceGroup->entries(true, true);

    for (const KSycocaEntry::Ptr &entry : entries) {
        if (entry->isType(KST_KService)) {
            KService::Ptr service(static_cast<KService *>(entry.data()));

            if (!service->showOnCurrentPlatform() || blacklist.contains(service->desktopEntryName())) {
                continue;
            }

            if (!categoryName.isEmpty() && !orderedCategories.contains(categoryName)) {
                orderedCategories.append(categoryName);
            }

            if (!applicationsMap.contains(service->storageId())) {
                applicationsMap.insert(service->storageId(), {service, QStringList{categoryName}});
            } else {
                if (!applicationsMap[service->storageId()].second.contains(categoryName)) {
                    applicationsMap[service->storageId()].second.append(categoryName);
                }
            }

        } else if (entry->isType(KST_KServiceGroup)) {
            KServiceGroup::Ptr subServiceGroup(static_cast<KServiceGroup *>(entry.data()));

            QString currentCategoryName = categoryName.isEmpty() ? subServiceGroup->caption() : categoryName;
            fetchAppsFromMenu(subServiceGroup, currentCategoryName, blacklist, applicationsMap, orderedCategories);
        }
    }
}

void ApplicationListModel::load()
{
    qDebug() << "Reloading folio app list...";

    // This function supports dynamic insertions and deletions to the existing

    auto config = KSharedConfig::openConfig(QStringLiteral("applications-blacklistrc"));
    auto blacklistConfigGroup = KConfigGroup(config, QStringLiteral("Applications"));
    const QStringList blacklist = blacklistConfigGroup.readEntry("blacklist", QStringList());

    QMap<QString, std::pair<KService::Ptr, QStringList>> newApplicationsMap;
    QStringList orderedCategories;

    fetchAppsFromMenu(KServiceGroup::root(), QString(), blacklist, newApplicationsMap, orderedCategories);

    QMap<QString, int> storageIdMap; // <storageId, index>
    for (int i = 0; i < m_delegates.size(); ++i) {
        if (m_delegates[i]->application()) {
            storageIdMap.insert(m_delegates[i]->application()->storageId(), i);
        }
    }

    QList<std::pair<KService::Ptr, QStringList>> toInsert;
    bool categoriesUpdated = false;

    for (auto mapIterator = newApplicationsMap.constBegin(); mapIterator != newApplicationsMap.constEnd(); ++mapIterator) {
        auto it = storageIdMap.find(mapIterator.key());
        if (it != storageIdMap.end()) {
            // Service already in m_delegates
            int delegateIndex = it.value();
            auto app = m_delegates[delegateIndex]->application();
            if (app && app->categories() != mapIterator.value().second) {
                app->setCategories(mapIterator.value().second);
                categoriesUpdated = true;

                QModelIndex modelIndex = index(delegateIndex, 0);
                Q_EMIT dataChanged(modelIndex, modelIndex, {CategoryRole});
            }
            storageIdMap.erase(it);
        } else {
            // Service needs to be inserted into m_delegates
            toInsert.append(mapIterator.value());
        }
    }

    QList<int> toRemove = storageIdMap.values();
    std::sort(toRemove.begin(), toRemove.end());

    // Remove indices first, from end to start to avoid indices changing
    for (int i = toRemove.size() - 1; i >= 0; --i) {
        int ind = toRemove[i];

        QString storageId;
        if (m_delegates[ind]->application()) {
            storageId = m_delegates[ind]->application()->storageId();
        }

        beginRemoveRows({}, ind, ind);
        m_delegates.removeAt(ind);
        endRemoveRows();

        Q_EMIT applicationRemoved(storageId);
    }

    // Append new elements
    if (!toInsert.isEmpty()) {
        beginInsertRows({}, m_delegates.size(), m_delegates.size() + toInsert.size() - 1);
        for (const auto &appPair : std::as_const(toInsert)) {
            FolioApplication::Ptr app = std::make_shared<FolioApplication>(appPair.first, appPair.second);
            FolioDelegate::Ptr delegate = std::make_shared<FolioDelegate>(app);
            m_delegates.append(delegate);
        }
        endInsertRows();
    }

    // Rebuild tab categories if insertions, removals, or category changes happened
    if (!toRemove.isEmpty() || !toInsert.isEmpty() || categoriesUpdated) {
        QStringList newCategories;
        newCategories << i18n("All"); // always put "All" first

        // Append categories in the exact order they were discovered in the menu tree
        for (const QString &category : orderedCategories) {
            if (!category.isEmpty() && !newCategories.contains(category)) {
                newCategories << category;
            }
        }

        if (m_categories != newCategories) {
            m_categories = newCategories;
            Q_EMIT categoriesChanged();
        }
    }
}

QVariant ApplicationListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_delegates.count()) {
        return QVariant();
    }

    auto delegate = m_delegates.at(index.row());
    auto app = delegate->application();

    switch (role) {
    case Qt::DisplayRole:
    case DelegateRole:
        return QVariant::fromValue(delegate.get());
    case NameRole:
        return app ? app->name() : QVariant();
    case CategoryRole:
        return app ? QVariant(app->categories()) : QVariant();
    default:
        return QVariant();
    }
}

int ApplicationListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_delegates.count();
}

ApplicationListSearchModel::ApplicationListSearchModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setFilterRole(ApplicationListModel::NameRole);
    setFilterCaseSensitivity(Qt::CaseInsensitive);

    setSortRole(ApplicationListModel::NameRole);
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setSortLocaleAware(true);

    sort(0, Qt::AscendingOrder);

    connect(this, &QSortFilterProxyModel::rowsInserted, this, &ApplicationListSearchModel::countChanged);
    connect(this, &QSortFilterProxyModel::rowsRemoved, this, &ApplicationListSearchModel::countChanged);
    connect(this, &QSortFilterProxyModel::modelReset, this, &ApplicationListSearchModel::countChanged);
    connect(this, &QSortFilterProxyModel::layoutChanged, this, &ApplicationListSearchModel::countChanged);
}

void ApplicationListSearchModel::setCategoryFilter(const QString &category)
{
    if (m_categoryFilter != category) {
        m_categoryFilter = category;
        Q_EMIT categoryFilterChanged();
        beginFilterChange();
        endFilterChange();
    }
}

void ApplicationListSearchModel::setSearchString(const QString &search)
{
    if (m_searchString != search) {
        m_searchString = search;
        setFilterFixedString(search);
        Q_EMIT searchStringChanged();
    }
}

bool ApplicationListSearchModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if (!QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent)) {
        return false;
    }

    if (m_categoryFilter.isEmpty() || m_categoryFilter == i18n("All") || m_categoryFilter == QLatin1String("All")) {
        return true;
    }

    QModelIndex index = sourceModel()->index(source_row, 0, source_parent);

    QStringList rowCategories = sourceModel()->data(index, ApplicationListModel::CategoryRole).toStringList();

    return rowCategories.contains(m_categoryFilter);
}

QVariant ApplicationListSearchModel::get(int row, const QString &roleName) const
{
    if (row < 0 || row >= rowCount())
        return QVariant();

    int role = roleNames().key(roleName.toUtf8(), -1);
    if (role == -1)
        return QVariant();

    return data(index(row, 0), role);
}
