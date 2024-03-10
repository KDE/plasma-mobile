/*
 *  SPDX-FileCopyrightText: 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "windowutil.h"

#include <KApplicationTrader>

#include <QGuiApplication>

constexpr int ACTIVE_WINDOW_UPDATE_INVERVAL = 0;

WindowUtil::WindowUtil(QObject *parent)
    : QObject{parent}
    , m_activeWindowTimer{new QTimer{this}}
{
    // use 0 tick timer to update active window to ensure window state has finished changing
    m_activeWindowTimer->setSingleShot(true);
    m_activeWindowTimer->setInterval(ACTIVE_WINDOW_UPDATE_INVERVAL);
    connect(m_activeWindowTimer, &QTimer::timeout, this, &WindowUtil::updateActiveWindow);

    connect(this, &WindowUtil::activeWindowChanged, this, &WindowUtil::updateActiveWindowIsShell);

    initWayland();
}

bool WindowUtil::isShowingDesktop() const
{
    return m_showingDesktop;
}

bool WindowUtil::activeWindowIsShell() const
{
    return m_activeWindowIsShell;
}

void WindowUtil::initWayland()
{
    if (!QGuiApplication::platformName().startsWith(QLatin1String("wayland"), Qt::CaseInsensitive)) {
        qWarning() << "Plasma Mobile must use wayland! The current platform detected is:" << QGuiApplication::platformName();
        return;
    }

    using namespace KWayland::Client;
    ConnectionThread *connection = ConnectionThread::fromApplication(this);

    if (!connection) {
        return;
    }

    auto *registry = new Registry(this);
    registry->create(connection);

    connect(registry, &Registry::plasmaWindowManagementAnnounced, this, [this, registry](quint32 name, quint32 version) {
        m_windowManagement = registry->createPlasmaWindowManagement(name, version, this);
        qRegisterMetaType<QVector<int>>("QVector<int>");

        connect(m_windowManagement, &KWayland::Client::PlasmaWindowManagement::windowCreated, this, [this](KWayland::Client::PlasmaWindow *window) {
            Q_EMIT windowCreated(window);
        });
        connect(m_windowManagement, &KWayland::Client::PlasmaWindowManagement::windowCreated, this, &WindowUtil::windowCreatedSlot);

        connect(m_windowManagement, &PlasmaWindowManagement::showingDesktopChanged, this, &WindowUtil::updateShowingDesktop);
        connect(m_windowManagement, &PlasmaWindowManagement::activeWindowChanged, m_activeWindowTimer, qOverload<>(&QTimer::start));

        m_activeWindowTimer->start();
    });

    connect(registry, &Registry::plasmaActivationFeedbackAnnounced, this, [this, registry](quint32 name, quint32 version) {
        auto iface = registry->createPlasmaActivationFeedback(name, version, this);

        connect(iface, &PlasmaActivationFeedback::activation, this, [this](PlasmaActivation *activation) {
            connect(activation, &PlasmaActivation::applicationId, this, [this, activation](const QString &appId) {
                // do not show activation screen for the plasmashell process
                if (appId == "org.kde.plasmashell") {
                    return;
                }

                const auto servicesFound = KApplicationTrader::query([&appId](const KService::Ptr &service) {
                    if (service->exec().isEmpty())
                        return false;

                    if (service->desktopEntryName().compare(appId, Qt::CaseInsensitive) == 0)
                        return true;

                    const auto idWithoutDesktop = QString(appId).remove(QStringLiteral(".desktop"));
                    if (service->desktopEntryName().compare(idWithoutDesktop, Qt::CaseInsensitive) == 0)
                        return true;

                    const auto renamedFrom = service->property<QStringList>(QStringLiteral("X-Flatpak-RenamedFrom"));
                    if (renamedFrom.contains(appId, Qt::CaseInsensitive) || renamedFrom.contains(idWithoutDesktop, Qt::CaseInsensitive))
                        return true;

                    return false;
                });

                if (!servicesFound.isEmpty()) {
                    QString iconName = servicesFound.constFirst()->icon();

                    // Connect signal to when activation is complete to trigger event
                    connect(activation, &PlasmaActivation::finished, this, [this, appId, iconName]() {
                        Q_EMIT appActivationFinished(appId, iconName);
                    });

                    // Trigger app activation event
                    Q_EMIT appActivationStarted(appId, iconName);
                } else {
                    qDebug() << "WindowUtil: Could not find service" << appId;
                }
            });
        });
    });

    registry->setup();
    connection->roundtrip();
}

void WindowUtil::updateActiveWindow()
{
    if (!m_windowManagement || m_activeWindow == m_windowManagement->activeWindow()) {
        return;
    }

    using namespace KWayland::Client;
    if (m_activeWindow) {
        disconnect(m_activeWindow.data(), &PlasmaWindow::closeableChanged, this, &WindowUtil::hasCloseableActiveWindowChanged);
        disconnect(m_activeWindow.data(), &PlasmaWindow::unmapped, this, &WindowUtil::forgetActiveWindow);
    }

    m_activeWindow = m_windowManagement->activeWindow();
    Q_EMIT activeWindowChanged();

    if (m_activeWindow) {
        connect(m_activeWindow.data(), &PlasmaWindow::closeableChanged, this, &WindowUtil::hasCloseableActiveWindowChanged);
        connect(m_activeWindow.data(), &PlasmaWindow::unmapped, this, &WindowUtil::forgetActiveWindow);
    }

    Q_EMIT hasCloseableActiveWindowChanged();
}

bool WindowUtil::hasCloseableActiveWindow() const
{
    return m_activeWindow && m_activeWindow->isCloseable() /*&& !m_activeWindow->isMinimized()*/;
}

