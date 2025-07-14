/*
 *   SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include "waydroidapplication.h"
#include "waydroidstate.h"

#include <QAbstractListModel>
#include <QObject>
#include <QTimer>

class WaydroidState;

class WaydroidApplicationListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        DelegateRole = Qt::UserRole + 1,
        NameRole,
        IdRole
    };

    WaydroidApplicationListModel(WaydroidState *parent = nullptr);
    ~WaydroidApplicationListModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void installApk(const QString apkFile);
    Q_INVOKABLE void deleteApplication(const QString appId);

Q_SIGNALS:
    void actionFinished(const QString message);
    void errorOccurred(const QString message);

private:
    WaydroidState *m_waydroidState{nullptr};
    QList<WaydroidApplication::Ptr> m_applications;
    QTimer *m_refreshTimer{nullptr};

    void refreshApplications();
    QList<WaydroidApplication::Ptr> queryApplications() const;
};