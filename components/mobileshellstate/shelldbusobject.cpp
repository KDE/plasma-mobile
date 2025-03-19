// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "shelldbusobject.h"
#include "mobileadaptor.h"

#include <QDBusConnection>

ShellDBusObject::ShellDBusObject(QObject *parent)
    : QObject{parent}
    , m_startupFeedbackModel{new StartupFeedbackModel{this}}
{
}

void ShellDBusObject::registerObject()
{
    if (!m_initialized) {
        new PlasmashellAdaptor{this};
        QDBusConnection::sessionBus().registerObject(QStringLiteral("/Mobile"), this);
        m_initialized = true;
    }
}

StartupFeedbackModel *ShellDBusObject::startupFeedbackModel()
{
    return m_startupFeedbackModel;
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

QString ShellDBusObject::panelState()
{
    return m_panelState;
}

void ShellDBusObject::setPanelState(QString state)
{
    if (state != m_panelState) {
        m_panelState = state;
        Q_EMIT panelStateChanged();
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

bool ShellDBusObject::isVolumeOSDOpen()
{
    return m_isVolumeOSDOpen;
}

void ShellDBusObject::setIsVolumeOSDOpen(bool value)
{
    if (value != m_isVolumeOSDOpen) {
        m_isVolumeOSDOpen = value;
        Q_EMIT isVolumeOSDOpenChanged();
    }
}

bool ShellDBusObject::isNotificationPopupDrawerOpen()
{
    return m_isNotificationPopupDrawerOpen;
}

void ShellDBusObject::setIsNotificationPopupDrawerOpen(bool value)
{
    if (value != m_isNotificationPopupDrawerOpen) {
        m_isNotificationPopupDrawerOpen = value;
        Q_EMIT isNotificationPopupDrawerOpenChanged();
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

void ShellDBusObject::openAppLaunchAnimationWithPosition(int screen,
                                                         QString splashIcon,
                                                         QString title,
                                                         QString storageId,
                                                         qreal x,
                                                         qreal y,
                                                         qreal sourceIconSize)
{
    if (!m_startupFeedbackModel) {
        return;
    }

    StartupFeedback *feedback = new StartupFeedback{m_startupFeedbackModel, splashIcon, title, storageId, x, y, sourceIconSize, screen};
    m_startupFeedbackModel->addApp(feedback);
}

void ShellDBusObject::triggerAppLaunchMaximizePanelAnimation(int screen, QString color)
{
    Q_EMIT appLaunchMaximizePanelAnimationTriggered(screen, color);
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