bool WindowUtil::activateWindowByStorageId(const QString &storageId)
{
    auto windows = windowsFromStorageId(storageId);

    if (!windows.empty()) {
        windows[0]->requestActivate();
        return true;
    }

    return false;
}

void WindowUtil::closeActiveWindow()
{
    if (m_activeWindow) {
        m_activeWindow->requestClose();
    }
}

void WindowUtil::requestShowingDesktop(bool showingDesktop)
{
    if (!m_windowManagement) {
        return;
    }
    m_windowManagement->setShowingDesktop(showingDesktop);
}

void WindowUtil::minimizeAll()
{
    if (!m_windowManagement) {
        qWarning() << "Ignoring request for minimizing all windows since window management hasn't been announced yet!";
        return;
    }

    for (auto *w : m_windowManagement->windows()) {
        if (!w->isMinimized()) {
            w->requestToggleMinimized();
        }
    }
}

void WindowUtil::unsetAllMinimizedGeometries(QQuickItem *parent)
{
    if (!m_windowManagement) {
        qWarning() << "Ignoring request for minimizing all windows since window management hasn't been announced yet!";
        return;
    }

    if (!parent) {
        return;
    }

    QWindow *window = parent->window();
    if (!window) {
        return;
    }

    KWayland::Client::Surface *surface = KWayland::Client::Surface::fromWindow(window);
    if (!surface) {
        return;
    }

    for (auto *w : m_windowManagement->windows()) {
        w->unsetMinimizedGeometry(surface);
    }
}

void WindowUtil::updateShowingDesktop(bool showing)
{
    if (showing != m_showingDesktop) {
        m_showingDesktop = showing;
        Q_EMIT showingDesktopChanged(m_showingDesktop);
    }
}

void WindowUtil::updateActiveWindowIsShell()
{
    auto activeWindow = m_windowManagement->activeWindow();
    if (activeWindow) {
        if (activeWindow->appId() == QStringLiteral("org.kde.plasmashell") && !m_activeWindowIsShell) {
            m_activeWindowIsShell = true;
            Q_EMIT activeWindowIsShellChanged();
        } else if (activeWindow->appId() != QStringLiteral("org.kde.plasmashell") && m_activeWindowIsShell) {
            m_activeWindowIsShell = false;
            Q_EMIT activeWindowIsShellChanged();
        }
    }
}

void WindowUtil::forgetActiveWindow()
{
    using namespace KWayland::Client;
    if (m_activeWindow) {
        disconnect(m_activeWindow.data(), &PlasmaWindow::closeableChanged, this, &WindowUtil::hasCloseableActiveWindowChanged);
        disconnect(m_activeWindow.data(), &PlasmaWindow::unmapped, this, &WindowUtil::forgetActiveWindow);
    }
    m_activeWindow.clear();
    Q_EMIT hasCloseableActiveWindowChanged();
}

QList<KWayland::Client::PlasmaWindow *> WindowUtil::windowsFromStorageId(const QString &storageId) const
{
    if (!m_windows.contains(storageId)) {
        return {};
    }
    return m_windows[storageId];
}

void WindowUtil::windowCreatedSlot(KWayland::Client::PlasmaWindow *window)
{
    QString storageId = window->appId() + QStringLiteral(".desktop");

    // ignore empty windows
    if (storageId == ".desktop" || storageId == "org.kde.plasmashell.desktop") {
        return;
    }

    if (!m_windows.contains(storageId)) {
        m_windows[storageId] = {};
    }
    m_windows[storageId].push_back(window);

    // listen for window close
    connect(window, &KWayland::Client::PlasmaWindow::unmapped, this, [this, storageId]() {
        m_windows.remove(storageId);
        Q_EMIT windowChanged(storageId);
    });

    Q_EMIT windowChanged(storageId);
}
