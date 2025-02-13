// SPDX-FileCopyrightText: 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "application.h"

#include <QAbstractListModel>
#include <QList>
#include <QObject>
#include <QQuickItem>
#include <QSet>
#include <QTimer>

/**
 * @short The base application list, used directly by the full app list page.
 */
class ApplicationListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles { ApplicationRole = Qt::UserRole + 1 };

    ApplicationListModel(QObject *parent = nullptr);
    ~ApplicationListModel() override;
    static ApplicationListModel *self();

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void loadApplications();

public Q_SLOTS:
    void sycocaDbChanged();

protected:
    QList<Application *> m_applicationList;
    QTimer *m_reloadAppsTimer{nullptr};
};
