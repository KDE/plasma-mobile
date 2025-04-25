// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "raiselockscreen.h"

#include <QQuickItem>
#include <QWaylandClientExtensionTemplate>
#include <qpa/qplatformnativeinterface.h>

#include <KWaylandExtras>
#include <KWindowSystem>

#include "qwayland-kde-lockscreen-overlay-v1.h"

class WaylandAboveLockscreen : public QWaylandClientExtensionTemplate<WaylandAboveLockscreen>, public QtWayland::kde_lockscreen_overlay_v1
{
public:
    WaylandAboveLockscreen()
        : QWaylandClientExtensionTemplate<WaylandAboveLockscreen>(1)
    {
        initialize();
    }

    bool allowWindow(QWindow *window)
    {
        QPlatformNativeInterface *native = qGuiApp->platformNativeInterface();
        wl_surface *surface = reinterpret_cast<wl_surface *>(native->nativeResourceForWindow(QByteArrayLiteral("surface"), window));

        if (!surface) {
            return false;
        }

        allow(surface);
        return true;
    }
};

RaiseLockscreen::RaiseLockscreen(QObject *parent)
    : QObject{parent}
{
}

RaiseLockscreen::~RaiseLockscreen()
{
}

QWindow *RaiseLockscreen::window() const
{
    return m_window;
}

void RaiseLockscreen::setWindow(QWindow *window)
{
    m_window = window;
    Q_EMIT windowChanged();
}

bool RaiseLockscreen::initialized() const
{
    return m_initialized;
}

void RaiseLockscreen::setInitialized(bool initialized)
{
    m_initialized = initialized;
    Q_EMIT initializedChanged();
}

void RaiseLockscreen::initializeOverlay(QQuickWindow *window)
{
    if (!window) {
        return;
    }

    m_window = window;

    WaylandAboveLockscreen aboveLockscreen;
    if (!aboveLockscreen.isInitialized()) {
        setInitialized(false);
    }

    if (!aboveLockscreen.allowWindow(m_window)) {
        setInitialized(false);
    }

    setInitialized(true);
}

void RaiseLockscreen::raiseOverlay()
{
    if (m_window && m_initialized) {
        KWaylandExtras::requestXdgActivationToken(m_window, 0, QStringLiteral("org.kde.plasmashell.desktop"));

        QObject::connect(KWaylandExtras::self(), &KWaylandExtras::xdgActivationTokenArrived, m_window, [this](int, const QString &token) {
            KWindowSystem::setCurrentXdgActivationToken(token);
            KWindowSystem::activateWindow(m_window);
        });
    }
}