// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "raiselockscreen.h"
#include "utils.h"

#include <QQuickItem>
#include <QWaylandClientExtensionTemplate>
#include <qpa/qplatformwindow_p.h>

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
};

RaiseLockscreen::RaiseLockscreen(QObject *parent)
    : QObject{parent}
    , m_implementation(std::make_unique<WaylandAboveLockscreen>())
{
    QObject::connect(KWaylandExtras::self(), &KWaylandExtras::xdgActivationTokenArrived, this, [this](int, const QString &token) {
        qCDebug(LOGGING_CATEGORY) << "XDG activation token arrived, activating window...";
        // Activate window over lockscreen once we have activation token
        KWindowSystem::setCurrentXdgActivationToken(token);
        KWindowSystem::activateWindow(m_window);
    });
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
    if (!window || window == m_window) {
        return;
    }

    setWindow(window);
    setOverlay();

    // also re-set the overlay when the compositor gets restarted
    connect(m_implementation.get(), &WaylandAboveLockscreen::activeChanged, this, &RaiseLockscreen::setOverlay);
}

void RaiseLockscreen::setOverlay()
{
    if (!m_implementation->isActive()) {
        setInitialized(false);
        qCWarning(LOGGING_CATEGORY) << "Unable to set overlay: wayland protocol is not active";
        return;
    }
    auto waylandWindow = m_window->nativeInterface<QNativeInterface::Private::QWaylandWindow>();
    if (!waylandWindow) {
        m_window->installEventFilter(this);
        setInitialized(false);
        qCWarning(LOGGING_CATEGORY) << "Unable to set overlay: unable to get wayland window";
        return;
    }
    if (!waylandWindow->surface()) {
        connect(waylandWindow, &QNativeInterface::Private::QWaylandWindow::surfaceCreated, this, &RaiseLockscreen::setOverlay, Qt::SingleShotConnection);
        setInitialized(false);
        qCWarning(LOGGING_CATEGORY) << "Unable to set overlay: unable to get wayland window surface";
        return;
    }

    // We need to allow the overlay only when there's a shell surface, otherwise it gets ignored
    if (!m_window->isExposed()) {
        setInitialized(false);
        connect(
            waylandWindow,
            &QNativeInterface::Private::QWaylandWindow::surfaceRoleCreated,
            this,
            [this, waylandWindow]() {
                m_implementation->allow(waylandWindow->surface());
                setInitialized(true);
            },
            Qt::SingleShotConnection);

        qCWarning(LOGGING_CATEGORY) << "Unable to set overlay: no shell surface";
    }

    m_implementation->allow(waylandWindow->surface());
    setInitialized(true);
    qCDebug(LOGGING_CATEGORY) << "Initialized overlay successfully";
}

bool RaiseLockscreen::eventFilter(QObject *watched, QEvent *event)
{
    auto window = qobject_cast<QQuickWindow *>(watched);
    if (window && event->type() == QEvent::PlatformSurface) {
        auto surfaceEvent = static_cast<QPlatformSurfaceEvent *>(event);
        if (surfaceEvent->surfaceEventType() == QPlatformSurfaceEvent::SurfaceCreated) {
            m_window->removeEventFilter(this);
            setOverlay();
        }
    }
    return false;
}

void RaiseLockscreen::raiseOverlay()
{
    if (!m_window) {
        qCWarning(LOGGING_CATEGORY) << "Unable to raise overlay: no window set";
        return;
    }

    if (!m_initialized) {
        qCWarning(LOGGING_CATEGORY) << "Unable to raise overlay: window is not initialized for lockscreen overlaying, trying anyway...";
    }

    qCDebug(LOGGING_CATEGORY) << "Attempting to raise overlay: " << m_window << m_initialized;
    KWaylandExtras::requestXdgActivationToken(m_window, 0, QStringLiteral("org.kde.plasmashell.desktop"));
}
