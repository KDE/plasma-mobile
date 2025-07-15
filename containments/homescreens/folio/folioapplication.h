// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QJsonObject>
#include <QObject>
#include <QQuickItem>
#include <QString>

#include <KIO/ApplicationLauncherJob>
#include <KService>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

#include "homescreen.h"

class HomeScreen;

/**
 * @short Object that represents an application.
 */
class FolioApplication : public QObject, public std::enable_shared_from_this<FolioApplication>
{
    Q_OBJECT
    Q_PROPERTY(bool running READ running NOTIFY windowChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QString icon READ icon NOTIFY iconChanged)
    Q_PROPERTY(QString storageId READ storageId NOTIFY storageIdChanged)

public:
    typedef std::shared_ptr<FolioApplication> Ptr;

    FolioApplication(KService::Ptr service = QExplicitlySharedDataPointer<KService>{nullptr}, QObject *parent = nullptr);

    static FolioApplication::Ptr fromJson(QJsonObject &obj); // may return nullptr
    QJsonObject toJson() const;

    bool running() const;
    QString name() const;
    QString icon() const;
    QString storageId() const;
    KWayland::Client::PlasmaWindow *window() const;

    void setName(QString &name);
    void setIcon(QString &icon);
    void setStorageId(QString &storageId);
    void setWindow(KWayland::Client::PlasmaWindow *window);

    Q_INVOKABLE void setMinimizedDelegate(QQuickItem *delegate);
    Q_INVOKABLE void unsetMinimizedDelegate(QQuickItem *delegate);

Q_SIGNALS:
    void nameChanged();
    void iconChanged();
    void storageIdChanged();
    void windowChanged();

private:
    bool m_running;
    QString m_name;
    QString m_icon;
    QString m_storageId;
    KWayland::Client::PlasmaWindow *m_window{nullptr};
};
