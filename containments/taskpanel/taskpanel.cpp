/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "taskpanel.h"

#include <QDebug>
#include <QQuickItem>
#include <QQuickWindow>
#include <QtQml>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/output.h>
#include <KWayland/Client/plasmashell.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>
#include <Plasma/Package>

#include <virtualkeyboardinterface.h>

static const QString s_kwinService = QStringLiteral("org.kde.KWin");
constexpr int ACTIVE_WINDOW_UPDATE_INVERVAL = 250;

TaskPanel::TaskPanel(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args)
    , m_showingDesktop(false)
    , m_windowManagement(nullptr)
{
    setHasConfigurationInterface(true);
    m_activeTimer = new QTimer(this);
    m_activeTimer->setSingleShot(true);
    m_activeTimer->setInterval(ACTIVE_WINDOW_UPDATE_INVERVAL);
    connect(m_activeTimer, &QTimer::timeout, this, &TaskPanel::updateActiveWindow);
    initWayland();

    qmlRegisterUncreatableType<KWayland::Client::Output>("org.kde.plasma.phone.taskpanel", 1, 0, "Output", "nope");

    connect(this, &Plasma::Containment::locationChanged, this, &TaskPanel::locationChanged);
    connect(this, &Plasma::Containment::locationChanged, this, [this] {
        auto l = location();
        setFormFactor(l == Plasma::Types::LeftEdge || l == Plasma::Types::RightEdge ? Plasma::Types::Vertical : Plasma::Types::Horizontal);
    });
}

TaskPanel::~TaskPanel() = default;

void TaskPanel::requestShowingDesktop(bool showingDesktop)
{
    if (!m_windowManagement) {
        return;
    }
    m_windowManagement->setShowingDesktop(showingDesktop);
}

void TaskPanel::initWayland()
{
    if (!QGuiApplication::platformName().startsWith(QLatin1String("wayland"), Qt::CaseInsensitive)) {
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
        connect(m_windowManagement, &PlasmaWindowManagement::showingDesktopChanged, this, [this](bool showing) {
            if (showing == m_showingDesktop) {
                return;
            }
            m_showingDesktop = showing;
            emit showingDesktopChanged(m_showingDesktop);
        });
        connect(m_windowManagement, &KWayland::Client::PlasmaWindowManagement::activeWindowChanged, m_activeTimer, qOverload<>(&QTimer::start));

        m_activeTimer->start();
    });
    connect(registry, &Registry::plasmaShellAnnounced, this, [this, registry](quint32 name, quint32 version) {
        m_shellInterface = registry->createPlasmaShell(name, version, this);

        if (!m_panel) {
            return;
        }
        Surface *s = Surface::fromWindow(m_panel);
        if (!s) {
            return;
        }
        m_shellSurface = m_shellInterface->createSurface(s, this);
        m_shellSurface->setSkipTaskbar(true);
    });
    registry->setup();
    connection->roundtrip();
}

QWindow *TaskPanel::panel()
{
    return m_panel;
}

void TaskPanel::setPanel(QWindow *panel)
{
    if (panel == m_panel) {
        return;
    }

    if (m_panel) {
        disconnect(m_panel, &QWindow::visibilityChanged, this, &TaskPanel::updatePanelVisibility);
    }
    m_panel = panel;
    connect(m_panel, &QWindow::visibilityChanged, this, &TaskPanel::updatePanelVisibility, Qt::QueuedConnection);
    emit panelChanged();
    updatePanelVisibility();
}

void TaskPanel::updatePanelVisibility()
{
    using namespace KWayland::Client;
    if (!m_panel->isVisible()) {
        return;
    }

    Surface *s = Surface::fromWindow(m_panel);

    if (!s) {
        return;
    }

    m_shellSurface = m_shellInterface->createSurface(s, this);
    if (m_shellSurface) {
        m_shellSurface->setSkipTaskbar(true);
    }
}

void TaskPanel::updateActiveWindow()
{
    if (!m_windowManagement || m_activeWindow == m_windowManagement->activeWindow()) {
        return;
    }
    if (m_activeWindow) {
        disconnect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::closeableChanged, this, &TaskPanel::hasCloseableActiveWindowChanged);
        disconnect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::unmapped, this, &TaskPanel::forgetActiveWindow);
    }
    m_activeWindow = m_windowManagement->activeWindow();

    if (m_activeWindow) {
        connect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::closeableChanged, this, &TaskPanel::hasCloseableActiveWindowChanged);
        connect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::unmapped, this, &TaskPanel::forgetActiveWindow);
    }

    bool newAllMinimized = true;
    for (auto *w : m_windowManagement->windows()) {
        if (!w->isMinimized() && !w->skipTaskbar() && !w->isFullscreen() /*&& w->appId() != QStringLiteral("org.kde.plasmashell")*/) {
            newAllMinimized = false;
            break;
        }
    }
    if (newAllMinimized != m_allMinimized) {
        m_allMinimized = newAllMinimized;
        emit allMinimizedChanged();
    }
    // TODO: connect to closeableChanged, not needed right now as KWin doesn't provide this changeable
    emit hasCloseableActiveWindowChanged();
}

bool TaskPanel::hasCloseableActiveWindow() const
{
    return m_activeWindow && m_activeWindow->isCloseable() /*&& !m_activeWindow->isMinimized()*/;
}

void TaskPanel::forgetActiveWindow()
{
    if (m_activeWindow) {
        disconnect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::closeableChanged, this, &TaskPanel::hasCloseableActiveWindowChanged);
        disconnect(m_activeWindow.data(), &KWayland::Client::PlasmaWindow::unmapped, this, &TaskPanel::forgetActiveWindow);
    }
    m_activeWindow.clear();
    emit hasCloseableActiveWindowChanged();
}

void TaskPanel::closeActiveWindow()
{
    if (m_activeWindow) {
        m_activeWindow->requestClose();
    }
}

K_PLUGIN_CLASS_WITH_JSON(TaskPanel, "metadata.json")

#include "taskpanel.moc"
