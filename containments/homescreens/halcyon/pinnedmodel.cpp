// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "pinnedmodel.h"

#include <QJsonArray>
#include <QJsonDocument>

PinnedModel::PinnedModel(QObject *parent, Plasma::Applet *applet)
    : QAbstractListModel{parent}
    , m_applet{applet}
{
}

PinnedModel::~PinnedModel() = default;

int PinnedModel::rowCount(const QModelIndex &parent) const
{
    return m_applications.count();
}

QVariant PinnedModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
    case IsFolderRole:
        return m_folders.at(index.row()) != nullptr;
    case ApplicationRole:
        return QVariant::fromValue(m_applications.at(index.row()));
    case FolderRole:
        return QVariant::fromValue(m_folders.at(index.row()));
    }

    return QVariant();
}

QHash<int, QByteArray> PinnedModel::roleNames() const
{
    return {{IsFolderRole, "isFolder"}, {ApplicationRole, "application"}, {FolderRole, "folder"}};
}

void PinnedModel::addApp(const QString &storageId, int row)
{
    if (row < 0 || row > m_applications.size()) {
        return;
    }

    if (KService::Ptr service = KService::serviceByStorageId(storageId)) {
        Application *app = new Application(this, service);

        beginInsertRows(QModelIndex(), row, row);
        m_applications.insert(row, app);
        m_folders.insert(row, nullptr); // maintain indicies
        endInsertRows();

        save();
    }
}

void PinnedModel::removeApp(int row)
{
    if (row < 0 || row >= m_applications.size()) {
        return;
    }

    beginRemoveRows(QModelIndex(), row, row);
    m_applications[row]->deleteLater();
    m_applications.removeAt(row);
    m_folders.removeAt(row); // maintain indicies
    endRemoveRows();

    save();
}

void PinnedModel::addFolder(QString name, int row)
{
    if (row < 0 || row > m_applications.size()) {
        return;
    }

    ApplicationFolder *folder = new ApplicationFolder(this, name);
    connect(folder, &ApplicationFolder::saveRequested, this, &PinnedModel::save);

    beginInsertRows(QModelIndex(), row, row);
    m_applications.insert(row, nullptr);
    m_folders.insert(row, folder);
    endInsertRows();

    save();
}

void PinnedModel::removeFolder(int row)
{
    if (row < 0 || row >= m_applications.size()) {
        return;
    }

    beginRemoveRows(QModelIndex(), row, row);
    m_applications.removeAt(row);
    m_folders.removeAt(row);
    endRemoveRows();

    save();
}

void PinnedModel::load()
{
    if (!m_applet) {
        return;
    }

    QJsonDocument doc = QJsonDocument::fromJson(m_applet->config().readEntry("Pinned", "{}").toUtf8());

    beginResetModel();

    for (QJsonValueRef r : doc.array()) {
        QJsonObject obj = r.toObject();

        if (obj[QStringLiteral("type")].toString() == "application") {
            // read application
            Application *app = Application::fromJson(obj, this);
            if (app) {
                m_applications.append(app);
                m_folders.append(nullptr);
            }

        } else if (obj[QStringLiteral("type")].toString() == "folder") {
            // read folder
            ApplicationFolder *folder = ApplicationFolder::fromJson(obj, this);
            connect(folder, &ApplicationFolder::saveRequested, this, &PinnedModel::save);

            if (folder) {
                m_applications.append(nullptr);
                m_folders.append(folder);
            }
        }
    }

    endResetModel();
}

void PinnedModel::save()
{
    if (!m_applet) {
        return;
    }

    QJsonArray arr;
    for (int i = 0; i < m_applications.size() && i < m_folders.size(); i++) {
        if (m_applications[i]) {
            arr.push_back(m_applications[i]->toJson());
        } else if (m_folders[i]) {
            arr.push_back(m_folders[i]->toJson());
        }
    }
    QByteArray data = QJsonDocument(arr).toJson(QJsonDocument::Compact);

    m_applet->config().writeEntry("Pinned", QString::fromStdString(data.toStdString()));
    Q_EMIT m_applet->configNeedsSaving();
}
