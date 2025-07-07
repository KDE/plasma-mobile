// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "application.h"
#include "windowlistener.h"

#include <QQuickWindow>

#include <KNotificationJobUiDelegate>

Application::Application(QObject *parent, KService::Ptr service)
    : QObject{parent}
    , m_running{false}
    , m_name{service->name()}
    , m_icon{service->icon()}
    , m_storageId{service->storageId()}
{
    if (!service->property<QString>(QStringLiteral("X-KDE-PlasmaMobileName")).isEmpty()) {
        m_name = service->property<QString>(QStringLiteral("X-KDE-PlasmaMobileName"));
    }

    auto windows = WindowListener::instance()->windowsFromStorageId(m_storageId);
    if (windows.empty()) {
        m_window = nullptr;
    } else {
        m_window = windows[0];
    }

    connect(WindowListener::instance(), &WindowListener::windowChanged, this, [this](QString storageId) {
        if (storageId == m_storageId) {
            auto windows = WindowListener::instance()->windowsFromStorageId(m_storageId);
            if (windows.empty()) {
                setWindow(nullptr);
            } else {
                setWindow(windows[0]);
            }
        }
    });
}

Application *Application::fromJson(QJsonObject &obj, QObject *parent)
{
    QString storageId = obj[QStringLiteral("storageId")].toString();
    if (KService::Ptr service = KService::serviceByStorageId(storageId)) {
        return new Application(parent, service);
    }
    return nullptr;
}

QJsonObject Application::toJson()
{
    QJsonObject obj;
    obj[QStringLiteral("type")] = "application";
    obj[QStringLiteral("storageId")] = m_storageId;
    return obj;
}

bool Application::running() const
{
    return m_window != nullptr;
}

QString Application::name() const
{
    return m_name;
}

QString Application::icon() const
{
    return m_icon;
}

QString Application::storageId() const
{
    return m_storageId;
}

KWayland::Client::PlasmaWindow *Application::window() const
{
    return m_window;
}

void Application::setName(QString &name)
{
    m_name = name;
    Q_EMIT nameChanged();
}

void Application::setIcon(QString &icon)
{
    m_icon = icon;
    Q_EMIT iconChanged();
}

void Application::setStorageId(QString &storageId)
{
    m_storageId = storageId;
    Q_EMIT storageIdChanged();
}

void Application::setWindow(KWayland::Client::PlasmaWindow *window)
{
    m_window = window;
    Q_EMIT windowChanged();
}

void Application::setMinimizedDelegate(QQuickItem *delegate)
{
    QWindow *delegateWindow = delegate->window();
    if (!delegateWindow) {
        return;
    }
    if (!m_window) {
        return;
    }

    KWayland::Client::Surface *surface = KWayland::Client::Surface::fromWindow(delegateWindow);
    if (!surface) {
        return;
    }

    QRect rect = delegate->mapRectToScene(QRectF(0, 0, delegate->width(), delegate->height())).toRect();
    m_window->setMinimizedGeometry(surface, rect);
}

void Application::unsetMinimizedDelegate(QQuickItem *delegate)
{
    QWindow *delegateWindow = delegate->window();
    if (!delegateWindow) {
        return;
    }
    if (!m_window) {
        return;
    }

    KWayland::Client::Surface *surface = KWayland::Client::Surface::fromWindow(delegateWindow);
    if (!surface) {
        return;
    }

    m_window->unsetMinimizedGeometry(surface);
}
