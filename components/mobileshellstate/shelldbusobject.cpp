// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "shelldbusobject.h"
#include "mobileadaptor.h"

#include <QDBusConnection>

ShellDBusObject::ShellDBusObject(QObject *parent)
    : QObject{parent}
{
}

ShellDBusObject *ShellDBusObject::self()
{
    static ShellDBusObject *instance = new ShellDBusObject;
    return instance;
}

void ShellDBusObject::registerObject()
{
    if (!m_initialized) {
        new PlasmashellAdaptor{this};
        QDBusConnection::sessionBus().registerObject(QStringLiteral("/Mobile"), this);
        m_initialized = true;
    }
}

bool ShellDBusObject::doNotDisturb()
{
    return m_doNotDisturb;
}

void ShellDBusObject::setDoNotDisturb(bool value)
{
    if (value != m_doNotDisturb) {
        m_doNotDisturb = value;
        Q_EMIT doNotDisturbChanged();
    }
}

bool ShellDBusObject::isActionDrawerOpen()
{
    return m_isActionDrawerOpen;
}

void ShellDBusObject::setIsActionDrawerOpen(bool value)
{
    if (value != m_isActionDrawerOpen) {
        m_isActionDrawerOpen = value;
        Q_EMIT isActionDrawerOpenChanged();
    }
}

bool ShellDBusObject::isTaskSwitcherVisible()
{
    return m_isTaskSwitcherVisible;
}

void ShellDBusObject::setIsTaskSwitcherVisible(bool value)
{
    if (value != m_isTaskSwitcherVisible) {
        m_isTaskSwitcherVisible = value;
        Q_EMIT isTaskSwitcherVisibleChanged();
    }
}

void ShellDBusObject::openActionDrawer()
{
    Q_EMIT openActionDrawerRequested();
}

void ShellDBusObject::closeActionDrawer()
{
    Q_EMIT closeActionDrawerRequested();
}

void ShellDBusObject::openAppLaunchAnimation(QString splashIcon, QString title, qreal x, qreal y, qreal sourceIconSize)
{
    Q_EMIT openAppLaunchAnimationRequested(splashIcon, title, x, y, sourceIconSize);
}

void ShellDBusObject::closeAppLaunchAnimation()
{
    Q_EMIT closeAppLaunchAnimationRequested();
}

void ShellDBusObject::openHomeScreen()
{
    Q_EMIT openHomeScreenRequested();
}

void ShellDBusObject::resetHomeScreenPosition()
{
    Q_EMIT resetHomeScreenPositionRequested();
}

void ShellDBusObject::showVolumeOSD()
{
    Q_EMIT showVolumeOSDRequested();
}
