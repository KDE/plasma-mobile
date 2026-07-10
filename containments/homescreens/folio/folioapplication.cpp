// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "folioapplication.h"
#include "windowlistener.h"

#include <QQuickWindow>
#include <QFileInfo>
#include <QUrl>
#include <QIcon>

static bool isIconValid(const QString &iconNameOrPath)
{
    if (iconNameOrPath.isEmpty()) {
        return false;
    }

    if (iconNameOrPath.startsWith(QStringLiteral("file://"))) {
        return QFileInfo::exists(QUrl(iconNameOrPath).toLocalFile());
    } else if (iconNameOrPath.startsWith(QLatin1Char('/'))) {
        return QFileInfo::exists(iconNameOrPath);
    }

    return QIcon::hasThemeIcon(iconNameOrPath);
}

FolioApplication::FolioApplication(KService::Ptr service, const QStringList &categories, QObject *parent)
: QObject{parent}
, m_running{false}
, m_name{service ? service->name() : QString()}
, m_icon{service && isIconValid(service->icon()) ? service->icon() : QStringLiteral("unknown")}
, m_storageId{service ? service->storageId() : QString()}
, m_categories{categories}
, m_service{service}
{
    if (service && service->property<bool>(QStringLiteral("X-KDE-PlasmaMobile-UseGenericName"))) {
        m_name = service->genericName();
    }

    auto windows = WindowListener::instance()->windowsFromStorageId(m_storageId);
    m_window = windows.empty() ? nullptr : windows[0];

    connect(WindowListener::instance(), &WindowListener::windowChanged, this, [this](QString storageId) {
        if (storageId == m_storageId) {
            auto windows = WindowListener::instance()->windowsFromStorageId(m_storageId);
            setWindow(windows.empty() ? nullptr : windows[0]);
        }
    });
}

FolioApplication::Ptr FolioApplication::fromJson(QJsonObject &obj)
{
    QString storageId = obj[QStringLiteral("storageId")].toString();
    if (KService::Ptr service = KService::serviceByStorageId(storageId)) {
        return std::make_shared<FolioApplication>(service);
    }
    return nullptr;
}

QJsonObject FolioApplication::toJson() const
{
    QJsonObject obj;
    obj[QStringLiteral("type")] = "application";
    obj[QStringLiteral("storageId")] = m_storageId;
    return obj;
}

bool FolioApplication::running() const
{
    return m_window != nullptr;
}

QString FolioApplication::name() const
{
    return m_name;
}

QString FolioApplication::icon() const
{
    return m_icon;
}

QStringList FolioApplication::categories() const
{
    return m_categories;
}

QString FolioApplication::storageId() const
{
    return m_storageId;
}

KWayland::Client::PlasmaWindow *FolioApplication::window() const
{
    return m_window;
}

KService::Ptr FolioApplication::service() const
{
    return m_service;
}

void FolioApplication::setName(QString &name)
{
    m_name = name;
    Q_EMIT nameChanged();
}

void FolioApplication::setIcon(QString &icon)
{
    m_icon = icon;
    Q_EMIT iconChanged();
}

void FolioApplication::setStorageId(QString &storageId)
{
    m_storageId = storageId;
    Q_EMIT storageIdChanged();
}

void FolioApplication::setWindow(KWayland::Client::PlasmaWindow *window)
{
    m_window = window;
    Q_EMIT windowChanged();
}

void FolioApplication::setCategories(const QStringList &categories)
{
    if (m_categories != categories) {
        m_categories = categories;
        Q_EMIT categoriesChanged();
    }
}

void FolioApplication::setMinimizedDelegate(QQuickItem *delegate)
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

void FolioApplication::unsetMinimizedDelegate(QQuickItem *delegate)
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
