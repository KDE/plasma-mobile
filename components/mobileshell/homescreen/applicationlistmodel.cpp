/*
 *   SPDX-FileCopyrightText: 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
 *   SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

// Self
#include "applicationlistmodel.h"

// Qt
#include <QByteArray>
#include <QDebug>
#include <QModelIndex>
#include <QProcess>
#include <QQuickItem>
#include <QQuickWindow>

// KDE
#include <KApplicationTrader>
#include <KIO/ApplicationLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KService>
#include <KSharedConfig>
#include <KSycoca>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

#include <Plasma/Applet>
#include <PlasmaQuick/AppletQuickItem>

constexpr int MAX_FAVOURITES = 5;

ApplicationListModel::ApplicationListModel(QObject *parent)
    : QAbstractListModel(parent)
// m_applet(parent)
{
    connect(KSycoca::self(), qOverload<const QStringList &>(&KSycoca::databaseChanged), this, &ApplicationListModel::sycocaDbChanged);

    loadSettings();
    initWayland();
}

ApplicationListModel::~ApplicationListModel() = default;

void ApplicationListModel::loadSettings()
{
    if (!m_applet) {
        return;
    }
    m_favorites = m_applet->applet()->config().readEntry("Favorites", QStringList());
#if (QT_VERSION >= QT_VERSION_CHECK(5, 14, 0))
    const auto di = m_applet->applet()->config().readEntry("DesktopItems", QStringList());
    m_desktopItems = QSet<QString>(di.begin(), di.end());
#else
    m_desktopItems = m_applet->applet()->config().readEntry("DesktopItems", QStringList()).toSet();
#endif
    m_appOrder = m_applet->applet()->config().readEntry("AppOrder", QStringList());
    m_maxFavoriteCount = m_applet->applet()->config().readEntry("MaxFavoriteCount", MAX_FAVOURITES);

    int i = 0;
    for (const QString &app : qAsConst(m_appOrder)) {
        m_appPositions[app] = i;
        ++i;
    }

    // loadApplications();
}

QHash<int, QByteArray> ApplicationListModel::roleNames() const
{
    return {{ApplicationNameRole, QByteArrayLiteral("applicationName")},
            {ApplicationIconRole, QByteArrayLiteral("applicationIcon")},
            {ApplicationStorageIdRole, QByteArrayLiteral("applicationStorageId")},
            {ApplicationEntryPathRole, QByteArrayLiteral("applicationEntryPath")},
            {ApplicationOriginalRowRole, QByteArrayLiteral("applicationOriginalRow")},
            {ApplicationStartupNotifyRole, QByteArrayLiteral("applicationStartupNotify")},
            {ApplicationLocationRole, QByteArrayLiteral("applicationLocation")},
            {ApplicationRunningRole, QByteArrayLiteral("applicationRunning")},
            {ApplicationUniqueIdRole, QByteArrayLiteral("applicationUniqueId")}};
}

void ApplicationListModel::sycocaDbChanged(const QStringList &changes)
{
    if (!changes.contains(QStringLiteral("apps")) && !changes.contains(QStringLiteral("xdgdata-apps"))) {
        return;
    }

    m_applicationList.clear();

    loadApplications();
}

bool appNameLessThan(const ApplicationListModel::ApplicationData &a1, const ApplicationListModel::ApplicationData &a2)
{
    return a1.name.compare(a2.name, Qt::CaseInsensitive) < 0;
}

void ApplicationListModel::initWayland()
{
    if (!QGuiApplication::platformName().startsWith(QLatin1String("wayland"), Qt::CaseInsensitive)) {
        return;
    }
    using namespace KWayland::Client;
    ConnectionThread *connection = ConnectionThread::fromApplication(this);

    if (!connection) {
        return;
    }
    auto *registry = new Registry(this);
    registry->create(connection);
    connect(registry, &Registry::plasmaWindowManagementAnnounced, this, [this, registry](quint32 name, quint32 version) {
        m_windowManagement = registry->createPlasmaWindowManagement(name, version, this);
        qRegisterMetaType<QVector<int>>("QVector<int>");

        connect(m_windowManagement, &KWayland::Client::PlasmaWindowManagement::windowCreated, this, [this](KWayland::Client::PlasmaWindow *window) {
            if (window->appId() == QStringLiteral("org.kde.plasmashell")) {
                return;
            }
            int idx = 0;
            for (auto i = m_applicationList.begin(); i != m_applicationList.end(); i++) {
                if ((*i).storageId == window->appId() + QStringLiteral(".desktop")) {
                    (*i).window = window;
                    emit dataChanged(index(idx, 0), index(idx, 0));
                    connect(window, &KWayland::Client::PlasmaWindow::unmapped, this, [this, window]() {
                        int idx = 0;
                        for (auto i = m_applicationList.begin(); i != m_applicationList.end(); i++) {
                            if ((*i).storageId == window->appId() + QStringLiteral(".desktop")) {
                                (*i).window = nullptr;
                                emit dataChanged(index(idx, 0), index(idx, 0));
                                break;
                            }
                            idx++;
                        }
                    });
                    break;
                }
                idx++;
            }
        });
    });

    registry->setup();
    connection->roundtrip();
}

void ApplicationListModel::loadApplications()
{
    auto cfg = KSharedConfig::openConfig(QStringLiteral("applications-blacklistrc"));
    auto blgroup = KConfigGroup(cfg, QStringLiteral("Applications"));

    const QStringList blacklist = blgroup.readEntry("blacklist", QStringList());

    beginResetModel();

    m_applicationList.clear();

    QMap<int, ApplicationData> orderedList;
    QList<ApplicationData> unorderedList;
    QSet<QString> foundFavorites;

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

        if (m_favorites.contains(data.uniqueId)) {
            data.location = Favorites;
            foundFavorites.insert(data.uniqueId);
        } else if (m_desktopItems.contains(data.uniqueId)) {
            data.location = Desktop;
        }

        auto it = m_appPositions.constFind(data.uniqueId);
        if (it != m_appPositions.constEnd()) {
            orderedList[*it] = data;
        } else {
            unorderedList << data;
        }
    }

    blgroup.writeEntry("blacklist", blacklist);
    cfg->sync();

    std::sort(unorderedList.begin(), unorderedList.end(), appNameLessThan);
    m_applicationList << orderedList.values();
    m_applicationList << unorderedList;

    endResetModel();
    emit countChanged();

    bool favChanged = false;
    for (const auto &item : m_favorites) {
        if (!foundFavorites.contains(item)) {
            favChanged = true;
            m_favorites.removeAll(item);
        }
    }
    if (favChanged) {
        if (m_applet) {
            m_applet->applet()->config().writeEntry("Favorites", m_favorites);
        }
        emit favoriteCountChanged();
    }
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
    case ApplicationOriginalRowRole:
        return index.row();
    case ApplicationStartupNotifyRole:
        return m_applicationList.at(index.row()).startupNotify;
    case ApplicationLocationRole:
        return m_applicationList.at(index.row()).location;
    case ApplicationRunningRole:
        return m_applicationList.at(index.row()).window != nullptr;
    case ApplicationUniqueIdRole:
        return m_applicationList.at(index.row()).uniqueId;

    default:
        return QVariant();
    }
}

Qt::ItemFlags ApplicationListModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return {};
    return Qt::ItemIsDragEnabled | QAbstractListModel::flags(index);
}

int ApplicationListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_applicationList.count();
}

void ApplicationListModel::moveRow(const QModelIndex & /* sourceParent */, int sourceRow, const QModelIndex & /* destinationParent */, int destinationChild)
{
    moveItem(sourceRow, destinationChild);
}

