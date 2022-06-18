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

class ApplicationFolder : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QList<Application *> applications READ applications NOTIFY applicationsChanged)

public:
    ApplicationFolder(QObject *parent = nullptr);

    static ApplicationFolder *fromJson(QJsonObject &obj, QObject *parent);
    QJsonObject toJson();

    QString name() const;
    void setName(QString &name);

    QList<Application *> applications();
    void setApplications(QList<Application *> applications);

Q_SIGNALS:
    void nameChanged();
    void applicationsChanged();

private:
    QString m_name;
    QList<Application *> m_applications;
};
