// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "shelldbusclient.h"

#include <QDBusServiceWatcher>

ShellDBusClient::ShellDBusClient(QObject *parent)
    : QObject{parent}
    , m_interface{new OrgKdePlasmashellInterface{QStringLiteral("org.kde.plasmashell"), QStringLiteral("/Mobile"), QDBusConnection::sessionBus(), this}}
    , m_connected{false}
{
    // Check if the service is already running
    if (QDBusConnection::sessionBus().interface()->isServiceRegistered(QStringLiteral("org.kde.plasmashell"))) {
        m_connected = true;
        if (m_interface->isValid()) {
            connectSignals();
        }
    }

    connect(QDBusConnection::sessionBus().interface(), &QDBusConnectionInterface::serviceOwnerChanged, this, [this](const QString &service, const QString &oldOwner, const QString &newOwner) {
        Q_UNUSED(oldOwner);
        if (service == QStringLiteral("org.kde.plasmashell")) {
            if (!newOwner.isEmpty() && !m_connected) {
                m_connected = true;
                if (m_interface->isValid()) {
                    connectSignals();
                }
            } else if (newOwner.isEmpty() && m_connected) {
                m_connected = false;
            }
        }
    });
}

void ShellDBusClient::connectSignals()
{
    connect(m_interface, &OrgKdePlasmashellInterface::panelStateChanged, this, &ShellDBusClient::updatePanelState);
    connect(m_interface, &OrgKdePlasmashellInterface::isActionDrawerOpenChanged, this, &ShellDBusClient::updateIsActionDrawerOpen);
    connect(m_interface, &OrgKdePlasmashellInterface::isVolumeOSDOpenChanged, this, &ShellDBusClient::updateIsVolumeOSDOpen);
    connect(m_interface, &OrgKdePlasmashellInterface::isNotificationPopupDrawerOpenChanged, this, &ShellDBusClient::updateIsNotificationPopupDrawerOpen);
    connect(m_interface, &OrgKdePlasmashellInterface::doNotDisturbChanged, this, &ShellDBusClient::updateDoNotDisturb);
    connect(m_interface, &OrgKdePlasmashellInterface::isTaskSwitcherVisibleChanged, this, &ShellDBusClient::updateIsTaskSwitcherVisible);
    connect(m_interface, &OrgKdePlasmashellInterface::openActionDrawerRequested, this, &ShellDBusClient::openActionDrawerRequested);
    connect(m_interface, &OrgKdePlasmashellInterface::closeActionDrawerRequested, this, &ShellDBusClient::closeActionDrawerRequested);
    connect(m_interface,
            &OrgKdePlasmashellInterface::appLaunchMaximizePanelAnimationTriggered,
            this,
            &ShellDBusClient::appLaunchMaximizePanelAnimationTriggered);
    connect(m_interface, &OrgKdePlasmashellInterface::openHomeScreenRequested, this, &ShellDBusClient::openHomeScreenRequested);
    connect(m_interface, &OrgKdePlasmashellInterface::resetHomeScreenPositionRequested, this, &ShellDBusClient::resetHomeScreenPositionRequested);
    connect(m_interface, &OrgKdePlasmashellInterface::showVolumeOSDRequested, this, &ShellDBusClient::showVolumeOSDRequested);
    connect(m_interface, &OrgKdePlasmashellInterface::openLockScreenKeypadRequested, this, &ShellDBusClient::openLockScreenKeypadRequested);

    // Initial state fetch
    updatePanelState();
    updateIsActionDrawerOpen();
    updateIsVolumeOSDOpen();
    updateIsNotificationPopupDrawerOpen();
    updateDoNotDisturb();
    updateIsTaskSwitcherVisible();
}

QString ShellDBusClient::panelState() const
{
    return m_panelState;
}

void ShellDBusClient::setPanelState(QString state)
{
    m_interface->setPanelState(state);
}

bool ShellDBusClient::doNotDisturb() const
{
    return m_doNotDisturb;
}

void ShellDBusClient::setDoNotDisturb(bool value)
{
    m_interface->setDoNotDisturb(value);
}

bool ShellDBusClient::isActionDrawerOpen() const
{
    return m_isActionDrawerOpen;
}

void ShellDBusClient::setIsActionDrawerOpen(bool value)
{
    m_interface->setIsActionDrawerOpen(value);
}

bool ShellDBusClient::isVolumeOSDOpen() const
{
    return m_isVolumeOSDOpen;
}

void ShellDBusClient::setIsVolumeOSDOpen(bool value)
{
    m_interface->setIsVolumeOSDOpen(value);
}

bool ShellDBusClient::isNotificationPopupDrawerOpen() const
{
    return m_isNotificationPopupDrawerOpen;
}

void ShellDBusClient::setIsNotificationPopupDrawerOpen(bool value)
{
    m_interface->setIsNotificationPopupDrawerOpen(value);
}

void ShellDBusClient::openActionDrawer()
{
    m_interface->openActionDrawer();
}

void ShellDBusClient::closeActionDrawer()
{
    m_interface->closeActionDrawer();
}