void ApplicationListModel::setLocation(int row, LauncherLocation location)
{
    if (row < 0 || row >= m_applicationList.length()) {
        return;
    }

    ApplicationData data = m_applicationList.at(row);
    if (data.location == location) {
        return;
    }

    if (location == Favorites) {
        qWarning() << "favoriting" << row << data.name;
        // Deny favorites when full
        if (row >= m_maxFavoriteCount || m_favorites.count() >= m_maxFavoriteCount || m_favorites.contains(data.uniqueId)) {
            return;
        }

        m_favorites.insert(row, data.uniqueId);

        if (m_applet) {
            m_applet->applet()->config().writeEntry("Favorites", m_favorites);
        }
        emit favoriteCountChanged();

        // Out of favorites
    } else if (data.location == Favorites) {
        m_favorites.removeAll(data.uniqueId);
        if (m_applet) {
            m_applet->applet()->config().writeEntry("Favorites", m_favorites);
        }
        emit favoriteCountChanged();
    }

    // In Desktop
    if (location == Desktop) {
        m_desktopItems.insert(data.uniqueId);
        if (m_applet) {
            m_applet->applet()->config().writeEntry("DesktopItems", m_desktopItems.values());
        }

        // Out of Desktop
    } else if (data.location == Desktop) {
        m_desktopItems.remove(data.uniqueId);
        if (m_applet) {
            m_applet->applet()->config().writeEntry(QStringLiteral("DesktopItems"), m_desktopItems.values());
        }
    }

    data.location = location;
    if (m_applet) {
        emit m_applet->applet()->configNeedsSaving();
    }
    emit dataChanged(index(row, 0), index(row, 0));
}

