// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "panelsettingsdbusclient.h"

#include <QDBusServiceWatcher>

PanelSettingsDBusClient::PanelSettingsDBusClient(QObject *parent)
    : QObject{parent}
    , m_interface{nullptr}
    , m_connected{false}
{
}

void PanelSettingsDBusClient::connectToDBus()
{
    if (m_interface) {
        return;
    }
    m_interface = new OrgKdePlasmashellMobilePanelsInterface{QStringLiteral("org.kde.plasmashell"),
                                                             QStringLiteral("/Mobile/Panels/") + m_screenName.replace("-", ""),
                                                             QDBusConnection::sessionBus(),
                                                             this};

    // Check if the service is already running
    if (QDBusConnection::sessionBus().interface()->isServiceRegistered(QStringLiteral("org.kde.plasmashell"))) {
        m_connected = true;
        if (m_interface->isValid()) {
            connectSignals();
        }
    }

    connect(QDBusConnection::sessionBus().interface(),
            &QDBusConnectionInterface::serviceOwnerChanged,
            this,
            [this](const QString &service, const QString &oldOwner, const QString &newOwner) {
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

QString PanelSettingsDBusClient::screenName() const
{
    return m_screenName;
}

void PanelSettingsDBusClient::setScreenName(const QString &screenName)
{
    if (screenName == m_screenName) {
        return;
    }
    m_screenName = screenName;
    Q_EMIT screenNameChanged();

    connectToDBus();
}

void PanelSettingsDBusClient::connectSignals()
{
    connect(m_interface, &OrgKdePlasmashellMobilePanelsInterface::statusBarHeightChanged, this, &PanelSettingsDBusClient::updateStatusBarHeight);
    connect(m_interface, &OrgKdePlasmashellMobilePanelsInterface::statusBarLeftPaddingChanged, this, &PanelSettingsDBusClient::updateStatusBarLeftPadding);
    connect(m_interface, &OrgKdePlasmashellMobilePanelsInterface::statusBarRightPaddingChanged, this, &PanelSettingsDBusClient::updateStatusBarRightPadding);
    connect(m_interface, &OrgKdePlasmashellMobilePanelsInterface::statusBarCenterSpacingChanged, this, &PanelSettingsDBusClient::updateStatusBarCenterSpacing);
    connect(m_interface, &OrgKdePlasmashellMobilePanelsInterface::navigationPanelHeightChanged, this, &PanelSettingsDBusClient::updateNavigationPanelHeight);
    connect(m_interface,
            &OrgKdePlasmashellMobilePanelsInterface::navigationPanelLeftPaddingChanged,
            this,
            &PanelSettingsDBusClient::updateNavigationPanelLeftPadding);
    connect(m_interface,
            &OrgKdePlasmashellMobilePanelsInterface::navigationPanelRightPaddingChanged,
            this,
            &PanelSettingsDBusClient::updateNavigationPanelRightPadding);

    // Initial state fetch
    updateStatusBarHeight();
    updateStatusBarLeftPadding();
    updateStatusBarRightPadding();
    updateStatusBarCenterSpacing();
    updateNavigationPanelHeight();
    updateNavigationPanelLeftPadding();
    updateNavigationPanelRightPadding();
}

qreal PanelSettingsDBusClient::statusBarHeight() const
{
    return m_statusBarHeight;
}

qreal PanelSettingsDBusClient::statusBarLeftPadding() const
{
    return m_statusBarLeftPadding;
}

qreal PanelSettingsDBusClient::statusBarRightPadding() const
{
    return m_statusBarRightPadding;
}

qreal PanelSettingsDBusClient::statusBarCenterSpacing() const
{
    return m_statusBarCenterSpacing;
}

qreal PanelSettingsDBusClient::navigationPanelHeight() const
{
    return m_navigationPanelHeight;
}

qreal PanelSettingsDBusClient::navigationPanelLeftPadding() const
{
    return m_navigationPanelLeftPadding;
}

qreal PanelSettingsDBusClient::navigationPanelRightPadding() const
{
    return m_navigationPanelRightPadding;
}

void PanelSettingsDBusClient::updateStatusBarHeight()
{
    auto reply = m_interface->statusBarHeight();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<qreal> reply = *watcher;
        qreal statusBarHeight = reply.argumentAt<0>();

        if (statusBarHeight != m_statusBarHeight) {
            m_statusBarHeight = statusBarHeight;
            Q_EMIT statusBarHeightChanged();
        }

        watcher->deleteLater();
    });
}

void PanelSettingsDBusClient::updateStatusBarLeftPadding()
{
    auto reply = m_interface->statusBarLeftPadding();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<qreal> reply = *watcher;
        qreal statusBarLeftPadding = reply.argumentAt<0>();

        if (statusBarLeftPadding != m_statusBarLeftPadding) {
            m_statusBarLeftPadding = statusBarLeftPadding;
            Q_EMIT statusBarLeftPaddingChanged();
        }

        watcher->deleteLater();
    });
}

void PanelSettingsDBusClient::updateStatusBarRightPadding()
{
    auto reply = m_interface->statusBarRightPadding();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<qreal> reply = *watcher;
        qreal statusBarRightPadding = reply.argumentAt<0>();

        if (statusBarRightPadding != m_statusBarRightPadding) {
            m_statusBarRightPadding = statusBarRightPadding;
            Q_EMIT statusBarRightPaddingChanged();
        }

        watcher->deleteLater();
    });
}

void PanelSettingsDBusClient::updateStatusBarCenterSpacing()
{
    auto reply = m_interface->statusBarCenterSpacing();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<qreal> reply = *watcher;
        qreal statusBarCenterSpacing = reply.argumentAt<0>();

        if (statusBarCenterSpacing != m_statusBarCenterSpacing) {
            m_statusBarCenterSpacing = statusBarCenterSpacing;
            Q_EMIT statusBarCenterSpacingChanged();
        }

        watcher->deleteLater();
    });
}

void PanelSettingsDBusClient::updateNavigationPanelHeight()
{
    auto reply = m_interface->navigationPanelHeight();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<qreal> reply = *watcher;
        qreal navigationPanelHeight = reply.argumentAt<0>();

        if (navigationPanelHeight != m_navigationPanelHeight) {
            m_navigationPanelHeight = navigationPanelHeight;
            Q_EMIT navigationPanelHeightChanged();
        }

        watcher->deleteLater();
    });
}

void PanelSettingsDBusClient::updateNavigationPanelLeftPadding()
{
    auto reply = m_interface->navigationPanelLeftPadding();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<qreal> reply = *watcher;
        qreal navigationPanelLeftPadding = reply.argumentAt<0>();

        if (navigationPanelLeftPadding != m_navigationPanelLeftPadding) {
            m_navigationPanelLeftPadding = navigationPanelLeftPadding;
            Q_EMIT navigationPanelLeftPaddingChanged();
        }

        watcher->deleteLater();
    });
}

void PanelSettingsDBusClient::updateNavigationPanelRightPadding()
{
    auto reply = m_interface->navigationPanelRightPadding();
    auto watcher = new QDBusPendingCallWatcher(reply, this);

    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](auto watcher) {
        QDBusPendingReply<qreal> reply = *watcher;
        qreal navigationPanelRightPadding = reply.argumentAt<0>();

        if (navigationPanelRightPadding != m_navigationPanelRightPadding) {
            m_navigationPanelRightPadding = navigationPanelRightPadding;
            Q_EMIT navigationPanelRightPaddingChanged();
        }

        watcher->deleteLater();
    });
}
