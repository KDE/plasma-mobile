/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "taskpanel.h"

#include <QDBusPendingReply>
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

#include <virtualkeyboardinterface.h>

// register type for Keyboards.KWinVirtualKeyboard.forceActivate();
Q_DECLARE_METATYPE(QDBusPendingReply<>)

TaskPanel::TaskPanel(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment(parent, data, args)
{
    setHasConfigurationInterface(true);
    initWayland();

    qmlRegisterUncreatableType<KWayland::Client::Output>("org.kde.plasma.phone.taskpanel", 1, 0, "Output", "nope");

    // register type for Keyboards.KWinVirtualKeyboard.forceActivate();
    qRegisterMetaType<QDBusPendingReply<>>();

    connect(this, &Plasma::Containment::locationChanged, this, &TaskPanel::locationChanged);
    connect(this, &Plasma::Containment::locationChanged, this, [this] {
        auto l = location();
        setFormFactor(l == Plasma::Types::LeftEdge || l == Plasma::Types::RightEdge ? Plasma::Types::Vertical : Plasma::Types::Horizontal);
    });
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
    Q_EMIT panelChanged();
    updatePanelVisibility();
}

void TaskPanel::setPanelHeight(qreal height)
{
    if (m_panel) {
        m_panel->setHeight(height);
    }
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

K_PLUGIN_CLASS_WITH_JSON(TaskPanel, "package/metadata.json")

#include "taskpanel.moc"
