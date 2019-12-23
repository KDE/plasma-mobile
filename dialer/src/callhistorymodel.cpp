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
#include "callhistorymodel.h"

#include <QDateTime>
#include <QStandardPaths>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

CallHistoryModel::CallHistoryModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_db(QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), QStringLiteral("calldb")))
{
    m_db.setDatabaseName(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "plasmaphonedialerdb.sqlite");
    bool open = m_db.open();

    if (!open) {
        qWarning() << "Could not open call database" << m_db.lastError();
    }

    QSqlQuery createTable(m_db);
    createTable.exec(QStringLiteral("CREATE TABLE IF NOT EXISTS History(id INTEGER PRIMARY KEY AUTOINCREMENT, number TEXT, time DATETIME, duration INTEGER, callType INTEGER)"));

    QSqlQuery fetchCalls(m_db);
    fetchCalls.exec(QStringLiteral("SELECT id, number, time, duration, callType FROM History"));

    beginResetModel();
    while (fetchCalls.next()) {
        CallData call;
        call.id = fetchCalls.value(0).toString();
        call.number = fetchCalls.value(1).toString();
        call.time = QDateTime::fromMSecsSinceEpoch(fetchCalls.value(2).toInt());
        call.duration = fetchCalls.value(3).toInt();
        call.callType = fetchCalls.value(4).toInt();

        m_calls.append(call);
    }
    endResetModel();
}

void CallHistoryModel::addCall(QString number, int duration, int type)
{
    beginInsertRows(QModelIndex(), m_calls.size(), m_calls.size());
    QSqlQuery putCall(m_db);
    putCall.prepare(QStringLiteral("INSERT INTO History (number, time, duration, callType) VALUES (:number, :time, :duration, :callType)"));
    putCall.bindValue(":number", number);
    putCall.bindValue(":time", QDateTime::currentDateTime().toMSecsSinceEpoch());
    putCall.bindValue(":duration", duration);
    putCall.bindValue(":callType", type);
    putCall.exec();

    CallData data;
    data.id = putCall.lastInsertId().toString();
    data.number = number;
    data.duration = duration;
    data.time = QDateTime::currentDateTime();
    data.callType = type;

    m_calls.append(data);

    endInsertRows();
}

void CallHistoryModel::clear()
{
    beginResetModel();

    QSqlQuery clearCalls(m_db);
    clearCalls.exec(QStringLiteral("DELETE FROM History"));
    m_calls.clear();

    endResetModel();
}

QVariant CallHistoryModel::data(const QModelIndex& index, int role) const
{
    int row = index.row();

    switch (role) {
        case Roles::PhoneNumberRole:
            return m_calls[row].number;
        case Roles::CallTypeRole:
            return m_calls[row].callType;
        case Roles::DurationRole:
            return m_calls[row].duration;
        case Roles::TimeRole:
            return m_calls[row].time;
        case Roles::IdRole:
            return m_calls[row].id;
    }
    return {};
}

int CallHistoryModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_calls.size();
}

QHash<int, QByteArray> CallHistoryModel::roleNames() const
{
    QHash<int, QByteArray> roleNames;
    roleNames[PhoneNumberRole] = "number";
    roleNames[CallTypeRole] = "time";
    roleNames[DurationRole] = "duration";
    roleNames[TimeRole] = "callType";
    roleNames[IdRole] = "dbid";

    return roleNames;
}

bool CallHistoryModel::removeRows(int row, int count, const QModelIndex &parent)
{
    Q_UNUSED(count)

    beginRemoveRows(parent, row, row);
    QSqlQuery remove(m_db);
    remove.prepare(QStringLiteral("DELETE FROM History WHERE id=:id"));
    remove.bindValue(":id", m_calls[row].id);
    remove.exec();

    endRemoveRows();
    return true;
}

void CallHistorySortFilterModel::remove(int index)
{
    QSortFilterProxyModel::removeRow(index);
}

void CallHistorySortFilterModel::sort(int column, Qt::SortOrder order)
{
    QSortFilterProxyModel::sort(column, order);
}
