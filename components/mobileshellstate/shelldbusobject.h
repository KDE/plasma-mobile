// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QString>

class ShellDBusObject : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.plasmashell")

public:
    ShellDBusObject(QObject *parent = nullptr);
    static ShellDBusObject *self();

    // called by QML
    Q_INVOKABLE void registerObject();

Q_SIGNALS:
    Q_SCRIPTABLE void doNotDisturbChanged();
    Q_SCRIPTABLE void isActionDrawerOpenChanged();
    Q_SCRIPTABLE void isTaskSwitcherVisibleChanged();
    Q_SCRIPTABLE void openActionDrawerRequested();
    Q_SCRIPTABLE void closeActionDrawerRequested();
    Q_SCRIPTABLE void openAppLaunchAnimationRequested(QString splashIcon, QString title, qreal x, qreal y, qreal sourceIconSize);
    Q_SCRIPTABLE void closeAppLaunchAnimationRequested();
    Q_SCRIPTABLE void openHomeScreenRequested();
    Q_SCRIPTABLE void resetHomeScreenPositionRequested();
    Q_SCRIPTABLE void showVolumeOSDRequested();

public Q_SLOTS:
    Q_SCRIPTABLE bool doNotDisturb();
    Q_SCRIPTABLE void setDoNotDisturb(bool value);

    // TODO: Account for multiple action drawers?
    Q_SCRIPTABLE bool isActionDrawerOpen();
    Q_SCRIPTABLE void setIsActionDrawerOpen(bool value);

    Q_SCRIPTABLE bool isTaskSwitcherVisible();
    Q_SCRIPTABLE void setIsTaskSwitcherVisible(bool value);

    Q_SCRIPTABLE void openActionDrawer();
    Q_SCRIPTABLE void closeActionDrawer();

    Q_SCRIPTABLE void openAppLaunchAnimation(QString splashIcon, QString title, qreal x, qreal y, qreal sourceIconSize);
    Q_SCRIPTABLE void closeAppLaunchAnimation();

    Q_SCRIPTABLE void openHomeScreen();
    Q_SCRIPTABLE void resetHomeScreenPosition();
    Q_SCRIPTABLE void showVolumeOSD();

private:
    bool m_initialized = false;

    bool m_doNotDisturb = false;
    bool m_isActionDrawerOpen = false;
    bool m_isTaskSwitcherVisible = false;
};
