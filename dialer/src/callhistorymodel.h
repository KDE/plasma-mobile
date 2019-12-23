/*
    Copyright (C) 2019 Nicolas Fella <nicolas.fella@gmx.de>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#pragma once

#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QSqlDatabase>
#include <QDateTime>
#include <QVector>

struct CallData {
    QString id;
    QString number;
    QDateTime time;
    int duration;
    int callType;
};

class CallHistoryModel : public QAbstractListModel
{
    Q_OBJECT
public:

    CallHistoryModel(QObject *parent = nullptr);

    enum Roles {
        PhoneNumberRole = Qt::UserRole + 1,
        DurationRole,
        TimeRole,
        CallTypeRole,
        IdRole
    };
    Q_ENUM(Roles)

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addCall(QString number, int duration, int type);
    Q_INVOKABLE void clear();

    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;

private:
    QSqlDatabase m_db;
    QVector<CallData> m_calls;
};

class CallHistorySortFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    Q_INVOKABLE void remove(int index);
    Q_INVOKABLE void sort(int column, Qt::SortOrder order = Qt::AscendingOrder) override;
};
