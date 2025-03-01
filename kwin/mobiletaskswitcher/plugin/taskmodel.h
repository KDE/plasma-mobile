// SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <window.h>

#include <QAbstractListModel>
#include <QHash>
#include <QSortFilterProxyModel>
#include <QVariant>

namespace KWin
{

class TaskModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        WindowRole = Qt::UserRole + 1,
        OutputRole,
        DesktopRole,
        ActivityRole,
        LastActivatedRole
    };

    explicit TaskModel(QObject *parent = nullptr);

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

private:
    void markRoleChanged(Window *window, int role);

    void handleWindowAdded(Window *window);
    void handleWindowRemoved(Window *window);
    void setupWindowConnections(Window *window);

    void handleActiveWindowChanged();

    // qint64 - Last activated timestamp
    QList<std::pair<Window *, qint64>> m_windows;
};

}; // namespace KWin