void ApplicationListModel::moveItem(int row, int destination)
{
    if (row < 0 || destination < 0 || row >= m_applicationList.length() || destination >= m_applicationList.length() || row == destination) {
        return;
    }
    if (destination > row) {
        ++destination;
    }

    beginMoveRows(QModelIndex(), row, row, QModelIndex(), destination);
    if (destination > row) {
        ApplicationData data = m_applicationList.at(row);
        m_applicationList.insert(destination, data);
        m_applicationList.takeAt(row);

    } else {
        ApplicationData data = m_applicationList.takeAt(row);
        m_applicationList.insert(destination, data);
    }

    m_appOrder.clear();
    m_appPositions.clear();
    int i = 0;
    for (const ApplicationData &app : qAsConst(m_applicationList)) {
        m_appOrder << app.uniqueId;
        m_appPositions[app.uniqueId] = i;
        ++i;
    }

    if (m_applet) {
        m_applet->applet()->config().writeEntry("AppOrder", m_appOrder);
    }

    endMoveRows();
}

void ApplicationListModel::runApplication(const QString &storageId)
{
    if (storageId.isEmpty()) {
        return;
    }

    for (auto i = m_applicationList.begin(); i != m_applicationList.end(); i++) {
        if ((*i).window && (*i).storageId == storageId) {
            (*i).window->requestActivate();
            return;
        }
    }

    KService::Ptr service = KService::serviceByStorageId(storageId);
    KIO::ApplicationLauncherJob *job = new KIO::ApplicationLauncherJob(service);
    job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoHandlingEnabled));
    job->start();
    connect(job, &KJob::finished, this, [this, job] {
        if (job->error()) {
            qWarning() << "error launching" << job->error() << job->errorString();
            Q_EMIT launchError(job->errorString());
        }
    });
}

int ApplicationListModel::maxFavoriteCount() const
{
    return m_maxFavoriteCount;
}

void ApplicationListModel::setMaxFavoriteCount(int count)
{
    if (m_maxFavoriteCount == count) {
        return;
    }

    if (m_maxFavoriteCount > count) {
        while (m_favorites.size() > count && m_favorites.count() > 0) {
            m_favorites.pop_back();
        }
        emit favoriteCountChanged();

        int i = 0;
        for (auto &app : m_applicationList) {
            if (i >= count && app.location == Favorites) {
                app.location = Grid;
                emit dataChanged(index(i, 0), index(i, 0));
            }
            ++i;
        }
    }

    m_maxFavoriteCount = count;
    if (m_applet) {
        m_applet->applet()->config().writeEntry("MaxFavoriteCount", m_maxFavoriteCount);
    }

    emit maxFavoriteCountChanged();
}

PlasmaQuick::AppletQuickItem *ApplicationListModel::applet() const
{
    return m_applet;
}

void ApplicationListModel::setApplet(PlasmaQuick::AppletQuickItem *applet)
{
    if (m_applet == applet) {
        return;
    }
    m_applet = applet;
    loadSettings();
    emit appletChanged();
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

    using namespace KWayland::Client;
    KWayland::Client::PlasmaWindow *window = m_applicationList[row].window;
    if (!window) {
        return;
    }

    Surface *surface = Surface::fromWindow(delegateWindow);

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

    using namespace KWayland::Client;
    KWayland::Client::PlasmaWindow *window = m_applicationList[row].window;
    if (!window) {
        return;
    }

    Surface *surface = Surface::fromWindow(delegateWindow);

    if (!surface) {
        return;
    }

    window->unsetMinimizedGeometry(surface);
}
