// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "shelldbusclient.h"

#include <QDBusServiceWatcher>

ShellDBusClient::ShellDBusClient(QObject *parent)
    : QObject{parent}
    , m_interface{new OrgKdePlasmashellInterface{QStringLiteral("org.kde.plasmashell"), QStringLiteral("/Mobile"), QDBusConnection::sessionBus(), this}}
    , m_connected{false}
{
    m_watcher = new QDBusServiceWatcher(QStringLiteral("org.kde.plasmashell"), QDBusConnection::sessionBus(), QDBusServiceWatcher::WatchForOwnerChange, this);

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

ShellDBusClient *ShellDBusClient::self()
{
    static ShellDBusClient *instance = new ShellDBusClient;
    return instance;
}

void ShellDBusClient::connectSignals()
{
    connect(m_interface, &OrgKdePlasmashellInterface::isActionDrawerOpenChanged, this, &ShellDBusClient::updateIsActionDrawerOpen);
    connect(m_interface, &OrgKdePlasmashellInterface::doNotDisturbChanged, this, &ShellDBusClient::updateDoNotDisturb);
    connect(m_interface, &OrgKdePlasmashellInterface::openActionDrawerRequested, this, &ShellDBusClient::openActionDrawerRequested);
    connect(m_interface, &OrgKdePlasmashellInterface::closeActionDrawerRequested, this, &ShellDBusClient::closeActionDrawerRequested);
    connect(m_interface, &OrgKdePlasmashellInterface::openAppLaunchAnimationRequested, this, &ShellDBusClient::openAppLaunchAnimationRequested);
    connect(m_interface, &OrgKdePlasmashellInterface::closeAppLaunchAnimationRequested, this, &ShellDBusClient::closeAppLaunchAnimationRequested);
    connect(m_interface, &OrgKdePlasmashellInterface::openHomeScreenRequested, this, &ShellDBusClient::openHomeScreenRequested);
    connect(m_interface, &OrgKdePlasmashellInterface::resetHomeScreenPositionRequested, this, &ShellDBusClient::resetHomeScreenPositionRequested);

    updateIsActionDrawerOpen();
    updateDoNotDisturb();
}

bool ShellDBusClient::doNotDisturb()
{
    return m_doNotDisturb;
}

void ShellDBusClient::setDoNotDisturb(bool value)
{
    m_interface->setDoNotDisturb(value);
}

bool ShellDBusClient::isActionDrawerOpen()
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

void ShellDBusClient::openAppLaunchAnimation(QString splashIcon, QString title, qreal x, qreal y, qreal sourceIconSize)
{
    m_interface->openAppLaunchAnimation(splashIcon, title, x, y, sourceIconSize);
}

void ShellDBusClient::closeAppLaunchAnimation()
{
    m_interface->closeAppLaunchAnimation();
}

void ShellDBusClient::openHomeScreen()
{
    m_interface->openHomeScreen();
}

void ShellDBusClient::resetHomeScreenPosition()
{
    m_interface->resetHomeScreenPosition();
}

void ShellDBusClient::updateDoNotDisturb()
{
    m_doNotDisturb = m_interface->doNotDisturb();
    Q_EMIT doNotDisturbChanged();
}

void ShellDBusClient::updateIsActionDrawerOpen()
{
    m_isActionDrawerOpen = m_interface->isActionDrawerOpen();
    Q_EMIT isActionDrawerOpenChanged();
}
