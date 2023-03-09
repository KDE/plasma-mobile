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
    // get lockscreen state
    QDBusMessage request = QDBusMessage::createMethodCall(QStringLiteral("org.freedesktop.ScreenSaver"),
                                                          QStringLiteral("/ScreenSaver"),
                                                          QStringLiteral("org.freedesktop.ScreenSaver"),
                                                          QStringLiteral("GetActive"));
    const QDBusReply<bool> response = QDBusConnection::sessionBus().call(request);

    m_lockscreenShown = response.isValid() ? response.value() : false;

    qDebug() << "initial lockscreen state:" << m_lockscreenShown;

    // listen to future state changes
    QDBusConnection::sessionBus().connect(QStringLiteral("org.freedesktop.ScreenSaver"),
                                          QStringLiteral("/ScreenSaver"),
                                          QStringLiteral("org.freedesktop.ScreenSaver"),
                                          QStringLiteral("ActiveChanged"),
                                          this,
                                          SLOT(slotLockscreenStateChanged));
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

bool PhonePanel::lockscreenShown()
{
    return m_lockscreenShown;
}

void PhonePanel::slotLockscreenStateChanged(bool active)
{
    m_lockscreenShown = active;
    Q_EMIT lockscreenShownChanged();

    qDebug() << "lockscreen state changed:" << m_lockscreenShown;

    if (active && m_window) {
        KWindowSystem::requestXdgActivationToken(m_window, 0, QStringLiteral("org.kde.plasmashell.desktop"));

        QObject::connect(KWindowSystem::self(), &KWindowSystem::xdgActivationTokenArrived, m_window, [this](int, const QString &token) {
            KWindowSystem::setCurrentXdgActivationToken(token);
            KWindowSystem::activateWindow(m_window);
        });
    }
}

K_PLUGIN_CLASS_WITH_JSON(PhonePanel, "package/metadata.json")

#include "phonepanel.moc"
