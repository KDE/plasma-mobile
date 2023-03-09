// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2018 Bhushan Shah <bshah@kde.org>
// SPDX-FileCopyrightText: 2022 Aleix Pol Gonzalez <aleixpol@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#include "phonepanel.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusReply>
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
        QMetaObject::invokeMethod(this, "addRegistryListener");
    }

    void allowWindow(QWindow *window)
    {
        QPlatformNativeInterface *native = qGuiApp->platformNativeInterface();
        wl_surface *surface = reinterpret_cast<wl_surface *>(native->nativeResourceForWindow(QByteArrayLiteral("surface"), window));

        Q_ASSERT(surface);
        allow(surface);
    }
};

PhonePanel::PhonePanel(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment(parent, data, args)
{
}

PhonePanel::~PhonePanel() = default;

void PhonePanel::initializeOverlay(QQuickWindow *window)
{
    if (!window) {
        return;
    }

    m_window = window;

    WaylandAboveLockscreen aboveLockscreen;
    Q_ASSERT(aboveLockscreen.isInitialized());
    aboveLockscreen.allowWindow(m_window);
}

void PhonePanel::raiseOverlay()
{
    if (m_window) {
        KWaylandExtras::requestXdgActivationToken(m_window, 0, QStringLiteral("org.kde.plasmashell.desktop"));

        QObject::connect(KWaylandExtras::self(), &KWaylandExtras::xdgActivationTokenArrived, m_window, [this](int, const QString &token) {
            KWindowSystem::setCurrentXdgActivationToken(token);
            KWindowSystem::activateWindow(m_window);
        });
    }
}

K_PLUGIN_CLASS(PhonePanel)

#include "phonepanel.moc"
