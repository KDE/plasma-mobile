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

ApplicationListModel::ApplicationListModel(HomeScreen *parent)
    : QAbstractListModel(parent)
{
    connect(KSycoca::self(), &KSycoca::databaseChanged, this, &ApplicationListModel::sycocaDbChanged);

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

    beginResetModel();

    m_delegates.clear();

    QList<FolioDelegate *> unorderedList;

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

    const KService::List apps = KApplicationTrader::query(filter);

    for (const KService::Ptr &service : apps) {
        FolioApplication *app = new FolioApplication{m_homeScreen, service};
        FolioDelegate *delegate = new FolioDelegate{app, m_homeScreen};
        unorderedList << delegate;
    }

    std::sort(unorderedList.begin(), unorderedList.end(), [](FolioDelegate *a1, FolioDelegate *a2) {
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

    FolioDelegate *delegate = m_delegates.at(index.row());

    switch (role) {
    case Qt::DisplayRole:
    case DelegateRole:
        return QVariant::fromValue(delegate);
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
