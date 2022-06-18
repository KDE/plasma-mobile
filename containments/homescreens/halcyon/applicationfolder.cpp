// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "applicationfolder.h"

#include <QJsonArray>

ApplicationFolder::ApplicationFolder(QObject *parent)
{
}

ApplicationFolder *ApplicationFolder::fromJson(QJsonObject &obj, QObject *parent)
{
    QString name = obj[QStringLiteral("name")].toString();
    QList<Application *> apps;
    for (auto storageId : obj[QStringLiteral("apps")].toArray()) {
        if (KService::Ptr service = KService::serviceByStorageId(storageId.toString())) {
            apps.append(new Application(parent, service));
        }
    }

    ApplicationFolder *folder = new ApplicationFolder(parent);
    folder->setName(name);
    folder->setApplications(apps);
    return folder;
}

QJsonObject ApplicationFolder::toJson()
{
    QJsonObject obj;
    obj[QStringLiteral("type")] = "folder";
    obj[QStringLiteral("name")] = m_name;

    QJsonArray arr;
    for (auto *application : m_applications) {
        arr.append(QJsonValue::fromVariant(application->storageId()));
    }

    obj[QStringLiteral("apps")] = arr;

    return obj;
}

QString ApplicationFolder::name() const
{
    return m_name;
}

void ApplicationFolder::setName(QString &name)
{
    m_name = name;
    Q_EMIT nameChanged();
}

QList<Application *> ApplicationFolder::applications()
{
    return m_applications;
}

void ApplicationFolder::setApplications(QList<Application *> applications)
{
    m_applications = applications;
    Q_EMIT applicationsChanged();
}