bool ShellDBusClient::isTaskSwitcherVisible() const
{
    return m_isTaskSwitcherVisible;
}

void ShellDBusClient::openAppLaunchAnimationWithPosition(int screen,
                                                         QString splashIcon,
                                                         QString title,
                                                         QString storageId,
                                                         qreal x,
                                                         qreal y,
                                                         qreal sourceIconSize)
{
    m_interface->openAppLaunchAnimationWithPosition(screen, splashIcon, title, storageId, x, y, sourceIconSize);
}

void ShellDBusClient::triggerAppLaunchMaximizePanelAnimation(int screen, QString color)
{
    m_interface->triggerAppLaunchMaximizePanelAnimation(screen, color);
}

void ShellDBusClient::openHomeScreen()
{
    m_interface->openHomeScreen();
}

void ShellDBusClient::resetHomeScreenPosition()
{
    m_interface->resetHomeScreenPosition();
}

void ShellDBusClient::showVolumeOSD()
{
    m_interface->showVolumeOSD();
}

void ShellDBusClient::openLockScreenKeypad()
{
    m_interface->openLockScreenKeypad();
}

void ShellDBusClient::updatePanelState()
{
    auto reply = m_interface->panelState();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<QString> reply = *watcher;
        if (!reply.isValid()) {
            qDebug() << "ShellDBusClient: Failed to fetch updatePanelState:" << reply.error().message();
            watcher->deleteLater();
            return;
        }

        QString panelState = reply.argumentAt<0>();

        if (panelState != m_panelState) {
            m_panelState = panelState;
            Q_EMIT panelStateChanged();
        }

        watcher->deleteLater();
    });
}

void ShellDBusClient::updateDoNotDisturb()
{
    auto reply = m_interface->doNotDisturb();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<bool> reply = *watcher;
        if (!reply.isValid()) {
            qDebug() << "ShellDBusClient: Failed to fetch updateDoNotDisturb:" << reply.error().message();
            watcher->deleteLater();
            return;
        }

        bool doNotDisturb = reply.argumentAt<0>();

        if (doNotDisturb != m_doNotDisturb) {
            m_doNotDisturb = doNotDisturb;
            Q_EMIT doNotDisturbChanged();
        }

        watcher->deleteLater();
    });
}

void ShellDBusClient::updateIsActionDrawerOpen()
{
    auto reply = m_interface->isActionDrawerOpen();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<bool> reply = *watcher;
        if (!reply.isValid()) {
            qDebug() << "ShellDBusClient: Failed to fetch updateIsActionDrawerOpen:" << reply.error().message();
            watcher->deleteLater();
            return;
        }

        bool isActionDrawerOpen = reply.argumentAt<0>();

        if (isActionDrawerOpen != m_isActionDrawerOpen) {
            m_isActionDrawerOpen = isActionDrawerOpen;
            Q_EMIT isActionDrawerOpenChanged();
        }

        watcher->deleteLater();
    });
}

void ShellDBusClient::updateIsVolumeOSDOpen()
{
    auto reply = m_interface->isVolumeOSDOpen();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<bool> reply = *watcher;
        if (!reply.isValid()) {
            qDebug() << "ShellDBusClient: Failed to fetch updateIsVolumeOSDOpen:" << reply.error().message();
            watcher->deleteLater();
            return;
        }

        bool isVolumeOSDOpen = reply.argumentAt<0>();

        if (isVolumeOSDOpen != m_isVolumeOSDOpen) {
            m_isVolumeOSDOpen = isVolumeOSDOpen;
            Q_EMIT isVolumeOSDOpenChanged();
        }

        watcher->deleteLater();
    });
}

void ShellDBusClient::updateIsNotificationPopupDrawerOpen()
{
    auto reply = m_interface->isNotificationPopupDrawerOpen();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<bool> reply = *watcher;
        if (!reply.isValid()) {
            qDebug() << "ShellDBusClient: Failed to fetch updateIsNotificationPopupDrawerOpen:" << reply.error().message();
            watcher->deleteLater();
            return;
        }

         bool isNotificationPopupDrawerOpen = reply.argumentAt<0>();

        if (isNotificationPopupDrawerOpen != m_isNotificationPopupDrawerOpen) {
            m_isNotificationPopupDrawerOpen = isNotificationPopupDrawerOpen;
            Q_EMIT isNotificationPopupDrawerOpenChanged();
        }

        watcher->deleteLater();
    });
}

void ShellDBusClient::updateIsTaskSwitcherVisible()
{
    auto reply = m_interface->isTaskSwitcherVisible();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<bool> reply = *watcher;
        if (!reply.isValid()) {
            qDebug() << "ShellDBusClient: Failed to fetch updateIsTaskSwitcherVisible:" << reply.error().message();
            watcher->deleteLater();
            return;
        }

        bool isTaskSwitcherVisible = reply.argumentAt<0>();

        if (isTaskSwitcherVisible != m_isTaskSwitcherVisible) {
            m_isTaskSwitcherVisible = isTaskSwitcherVisible;
            Q_EMIT isTaskSwitcherVisibleChanged();
        }

        watcher->deleteLater();
    });
}
