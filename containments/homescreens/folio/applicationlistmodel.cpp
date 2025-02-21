// SPDX-FileCopyrightText: 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
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

void ApplicationListModel::load()
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

    beginResetModel();

    m_delegates.clear();

    QList<FolioDelegate::Ptr> unorderedList;

    const KService::List apps = KApplicationTrader::query(filter);

    for (const KService::Ptr &service : apps) {
        FolioApplication::Ptr app = std::make_shared<FolioApplication>(m_homeScreen, service);
        FolioDelegate::Ptr delegate = std::make_shared<FolioDelegate>(app, m_homeScreen);
        unorderedList << delegate;
    }

    std::sort(unorderedList.begin(), unorderedList.end(), [](FolioDelegate::Ptr &a1, FolioDelegate::Ptr &a2) {
        return a1->application()->name().compare(a2->application()->name(), Qt::CaseInsensitive) < 0;
    });

    m_delegates << unorderedList;

    endResetModel();
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
        return m_delegates.at(index.row())->application()->name();
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
    setFilterCaseSensitivity(Qt::CaseInsensitive);
    setSourceModel(model);
    setFilterRole(ApplicationListModel::NameRole);
}
