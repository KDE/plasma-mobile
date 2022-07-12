// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "application.h"

#include <QObject>
#include <QString>

#include <KService>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

/**
 * @short Object that represents an application folder on the main page.
 */
class ApplicationFolder : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QList<Application *> appPreviews READ appPreviews NOTIFY applicationsChanged)
    Q_PROPERTY(QList<Application *> applications READ applications NOTIFY applicationsChanged)

public:
    ApplicationFolder(QObject *parent = nullptr, QString name = QString{});

    static ApplicationFolder *fromJson(QJsonObject &obj, QObject *parent);
    QJsonObject toJson();

    QString name() const;
    void setName(QString &name);

    QList<Application *> appPreviews();

    QList<Application *> applications();
    void setApplications(QList<Application *> applications);

    Q_INVOKABLE void moveEntry(int fromRow, int toRow);
    Q_INVOKABLE void addApp(const QString &storageId, int row);
    Q_INVOKABLE void removeApp(int row);
    Q_INVOKABLE void moveAppOut(int row); // moves app to main page

Q_SIGNALS:
    void nameChanged();
    void applicationsChanged();
    void saveRequested();
    void moveAppOutRequested(const QString &storageId);

private:
    QString m_name;
    QList<Application *> m_applications;
};
