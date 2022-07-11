// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "applicationfolder.h"

#include <QJsonArray>

ApplicationFolder::ApplicationFolder(QObject *parent, QString name)
    : QObject{parent}
    , m_name{name}
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

    ApplicationFolder *folder = new ApplicationFolder(parent, name);
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
    Q_EMIT saveRequested();
}

QList<Application *> ApplicationFolder::appPreviews()
{
    QList<Application *> previews;
    // we give a maximum of 4 icons
    for (int i = 0; i < std::min(m_applications.length(), 4); ++i) {
        previews.push_back(m_applications[i]);
    }
    return previews;
}

QList<Application *> ApplicationFolder::applications()
{
    return m_applications;
}

void ApplicationFolder::setApplications(QList<Application *> applications)
{
    m_applications = applications;
    Q_EMIT applicationsChanged();
    Q_EMIT saveRequested();
}

void ApplicationFolder::moveEntry(int fromRow, int toRow)
{
    if (fromRow < 0 || toRow < 0 || fromRow >= m_applications.length() || toRow >= m_applications.length() || fromRow == toRow) {
        return;
    }
    if (toRow > fromRow) {
        ++toRow;
    }

    if (toRow > fromRow) {
        Application *app = m_applications.at(fromRow);
        m_applications.insert(toRow, app);
        m_applications.takeAt(fromRow);

    } else {
        Application *app = m_applications.takeAt(fromRow);
        m_applications.insert(toRow, app);
    }
    Q_EMIT applicationsChanged();
    Q_EMIT saveRequested();
}

void ApplicationFolder::addApp(const QString &storageId, int row)
{
    if (row < 0 || row > m_applications.size()) {
        return;
    }

    if (KService::Ptr service = KService::serviceByStorageId(storageId)) {
        Application *app = new Application(this, service);
        m_applications.insert(row, app);
        Q_EMIT applicationsChanged();
        Q_EMIT saveRequested();
    }
}

void ApplicationFolder::removeApp(int row)
{
    if (row < 0 || row >= m_applications.size()) {
        return;
    }

    m_applications[row]->deleteLater();
    m_applications.removeAt(row);
    Q_EMIT applicationsChanged();
    Q_EMIT saveRequested();
}

void ApplicationFolder::moveAppOut(int row)
{
    if (row < 0 || row >= m_applications.size()) {
        return;
    }

    Q_EMIT moveAppOutRequested(m_applications[row]->storageId());
    removeApp(row);
}
