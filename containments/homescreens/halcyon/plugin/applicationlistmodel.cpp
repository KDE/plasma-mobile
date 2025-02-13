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

ApplicationListModel::ApplicationListModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_reloadAppsTimer{new QTimer{this}}
{
    m_reloadAppsTimer->setSingleShot(true);
    m_reloadAppsTimer->setInterval(100ms);
    connect(m_reloadAppsTimer, &QTimer::timeout, this, &ApplicationListModel::sycocaDbChanged);

    connect(KSycoca::self(), &KSycoca::databaseChanged, m_reloadAppsTimer, static_cast<void (QTimer::*)()>(&QTimer::start));
}

ApplicationListModel::~ApplicationListModel() = default;

ApplicationListModel *ApplicationListModel::self()
{
    static ApplicationListModel *inst = new ApplicationListModel(nullptr);
    return inst;
}

QHash<int, QByteArray> ApplicationListModel::roleNames() const
{
    return {{ApplicationRole, QByteArrayLiteral("application")}};
}

void ApplicationListModel::sycocaDbChanged()
{
    loadApplications();
}

void ApplicationListModel::loadApplications()
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

    m_applicationList.clear();

    QList<Application *> unorderedList;

    const KService::List apps = KApplicationTrader::query(filter);

    for (const KService::Ptr &service : apps) {
        Application *application = new Application{this, service};
        unorderedList.append(application);
    }

    std::sort(unorderedList.begin(), unorderedList.end(), [](const Application *a1, const Application *a2) {
        return a1->name().compare(a2->name(), Qt::CaseInsensitive) < 0;
    });

    m_applicationList << unorderedList;

    endResetModel();
}

QVariant ApplicationListModel::data(const QModelIndex &index, int role) const
{
    Q_UNUSED(role)
    if (!index.isValid()) {
        return QVariant();
    }

    return QVariant::fromValue(m_applicationList.at(index.row()));
}

int ApplicationListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_applicationList.count();
}
