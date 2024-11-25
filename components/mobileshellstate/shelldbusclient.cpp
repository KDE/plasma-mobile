// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "shelldbusclient.h"

#include <QDBusServiceWatcher>

ShellDBusClient::ShellDBusClient(QObject *parent)
    : QObject{parent}
    , m_interface{new OrgKdePlasmashellInterface{QStringLiteral("org.kde.plasmashell"), QStringLiteral("/Mobile"), QDBusConnection::sessionBus(), this}}
    , m_watcher{new QDBusServiceWatcher(QStringLiteral("org.kde.plasmashell"), QDBusConnection::sessionBus(), QDBusServiceWatcher::WatchForOwnerChange, this)}
    , m_connected{false}
{
    if (m_interface->isValid()) {
        connectSignals();
    }

    connect(m_watcher, &QDBusServiceWatcher::serviceRegistered, this, [this]() -> void {
        m_connected = true;
        if (m_interface->isValid()) {
            connectSignals();
        }
    });

    connect(m_watcher, &QDBusServiceWatcher::serviceUnregistered, this, [this]() -> void {
        m_connected = false;
    });
}

void ShellDBusClient::connectSignals()
{
    connect(m_interface, &OrgKdePlasmashellInterface::panelStateChanged, this, &ShellDBusClient::updatePanelState);
    connect(m_interface, &OrgKdePlasmashellInterface::isActionDrawerOpenChanged, this, &ShellDBusClient::updateIsActionDrawerOpen);
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

    updateIsActionDrawerOpen();
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

void ShellDBusClient::updatePanelState()
{
    auto reply = m_interface->panelState();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<QString> reply = *watcher;
        m_panelState = reply.argumentAt<0>();
        Q_EMIT panelStateChanged();
    });
}

void ShellDBusClient::updateDoNotDisturb()
{
    auto reply = m_interface->doNotDisturb();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<bool> reply = *watcher;
        m_doNotDisturb = reply.argumentAt<0>();
        Q_EMIT doNotDisturbChanged();
    });
}

void ShellDBusClient::updateIsActionDrawerOpen()
{
    auto reply = m_interface->isActionDrawerOpen();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<bool> reply = *watcher;
        m_isActionDrawerOpen = reply.argumentAt<0>();
        Q_EMIT isActionDrawerOpenChanged();
    });
}

void ShellDBusClient::updateIsTaskSwitcherVisible()
{
    auto reply = m_interface->isTaskSwitcherVisible();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<bool> reply = *watcher;
        m_isTaskSwitcherVisible = reply.argumentAt<0>();
        Q_EMIT isTaskSwitcherVisibleChanged();
    });
}
