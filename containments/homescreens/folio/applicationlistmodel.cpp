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

ApplicationListModel::ApplicationListModel(QObject *parent)
    : QAbstractListModel(parent)
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    connect(KSycoca::self(), qOverload<const QStringList &>(&KSycoca::databaseChanged), this, &ApplicationListModel::sycocaDbChanged);
#else
    connect(KSycoca::self(), &KSycoca::databaseChanged, this, &ApplicationListModel::sycocaDbChanged);
#endif

    // initialize wayland window checking
    KWayland::Client::ConnectionThread *connection = KWayland::Client::ConnectionThread::fromApplication(this);
    if (!connection) {
        return;
    }

    auto *registry = new KWayland::Client::Registry(this);
    registry->create(connection);

    connect(registry, &KWayland::Client::Registry::plasmaWindowManagementAnnounced, this, [this, registry](quint32 name, quint32 version) {
        m_windowManagement = registry->createPlasmaWindowManagement(name, version, this);
        qRegisterMetaType<QVector<int>>("QVector<int>");
        connect(m_windowManagement, &KWayland::Client::PlasmaWindowManagement::windowCreated, this, &ApplicationListModel::windowCreated);
    });

    registry->setup();
    connection->roundtrip();
}

ApplicationListModel::~ApplicationListModel() = default;

QHash<int, QByteArray> ApplicationListModel::roleNames() const
{
    return {{ApplicationNameRole, QByteArrayLiteral("applicationName")},
            {ApplicationIconRole, QByteArrayLiteral("applicationIcon")},
            {ApplicationStorageIdRole, QByteArrayLiteral("applicationStorageId")},
            {ApplicationEntryPathRole, QByteArrayLiteral("applicationEntryPath")},
            {ApplicationStartupNotifyRole, QByteArrayLiteral("applicationStartupNotify")},
            {ApplicationRunningRole, QByteArrayLiteral("applicationRunning")},
            {ApplicationUniqueIdRole, QByteArrayLiteral("applicationUniqueId")},
            {ApplicationLocationRole, QByteArrayLiteral("applicationLocation")}};
}

void ApplicationListModel::sycocaDbChanged()
{
    load();
}

void ApplicationListModel::windowCreated(KWayland::Client::PlasmaWindow *window)
{
    if (window->appId() == QStringLiteral("org.kde.plasmashell")) {
        return;
    }
    int idx = 0;
    for (auto i = m_applicationList.begin(); i != m_applicationList.end(); i++) {
        if ((*i).storageId == window->appId() + QStringLiteral(".desktop")) {
            (*i).window = window;
            Q_EMIT dataChanged(index(idx, 0), index(idx, 0));
            connect(window, &KWayland::Client::PlasmaWindow::unmapped, this, [this, window]() {
                int idx = 0;
                for (auto i = m_applicationList.begin(); i != m_applicationList.end(); i++) {
                    if ((*i).storageId == window->appId() + QStringLiteral(".desktop")) {
                        (*i).window = nullptr;
                        Q_EMIT dataChanged(index(idx, 0), index(idx, 0));
                        break;
                    }
                    idx++;
                }
            });
            break;
        }
        idx++;
    }
}

void ApplicationListModel::load()
{
    auto cfg = KSharedConfig::openConfig(QStringLiteral("applications-blacklistrc"));
    auto blgroup = KConfigGroup(cfg, QStringLiteral("Applications"));

    const QStringList blacklist = blgroup.readEntry("blacklist", QStringList());

    beginResetModel();

    m_applicationList.clear();

    QList<ApplicationData> unorderedList;

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
        ApplicationData data;
        data.name = service->name();
        data.icon = service->icon();
        data.storageId = service->storageId();
        data.uniqueId = service->storageId();
        data.entryPath = service->exec();
        data.startupNotify = service->property(QStringLiteral("StartupNotify")).toBool();
        unorderedList << data;
    }

    std::sort(unorderedList.begin(), unorderedList.end(), [](const ApplicationListModel::ApplicationData &a1, const ApplicationListModel::ApplicationData &a2) {
        return a1.name.compare(a2.name, Qt::CaseInsensitive) < 0;
    });

    m_applicationList << unorderedList;

    endResetModel();
}

QVariant ApplicationListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
    case Qt::DisplayRole:
    case ApplicationNameRole:
        return m_applicationList.at(index.row()).name;
    case ApplicationIconRole:
        return m_applicationList.at(index.row()).icon;
    case ApplicationStorageIdRole:
        return m_applicationList.at(index.row()).storageId;
    case ApplicationEntryPathRole:
        return m_applicationList.at(index.row()).entryPath;
    case ApplicationStartupNotifyRole:
        return m_applicationList.at(index.row()).startupNotify;
    case ApplicationRunningRole:
        return m_applicationList.at(index.row()).window != nullptr;
    case ApplicationUniqueIdRole:
        return m_applicationList.at(index.row()).uniqueId;
    case ApplicationLocationRole:
        return m_applicationList.at(index.row()).location;
    default:
        return QVariant();
    }
}

int ApplicationListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_applicationList.count();
}

void ApplicationListModel::setMinimizedDelegate(int row, QQuickItem *delegate)
{
    if (row < 0 || row >= m_applicationList.count()) {
        return;
    }

    QWindow *delegateWindow = delegate->window();
    if (!delegateWindow) {
        return;
    }

    KWayland::Client::PlasmaWindow *window = m_applicationList[row].window;
    if (!window) {
        return;
    }

    KWayland::Client::Surface *surface = KWayland::Client::Surface::fromWindow(delegateWindow);
    if (!surface) {
        return;
    }

    QRect rect = delegate->mapRectToScene(QRectF(0, 0, delegate->width(), delegate->height())).toRect();

    window->setMinimizedGeometry(surface, rect);
}

void ApplicationListModel::unsetMinimizedDelegate(int row, QQuickItem *delegate)
{
    if (row < 0 || row >= m_applicationList.count()) {
        return;
    }

    QWindow *delegateWindow = delegate->window();
    if (!delegateWindow) {
        return;
    }

    KWayland::Client::PlasmaWindow *window = m_applicationList[row].window;
    if (!window) {
        return;
    }

    KWayland::Client::Surface *surface = KWayland::Client::Surface::fromWindow(delegateWindow);
    if (!surface) {
        return;
    }

    window->unsetMinimizedGeometry(surface);
}
