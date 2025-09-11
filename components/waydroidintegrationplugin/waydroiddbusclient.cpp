/*
 *   SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "waydroiddbusclient.h"

#include <QClipboard>
#include <QCoroDBusPendingReply>
#include <QGuiApplication>

using namespace Qt::StringLiterals;

WaydroidDBusClient::WaydroidDBusClient(QObject *parent)
    : QObject{parent}
    , m_interface{new OrgKdePlasmashellWaydroidInterface{u"org.kde.plasmashell"_s, u"/Waydroid"_s, QDBusConnection::sessionBus(), this}}
    , m_watcher{new QDBusServiceWatcher{u"org.kde.plasmashell"_s, QDBusConnection::sessionBus(), QDBusServiceWatcher::WatchForOwnerChange, this}}
    , m_applicationListModel{new WaydroidApplicationListModel{this}}
{
    // Check if the service is already running
    if (QDBusConnection::sessionBus().interface()->isServiceRegistered(u"org.kde.plasmashell"_s)) {
        m_connected = true;
        if (m_interface->isValid()) {
            connectSignals();
        }
    }

    connect(m_watcher, &QDBusServiceWatcher::serviceOwnerChanged, this, [this](const QString &service, const QString &oldOwner, const QString &newOwner) {
        if (service == u"org.kde.plasmashell"_s) {
            if (newOwner.isEmpty()) {
                // Service stopped
                m_connected = false;
            } else if (oldOwner.isEmpty()) {
                // Service started
                m_connected = true;
                if (m_interface->isValid()) {
                    connectSignals();
                }
            }
        }
    });
}

void WaydroidDBusClient::connectSignals()
{
    connect(m_interface, &OrgKdePlasmashellWaydroidInterface::statusChanged, this, &WaydroidDBusClient::updateStatus);
    connect(m_interface, &OrgKdePlasmashellWaydroidInterface::downloadStatusChanged, this, [this](double downloaded, double total, double speed) {
        Q_EMIT downloadStatusChanged(downloaded, total, speed);
    });
    connect(m_interface, &OrgKdePlasmashellWaydroidInterface::sessionStatusChanged, this, &WaydroidDBusClient::updateSessionStatus);
    connect(m_interface, &OrgKdePlasmashellWaydroidInterface::systemTypeChanged, this, &WaydroidDBusClient::updateSystemType);
    connect(m_interface, &OrgKdePlasmashellWaydroidInterface::ipAddressChanged, this, &WaydroidDBusClient::updateIpAddress);
    connect(m_interface, &OrgKdePlasmashellWaydroidInterface::androidIdChanged, this, &WaydroidDBusClient::updateAndroidId);
    connect(m_interface, &OrgKdePlasmashellWaydroidInterface::multiWindowsChanged, this, &WaydroidDBusClient::updateMultiWindows);
    connect(m_interface, &OrgKdePlasmashellWaydroidInterface::suspendChanged, this, &WaydroidDBusClient::updateSuspend);
    connect(m_interface, &OrgKdePlasmashellWaydroidInterface::ueventChanged, this, &WaydroidDBusClient::updateUevent);
    connect(m_interface, &OrgKdePlasmashellWaydroidInterface::actionFinished, this, [this](const QString message) {
        Q_EMIT actionFinished(message);
    });
    connect(m_interface, &OrgKdePlasmashellWaydroidInterface::actionFailed, this, [this](const QString message) {
        Q_EMIT actionFailed(message);
    });
    connect(m_interface, &OrgKdePlasmashellWaydroidInterface::errorOccurred, this, [this](const QString title, const QString message) {
        Q_EMIT errorOccurred(title, message);
    });

    initializeApplicationListModel();
    updateStatus();
    updateSessionStatus();
    updateSystemType();
    updateIpAddress();
    updateAndroidId();
    updateMultiWindows();
    updateSuspend();
    updateUevent();
}

void WaydroidDBusClient::initializeApplicationListModel()
{
    auto reply = m_interface->applications();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<QList<QDBusObjectPath>> reply = *watcher;
        const auto applications = reply.argumentAt<0>();

        m_applicationListModel->initializeApplications(applications);

        // Connect applicationListModel signals only when applications is synced
        connect(m_interface, &OrgKdePlasmashellWaydroidInterface::applicationAdded, m_applicationListModel, &WaydroidApplicationListModel::addApplication);
        connect(m_interface, &OrgKdePlasmashellWaydroidInterface::applicationRemoved, m_applicationListModel, &WaydroidApplicationListModel::removeApplication);
    });
}

WaydroidDBusClient::Status WaydroidDBusClient::status() const
{
    return m_status;
}

WaydroidDBusClient::SessionStatus WaydroidDBusClient::sessionStatus() const
{
    return m_sessionStatus;
}

WaydroidDBusClient::SystemType WaydroidDBusClient::systemType() const
{
    return m_systemType;
}

QString WaydroidDBusClient::ipAddress() const
{
    return m_ipAddress;
}

QString WaydroidDBusClient::androidId() const
{
    return m_androidId;
}

WaydroidApplicationListModel *WaydroidDBusClient::applicationListModel() const
{
    return m_applicationListModel;
}

QCoro::Task<void> WaydroidDBusClient::setMultiWindowsTask(const bool multiWindows)
{
    auto pendingReply = m_interface->setMultiWindows(multiWindows);
    co_await pendingReply;
}

QCoro::QmlTask WaydroidDBusClient::setMultiWindows(const bool multiWindows)
{
    return setMultiWindowsTask(multiWindows);
}

bool WaydroidDBusClient::multiWindows() const
{
    return m_multiWindows;
}

QCoro::Task<void> WaydroidDBusClient::setSuspendTask(const bool suspend)
{
    auto pendingReply = m_interface->setSuspend(suspend);
    co_await pendingReply;
}

QCoro::QmlTask WaydroidDBusClient::setSuspend(const bool suspend)
{
    return setSuspendTask(suspend);
}

bool WaydroidDBusClient::suspend() const
{
    return m_suspend;
}

QCoro::Task<void> WaydroidDBusClient::setUeventTask(const bool uevent)
{
    auto pendingReply = m_interface->setUevent(uevent);
    co_await pendingReply;
}

QCoro::QmlTask WaydroidDBusClient::setUevent(const bool multiWindows)
{
    return setUeventTask(multiWindows);
}

QCoro::Task<void> WaydroidDBusClient::refreshSessionInfoTask()
{
    auto pendingReply = m_interface->refreshSessionInfo();
    co_await pendingReply;
}

QCoro::QmlTask WaydroidDBusClient::refreshSessionInfo()
{
    return refreshSessionInfoTask();
}

QCoro::Task<void> WaydroidDBusClient::refreshAndroidIdTask()
{
    auto pendingReply = m_interface->refreshAndroidId();
    co_await pendingReply;
}

QCoro::QmlTask WaydroidDBusClient::refreshAndroidId()
{
    return refreshAndroidIdTask();
}

QCoro::Task<void> WaydroidDBusClient::refreshApplicationsTask()
{
    auto pendingReply = m_interface->refreshApplications();
    co_await pendingReply;
}

QCoro::QmlTask WaydroidDBusClient::refreshApplications()
{
    return refreshApplicationsTask();
}

bool WaydroidDBusClient::uevent() const
{
    return m_uevent;
}

QCoro::Task<void> WaydroidDBusClient::initializeTask(const SystemType systemType, const RomType romType, const bool forced)
{
    auto pendingReply = m_interface->initialize(systemType, romType, forced);
    co_await pendingReply;
}

QCoro::QmlTask WaydroidDBusClient::initialize(const SystemType systemType, const RomType romType, const bool forced)
{
    return initializeTask(systemType, romType, forced);
}

QCoro::Task<void> WaydroidDBusClient::startSessionTask()
{
    auto pendingReply = m_interface->startSession();
    co_await pendingReply;
}

QCoro::QmlTask WaydroidDBusClient::startSession()
{
    return startSessionTask();
}

QCoro::Task<void> WaydroidDBusClient::stopSessionTask()
{
    auto pendingReply = m_interface->stopSession();
    co_await pendingReply;
}

QCoro::QmlTask WaydroidDBusClient::stopSession()
{
    return stopSessionTask();
}

QCoro::Task<void> WaydroidDBusClient::resetWaydroidTask()
{
    auto pendingReply = m_interface->resetWaydroid();
    co_await pendingReply;
}

QCoro::QmlTask WaydroidDBusClient::resetWaydroid()
{
    return resetWaydroidTask();
}

QCoro::Task<void> WaydroidDBusClient::installApkTask(const QString apkFile)
{
    auto pendingReply = m_interface->installApk(apkFile);
    co_await pendingReply;
}

QCoro::QmlTask WaydroidDBusClient::installApk(const QString apkFile)
{
    return installApkTask(apkFile);
}

QCoro::Task<void> WaydroidDBusClient::deleteApplicationTask(const QString appId)
{
    auto pendingReply = m_interface->deleteApplication(appId);
    co_await pendingReply;
}

QCoro::QmlTask WaydroidDBusClient::deleteApplication(const QString appId)
{
    return deleteApplicationTask(appId);
}

void WaydroidDBusClient::updateStatus()
{
    auto reply = m_interface->status();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<int> reply = *watcher;
        const auto status = static_cast<Status>(reply.argumentAt<0>());

        if (m_status != status) {
            m_status = status;
            Q_EMIT statusChanged();
        }

        watcher->deleteLater();
    });
}

void WaydroidDBusClient::updateSessionStatus()
{
    auto reply = m_interface->sessionStatus();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<int> reply = *watcher;
        const auto sessionStatus = static_cast<SessionStatus>(reply.argumentAt<0>());

        if (m_sessionStatus != sessionStatus) {
            m_sessionStatus = sessionStatus;
            Q_EMIT sessionStatusChanged();
        }

        watcher->deleteLater();
    });
}

void WaydroidDBusClient::updateSystemType()
{
    auto reply = m_interface->systemType();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<int> reply = *watcher;
        const auto systemType = static_cast<SystemType>(reply.argumentAt<0>());

        if (m_systemType != systemType) {
            m_systemType = systemType;
            Q_EMIT systemTypeChanged();
        }

        watcher->deleteLater();
    });
}

void WaydroidDBusClient::updateIpAddress()
{
    auto reply = m_interface->ipAddress();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<QString> reply = *watcher;
        const auto ipAddress = reply.argumentAt<0>();

        if (m_ipAddress != ipAddress) {
            m_ipAddress = ipAddress;
            Q_EMIT ipAddressChanged();
        }

        watcher->deleteLater();
    });
}

void WaydroidDBusClient::updateAndroidId()
{
    auto reply = m_interface->androidId();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<QString> reply = *watcher;
        const auto androidId = reply.argumentAt<0>();

        if (m_androidId != androidId) {
            m_androidId = androidId;
            Q_EMIT androidIdChanged();
        }

        watcher->deleteLater();
    });
}

void WaydroidDBusClient::updateMultiWindows()
{
    auto reply = m_interface->multiWindows();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<bool> reply = *watcher;
        const auto multiWindows = reply.argumentAt<0>();

        if (m_multiWindows != multiWindows) {
            m_multiWindows = multiWindows;
            Q_EMIT multiWindowsChanged();
        }

        watcher->deleteLater();
    });
}

void WaydroidDBusClient::updateSuspend()
{
    auto reply = m_interface->suspend();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<bool> reply = *watcher;
        const auto suspend = reply.argumentAt<0>();

        if (m_suspend != suspend) {
            m_suspend = suspend;
            Q_EMIT suspendChanged();
        }

        watcher->deleteLater();
    });
}

void WaydroidDBusClient::updateUevent()
{
    auto reply = m_interface->uevent();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<bool> reply = *watcher;
        const auto uevent = reply.argumentAt<0>();

        if (m_uevent != uevent) {
            m_uevent = uevent;
            Q_EMIT ueventChanged();
        }

        watcher->deleteLater();
    });
}

void WaydroidDBusClient::copyToClipboard(const QString text)
{
    qGuiApp->clipboard()->setText(text);
}