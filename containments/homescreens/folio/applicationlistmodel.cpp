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
    return {{DelegateRole, QByteArrayLiteral("delegate")}};
}

void ApplicationListModel::sycocaDbChanged()
{
    load();
}

KService::List ApplicationListModel::queryApplications()
{
    auto cfg = KSharedConfig::openConfig(QStringLiteral("applications-blacklistrc"));
    auto blgroup = KConfigGroup(cfg, QStringLiteral("Applications"));

    const QStringList blacklist = blgroup.readEntry("blacklist", QStringList());
    auto filter = [blacklist](const KService::Ptr &service) -> bool {
        if (service->noDisplay()) {
            return false;
        }

        if (!service->showOnCurrentPlatform()) {
            return false;
        }

        if (blacklist.contains(service->desktopEntryName())) {
            return false;
        }

        return true;
    };

    return KApplicationTrader::query(filter);
}

void ApplicationListModel::load()
{
    qDebug() << "Reloading folio app list...";

    // This function supports dynamic insertions and deletions to the existing
    // list depending on what is given from queryApplications().

    QMap<QString, int> storageIdMap; // <storageId, index>
    for (int i = 0; i < m_delegates.size(); ++i) {
        const auto &delegate = m_delegates[i];
        storageIdMap.insert(delegate->application()->storageId(), i);
    }

    const KService::List currentApps = queryApplications();
    QList<KService::Ptr> toInsert;

    for (const KService::Ptr &service : currentApps) {
        auto it = storageIdMap.find(service->storageId());
        if (it != storageIdMap.end()) {
            // Service already in m_delegates
            storageIdMap.erase(it);
        } else {
            // Service needs to be inserted into m_delegates
            toInsert.append(std::move(service));
        }
    }

    QList<int> toRemove;
    for (int index : storageIdMap.values()) {
        toRemove.append(index);
    }

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
    for (const KService::Ptr &service : toInsert) {
        FolioApplication::Ptr app = std::make_shared<FolioApplication>(service);
        FolioDelegate::Ptr delegate = std::make_shared<FolioDelegate>(app);

        beginInsertRows({}, m_delegates.size(), m_delegates.size());
        m_delegates.append(delegate);
        endInsertRows();
    }
}

QVariant ApplicationListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    FolioDelegate::Ptr delegate = m_delegates.at(index.row());

    switch (role) {
    case Qt::DisplayRole:
    case DelegateRole:
        return QVariant::fromValue(delegate.get());
    case NameRole:
        if (!delegate->application()) {
            return QVariant();
        }
        return delegate->application()->name();
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

ApplicationListSearchModel::ApplicationListSearchModel(HomeScreen *parent, ApplicationListModel *model)
    : QSortFilterProxyModel(parent)
{
    setSourceModel(model);

    setFilterRole(ApplicationListModel::NameRole);
    setFilterCaseSensitivity(Qt::CaseInsensitive);

    setSortRole(ApplicationListModel::NameRole);
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setSortLocaleAware(true);

    sort(0, Qt::AscendingOrder);
}
