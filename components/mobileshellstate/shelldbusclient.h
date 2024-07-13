// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "plasmashellmobileinterface.h"

#include <QDBusServiceWatcher>
#include <QObject>
#include <QString>
#include <qqmlregistration.h>

class ShellDBusClient : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool doNotDisturb READ doNotDisturb WRITE setDoNotDisturb NOTIFY doNotDisturbChanged)
    Q_PROPERTY(bool isActionDrawerOpen READ isActionDrawerOpen WRITE setIsActionDrawerOpen NOTIFY isActionDrawerOpenChanged)
    Q_PROPERTY(bool isTaskSwitcherVisible READ isTaskSwitcherVisible NOTIFY isTaskSwitcherVisibleChanged)

public:
    explicit ShellDBusClient(QObject *parent = nullptr);

    bool doNotDisturb() const;
    void setDoNotDisturb(bool value);

    bool isActionDrawerOpen() const;
    void setIsActionDrawerOpen(bool value);

    bool isTaskSwitcherVisible() const;

    Q_INVOKABLE void openActionDrawer();
    Q_INVOKABLE void closeActionDrawer();

    Q_INVOKABLE void
    openAppLaunchAnimationWithPosition(int screen, QString splashIcon, QString title, QString storageId, qreal x, qreal y, qreal sourceIconSize);
    Q_INVOKABLE void triggerAppLaunchMaximizePanelAnimation(int screen, QString color);

    Q_INVOKABLE void openHomeScreen();
    Q_INVOKABLE void resetHomeScreenPosition();
    Q_INVOKABLE void showVolumeOSD();

Q_SIGNALS:
    void isActionDrawerOpenChanged();
    void doNotDisturbChanged();
    void isTaskSwitcherVisibleChanged();
    void openActionDrawerRequested();
    void closeActionDrawerRequested();
    void appLaunchMaximizePanelAnimationTriggered(int screen, QString color);
    void openHomeScreenRequested();
    void resetHomeScreenPositionRequested();
    void showVolumeOSDRequested();

private Q_SLOTS:
    void updateDoNotDisturb();
    void updateIsActionDrawerOpen();
    void updateIsTaskSwitcherVisible();

private:
    void connectSignals();

    OrgKdePlasmashellInterface *m_interface;
    QDBusServiceWatcher *m_watcher;

    bool m_doNotDisturb = false;
    bool m_isActionDrawerOpen = false;
    bool m_isTaskSwitcherVisible = false;

    bool m_connected = false;
};
