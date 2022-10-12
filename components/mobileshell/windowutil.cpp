/*
 *  SPDX-FileCopyrightText: 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
 *  SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "windowutil.h"

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

WindowUtil *WindowUtil::instance()
{
    static WindowUtil *inst = new WindowUtil();
    return inst;
}

bool WindowUtil::isShowingDesktop() const
{
    return m_showingDesktop;
}

bool WindowUtil::allWindowsMinimized() const
{
    return m_allWindowsMinimized;
}

bool WindowUtil::allWindowsMinimizedExcludingShell() const
{
    return m_allWindowsMinimizedExcludingShell;
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

    // loop through windows
    bool newAllMinimized = true;
    bool newAllMinimizedExcludingShell = true;
    for (auto *w : m_windowManagement->windows()) {
        if (!w->isMinimized() && !w->skipTaskbar() && !w->isFullscreen()) {
            newAllMinimized = false;

            if (w->appId() != QStringLiteral("org.kde.plasmashell")) {
                newAllMinimizedExcludingShell = false;
            }
        }
    }

    if (newAllMinimized != m_allWindowsMinimized) {
        m_allWindowsMinimized = newAllMinimized;
        Q_EMIT allWindowsMinimizedChanged();
    }
    if (newAllMinimizedExcludingShell != m_allWindowsMinimizedExcludingShell) {
        m_allWindowsMinimizedExcludingShell = newAllMinimizedExcludingShell;
        Q_EMIT allWindowsMinimizedExcludingShellChanged();
    }

    // TODO: connect to closeableChanged, not needed right now as KWin doesn't provide this changeable
    Q_EMIT hasCloseableActiveWindowChanged();
}

bool WindowUtil::hasCloseableActiveWindow() const
{
    return m_activeWindow && m_activeWindow->isCloseable() /*&& !m_activeWindow->isMinimized()*/;
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
    if (m_activeWindow) {
        if (m_activeWindow->appId() == QStringLiteral("org.kde.plasmashell") && !m_activeWindowIsShell) {
            m_activeWindowIsShell = true;
            Q_EMIT activeWindowIsShellChanged();
        } else if (m_activeWindow->appId() != QStringLiteral("org.kde.plasmashell") && m_activeWindowIsShell) {
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
