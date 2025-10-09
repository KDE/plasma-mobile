// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "plasmashellmobilepanelsinterface.h"

#include <QDBusServiceWatcher>
#include <QObject>
#include <QString>
#include <qqmlregistration.h>

class PanelSettingsDBusClient : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    // Client must set the screen they want to get details for
    Q_PROPERTY(QString screenName READ screenName WRITE setScreenName NOTIFY screenNameChanged)

    Q_PROPERTY(qreal statusBarHeight READ statusBarHeight NOTIFY statusBarHeightChanged)
    Q_PROPERTY(qreal statusBarLeftPadding READ statusBarLeftPadding NOTIFY statusBarLeftPaddingChanged)
    Q_PROPERTY(qreal statusBarRightPadding READ statusBarRightPadding NOTIFY statusBarRightPaddingChanged)
    Q_PROPERTY(qreal statusBarCenterSpacing READ statusBarCenterSpacing NOTIFY statusBarCenterSpacingChanged)

    Q_PROPERTY(qreal navigationPanelHeight READ navigationPanelHeight NOTIFY navigationPanelHeightChanged)
    Q_PROPERTY(qreal navigationPanelLeftPadding READ navigationPanelLeftPadding NOTIFY navigationPanelLeftPaddingChanged)
    Q_PROPERTY(qreal navigationPanelRightPadding READ navigationPanelRightPadding NOTIFY navigationPanelRightPaddingChanged)

public:
    explicit PanelSettingsDBusClient(QObject *parent = nullptr);

    void connectToDBus();

    QString screenName() const;
    void setScreenName(const QString &screenName);

    qreal statusBarHeight() const;
    qreal statusBarLeftPadding() const;
    qreal statusBarRightPadding() const;
    qreal statusBarCenterSpacing() const;

    qreal navigationPanelHeight() const;
    qreal navigationPanelLeftPadding() const;
    qreal navigationPanelRightPadding() const;

Q_SIGNALS:
    void screenNameChanged();
    void statusBarHeightChanged();
    void statusBarLeftPaddingChanged();
    void statusBarRightPaddingChanged();
    void statusBarCenterSpacingChanged();
    void navigationPanelHeightChanged();
    void navigationPanelLeftPaddingChanged();
    void navigationPanelRightPaddingChanged();

private Q_SLOTS:
    void updateStatusBarHeight();
    void updateStatusBarLeftPadding();
    void updateStatusBarRightPadding();
    void updateStatusBarCenterSpacing();
    void updateNavigationPanelHeight();
    void updateNavigationPanelLeftPadding();
    void updateNavigationPanelRightPadding();

private:
    void connectSignals();

    OrgKdePlasmashellMobilePanelsInterface *m_interface;
    QDBusServiceWatcher *m_watcher;

    QString m_screenName;

    qreal m_statusBarHeight = -1;
    qreal m_statusBarLeftPadding = 0;
    qreal m_statusBarRightPadding = 0;
    qreal m_statusBarCenterSpacing = 0;
    qreal m_navigationPanelHeight = -1;
    qreal m_navigationPanelLeftPadding = 0;
    qreal m_navigationPanelRightPadding = 0;

    bool m_connected = false;
};
