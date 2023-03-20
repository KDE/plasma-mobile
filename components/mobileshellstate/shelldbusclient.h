// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "plasmashellmobileinterface.h"

#include <QDBusServiceWatcher>
#include <QObject>
#include <QString>

class ShellDBusClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool doNotDisturb READ doNotDisturb WRITE setDoNotDisturb NOTIFY doNotDisturbChanged);
    Q_PROPERTY(bool isActionDrawerOpen READ isActionDrawerOpen WRITE setIsActionDrawerOpen NOTIFY isActionDrawerOpenChanged);

public:
    explicit ShellDBusClient(QObject *parent = nullptr);
    static ShellDBusClient *self();

    bool doNotDisturb();
    void setDoNotDisturb(bool value);

    bool isActionDrawerOpen();
    void setIsActionDrawerOpen(bool value);

    Q_INVOKABLE void openActionDrawer();
    Q_INVOKABLE void closeActionDrawer();

    Q_INVOKABLE void openAppLaunchAnimation(QString splashIcon, QString title, qreal x, qreal y, qreal sourceIconSize);
    Q_INVOKABLE void closeAppLaunchAnimation();

    Q_INVOKABLE void openHomeScreen();
    Q_INVOKABLE void resetHomeScreenPosition();

Q_SIGNALS:
    void isActionDrawerOpenChanged();
    void doNotDisturbChanged();
    void openActionDrawerRequested();
    void closeActionDrawerRequested();
    void openAppLaunchAnimationRequested(QString splashIcon, QString title, qreal x, qreal y, qreal sourceIconSize);
    void closeAppLaunchAnimationRequested();
    void openHomeScreenRequested();
    void resetHomeScreenPositionRequested();

private Q_SLOTS:
    void updateDoNotDisturb();
    void updateIsActionDrawerOpen();

private:
    void connectSignals();

    OrgKdePlasmashellInterface *m_interface;
    QDBusServiceWatcher *m_watcher;

    bool m_doNotDisturb;
    bool m_isActionDrawerOpen;
    bool m_connected;
};
