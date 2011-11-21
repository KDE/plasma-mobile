/*
    Copyright 2011 Aaron Seigo <aseigo@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#include "runnermodel.h"

#include <KDebug>

#include <Plasma/RunnerManager>

RunnerModel::RunnerModel(QObject *parent)
    : QAbstractItemModel(parent),
      m_manager(0)
{
}

QModelIndex RunnerModel::index(int row, int column, const QModelIndex &index) const
{
    kDebug() << "request for" << row << column << index;
    if (!index.isValid() && row < m_matches.count() && column < 1) {
        return createIndex(row, column);
    }

    return QModelIndex();
}

QModelIndex RunnerModel::parent(const QModelIndex&) const
{
    return QModelIndex();
}

int RunnerModel::rowCount(const QModelIndex& index) const
{
    return index.isValid() ? 0 : m_matches.count();
}

int RunnerModel::columnCount(const QModelIndex&) const
{
    return 1;
}

QVariant RunnerModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.parent().isValid()) {
        // index requested must be valid, but we have no child items!
        kDebug() << "invalid index requested";
        return QVariant();
    }

    if (role == Qt::DisplayRole) {
        if (index.row() < m_matches.count()) {
            return m_matches.at(index.row()).text();
        }
    }

    return QVariant();
}

QString RunnerModel::currentQuery() const
{
    return m_manager ? m_manager->query() : QString();
}

void RunnerModel::startQuery(const QString &query)
{
    if (!m_manager) {
        m_manager = new Plasma::RunnerManager(this);
        connect(m_manager, SIGNAL(matchesChanged(QList<Plasma::QueryMatch>)),
                this, SLOT(matchesChanged(QList<Plasma::QueryMatch>)));
        //connect(m_manager, SIGNAL(queryFinished()), this, SLOT(queryFinished()));
    }

    if (query != m_manager->query()) {
        kDebug() << "running query" << query;
        m_manager->launchQuery(query);
        emit queryChanged();
    }
}

void RunnerModel::matchesChanged(const QList<Plasma::QueryMatch> &matches)
{
    kDebug() << "got matches:" << matches.count();
    beginResetModel();
    m_matches = matches;
    endResetModel();
}

#include "runnermodel.moc"

