/*
 *   Copyright (C) 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

// Self
#include "applicationlistmodel.h"

// Qt
#include <QByteArray>
#include <QModelIndex>
#include <QProcess>
#include <QDebug>
#include <QQuickItem>
#include <QQuickWindow>

// KDE
#include <KIO/ApplicationLauncherJob>
#include <KNotificationJobUiDelegate>
#include <KService>
#include <KServiceGroup>
#include <KSharedConfig>
#include <KSycoca>
#include <KSycocaEntry>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

constexpr int MAX_FAVOURITES = 5;

ApplicationListModel::ApplicationListModel(HomeScreen *parent)
    : QAbstractListModel(parent),
      m_homeScreen(parent)
{
    connect(KSycoca::self(), qOverload<const QStringList &>(&KSycoca::databaseChanged),
            this, &ApplicationListModel::sycocaDbChanged);

    loadSettings();
    initWayland();
}

ApplicationListModel::~ApplicationListModel() = default;

void ApplicationListModel::loadSettings()
{
    m_favorites = m_homeScreen->config().readEntry("Favorites", QStringList());
#if (QT_VERSION >= QT_VERSION_CHECK(5, 14, 0))
    const auto di = m_homeScreen->config().readEntry("DesktopItems", QStringList());
    m_desktopItems = QSet<QString>(di.begin(), di.end());
#else
    m_desktopItems = m_homeScreen->config().readEntry("DesktopItems", QStringList()).toSet();
#endif
    m_appOrder = m_homeScreen->config().readEntry("AppOrder", QStringList());
    m_maxFavoriteCount = m_homeScreen->config().readEntry("MaxFavoriteCount", MAX_FAVOURITES);

    int i = 0;
    for (const QString &app : qAsConst(m_appOrder)) {
        m_appPositions[app] = i;
        ++i;
    }

    loadApplications();
}

QHash<int, QByteArray> ApplicationListModel::roleNames() const
{
    return {
        {ApplicationNameRole, QByteArrayLiteral("applicationName")},
        {ApplicationIconRole, QByteArrayLiteral("applicationIcon")},
        {ApplicationStorageIdRole, QByteArrayLiteral("applicationStorageId")},
        {ApplicationEntryPathRole, QByteArrayLiteral("applicationEntryPath")},
        {ApplicationOriginalRowRole, QByteArrayLiteral("applicationOriginalRow")},
        {ApplicationStartupNotifyRole, QByteArrayLiteral("applicationStartupNotify")},
        {ApplicationLocationRole, QByteArrayLiteral("applicationLocation")},
        {ApplicationRunningRole, QByteArrayLiteral("applicationRunning")}
    };
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
    return a1.name.toLower() < a2.name.toLower();
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
    connect(registry, &Registry::plasmaWindowManagementAnnounced, this,
        [this, registry] (quint32 name, quint32 version) {
            m_windowManagement = registry->createPlasmaWindowManagement(name, version, this);
            qRegisterMetaType<QVector<int> >("QVector<int>");

            connect(m_windowManagement, &KWayland::Client::PlasmaWindowManagement::windowCreated,
                    this, [this] (KWayland::Client::PlasmaWindow *window) {
                if (window->appId() == QStringLiteral("org.kde.plasmashell")) {
                    return;
                }
                int idx = 0;
                for (auto i = m_applicationList.begin(); i != m_applicationList.end(); i++) {
                    if ((*i).storageId == window->appId() + QStringLiteral(".desktop")) {
                        (*i).window = window;
                        emit dataChanged(index(idx, 0), index(idx, 0));
                        connect(window, &KWayland::Client::PlasmaWindow::unmapped, this, [this, window] () {
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
        }
    );

    registry->setup();
    connection->roundtrip();
}

void ApplicationListModel::loadApplications()
{
    auto cfg = KSharedConfig::openConfig(QStringLiteral("applications-blacklistrc"));
    auto blgroup = KConfigGroup(cfg, QStringLiteral("Applications"));

    QStringList blacklist = blgroup.readEntry("blacklist", QStringList());

    beginResetModel();

    m_applicationList.clear();

    KServiceGroup::Ptr group = KServiceGroup::root();
    if (!group || !group->isValid()) return;
    KServiceGroup::List subGroupList = group->entries(true);

    QMap<int, ApplicationData> orderedList;
    QList<ApplicationData> unorderedList;
    QSet<QString> foundFavorites;

    // Iterate over all entries in the group
    while (!subGroupList.isEmpty()) {
        KSycocaEntry::Ptr groupEntry = subGroupList.first();
        subGroupList.pop_front();

        if (groupEntry->isType(KST_KServiceGroup)) {
            KServiceGroup::Ptr serviceGroup(static_cast<KServiceGroup *>(groupEntry.data()));

            if (!serviceGroup->noDisplay()) {
                KServiceGroup::List entryGroupList = serviceGroup->entries(true);

                for(KServiceGroup::List::ConstIterator it = entryGroupList.constBegin();  it != entryGroupList.constEnd(); it++) {
                    KSycocaEntry::Ptr entry = (*it);

                    if (entry->isType(KST_KServiceGroup)) {
                        KServiceGroup::Ptr serviceGroup(static_cast<KServiceGroup *>(entry.data()));
                        subGroupList << serviceGroup;

                    } else if (entry->property(QStringLiteral("Exec")).isValid()) {
                        KService::Ptr service(static_cast<KService *>(entry.data()));

                        if (service->isApplication() &&
                            !blacklist.contains(service->desktopEntryName()) &&
                            service->showOnCurrentPlatform() &&
                            !service->property(QStringLiteral("Terminal"), QVariant::Bool).toBool()) {

                            ApplicationData data;
                            data.name = service->name();
                            data.icon = service->icon();
                            data.storageId = service->storageId();
                            data.entryPath = service->exec();
                            data.startupNotify = service->property(QStringLiteral("StartupNotify")).toBool();

                            if (m_favorites.contains(data.storageId)) {
                                data.location = Favorites;
                                foundFavorites.insert(data.storageId);
                            } else if (m_desktopItems.contains(data.storageId)) {
                                data.location = Desktop;
                            }

                            auto it = m_appPositions.constFind(service->storageId());
                            if (it != m_appPositions.constEnd()) {
                                orderedList[*it] = data;
                            } else {
                                unorderedList << data;
                            }
                        }
                    }
                }
            }
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
        m_homeScreen->config().writeEntry("Favorites", m_favorites);
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

    default:
        return QVariant();
    }
}

Qt::ItemFlags ApplicationListModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return {};
    return Qt::ItemIsDragEnabled|QAbstractListModel::flags(index);
}

int ApplicationListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_applicationList.count();
}

void ApplicationListModel::moveRow(const QModelIndex& /* sourceParent */, int sourceRow, const QModelIndex& /* destinationParent */, int destinationChild)
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
        if (row >= m_maxFavoriteCount || m_favorites.count() >= m_maxFavoriteCount) {
            return;
        }

        m_favorites.insert(row, data.storageId);

        m_homeScreen->config().writeEntry("Favorites", m_favorites);
        emit favoriteCountChanged();

    // Out of favorites
    } else  if (data.location == Favorites) {
        m_favorites.removeAll(data.storageId);
        m_homeScreen->config().writeEntry("Favorites", m_favorites);
        emit favoriteCountChanged();
    }

    // In Desktop
    if (location == Desktop) {
        m_desktopItems.insert(data.storageId);
        m_homeScreen->config().writeEntry("DesktopItems", m_desktopItems.values());

    // Out of Desktop
    } else  if (data.location == Desktop) {
        m_desktopItems.remove(data.storageId);
        m_homeScreen->config().writeEntry(QStringLiteral("DesktopItems"), m_desktopItems.values());
    }

    data.location = location;
    emit m_homeScreen->configNeedsSaving();
    emit dataChanged(index(row, 0), index(row, 0));
}

void ApplicationListModel::moveItem(int row, int destination)
{
    if (row < 0 || destination < 0 || row >= m_applicationList.length() ||
        destination >= m_applicationList.length() || row == destination) {
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
        m_appOrder << app.storageId;
        m_appPositions[app.storageId] = i;
        ++i;
    }

    m_homeScreen->config().writeEntry("AppOrder", m_appOrder);

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
    m_homeScreen->config().writeEntry("MaxFavoriteCount", m_maxFavoriteCount);

    emit maxFavoriteCountChanged();
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

    QRect rect = delegate->mapRectToScene(QRectF(0,0, delegate->width(), delegate->height())).toRect();

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

#include "moc_applicationlistmodel.cpp"

