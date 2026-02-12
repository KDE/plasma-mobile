// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "application.h"

#include <QAbstractListModel>
#include <QObject>
#include <QString>

#include <KService>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

#include <qqmlregistration.h>

/**
 * @short Object that represents an application folder on the main page.
 */

class ApplicationFolderModel;
class ApplicationFolder : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Managed by ApplicationListModel")
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QList<Application *> appPreviews READ appPreviews NOTIFY applicationsChanged)
    Q_PROPERTY(ApplicationFolderModel *applications READ applications NOTIFY applicationsReset)

public:
    ApplicationFolder(QObject *parent = nullptr, QString name = QString{});

    static ApplicationFolder *fromJson(QJsonObject &obj, QObject *parent);
    QJsonObject toJson();

    QString name() const;
    void setName(QString &name);

    QList<Application *> appPreviews();

    ApplicationFolderModel *applications();
    void setApplications(QList<Application *> applications);

    Q_INVOKABLE void moveEntry(int fromRow, int toRow);
    Q_INVOKABLE void addApp(const QString &storageId, int row);
    Q_INVOKABLE void removeApp(int row);
    Q_INVOKABLE void moveAppOut(int row); // moves app to main page

Q_SIGNALS:
    void nameChanged();
    void saveRequested();
    void moveAppOutRequested(const QString &storageId);
    void applicationsChanged();
    void applicationsReset();

private:
    QString m_name;
    QList<Application *> m_applications;
    ApplicationFolderModel *m_applicationFolderModel;

    friend class ApplicationFolderModel;
};

class ApplicationFolderModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        ApplicationRole = Qt::UserRole + 1
    };
    ApplicationFolderModel(ApplicationFolder *folder);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void moveEntry(int fromRow, int toRow);
    void addApp(const QString &storageId, int row);
    void removeApp(int row);

private:
    ApplicationFolder *m_folder;

    friend class ApplicationFolder;
};
