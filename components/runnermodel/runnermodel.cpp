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

#include <QIcon>

#include <KDebug>

#include <Plasma/RunnerManager>

RunnerModel::RunnerModel(QObject *parent)
    : QAbstractItemModel(parent),
      m_manager(0)
{
    QHash<int, QByteArray> roles;
    roles.insert(Qt::DisplayRole, "label");
    roles.insert(Qt::DecorationRole, "icon");
    roles.insert(Type, "type");
    roles.insert(Relevance, "relevance");
    roles.insert(Data, "data");
    roles.insert(Id, "id");
    roles.insert(SubText, "description");
    roles.insert(Enabled, "enabled");
    setRoleNames(roles);
}

QModelIndex RunnerModel::index(int row, int column, const QModelIndex &index) const
{
    //kDebug() << "request for" << row << column << !index.isValid();
    if (!index.isValid() && row >= 0 && row < m_matches.count() && column >= 0 && column < 1) {
        return createIndex(row, column);
    }

    //kDebug() << "IIIIIIIIIIIIIINVALID!";
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

int RunnerModel::count() const
{
    return m_matches.count();
}

int RunnerModel::columnCount(const QModelIndex&) const
{
    return 1;
}

QStringList RunnerModel::runners() const
{
    return m_manager ? m_manager->allowedRunners() : QStringList();
}

void RunnerModel::setRunners(const QStringList &allowedRunners)
{
    createManager();
    m_manager->setAllowedRunners(allowedRunners);
}

QVariant RunnerModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.parent().isValid() ||
        index.column() > 0 || index.row() < 0 || index.row() >= m_matches.count()) {
        // index requested must be valid, but we have no child items!
        //kDebug() << "invalid index requested";
        return QVariant();
    }

    if (role == Qt::DisplayRole) {
        return m_matches.at(index.row()).text();
    } else if (role == Qt::DecorationRole) {
        return m_matches.at(index.row()).icon();
    } else if (role == Type) {
        return m_matches.at(index.row()).type();
    } else if (role == Relevance) {
        return m_matches.at(index.row()).relevance();
    } else if (role == Data) {
        return m_matches.at(index.row()).data();
    } else if (role == Id) {
        return m_matches.at(index.row()).id();
    } else if (role == SubText) {
        return m_matches.at(index.row()).subtext();
    } else if (role == Enabled) {
        return m_matches.at(index.row()).isEnabled();
    }

    return QVariant();
}

QString RunnerModel::currentQuery() const
{
    return m_manager ? m_manager->query() : QString();
}

void RunnerModel::startQuery(const QString &query)
{
    //kDebug() << "booooooo yah!!!!!!!!!!!!!" << query;
    createManager();

    if (query != m_manager->query()) {
        //kDebug() << "running query" << query;
        m_manager->launchQuery(query);
        emit queryChanged();
    }
}

void RunnerModel::createManager()
{
    if (!m_manager) {
        m_manager = new Plasma::RunnerManager(this);
        connect(m_manager, SIGNAL(matchesChanged(QList<Plasma::QueryMatch>)),
                this, SLOT(matchesChanged(QList<Plasma::QueryMatch>)));
        //connect(m_manager, SIGNAL(queryFinished()), this, SLOT(queryFinished()));
    }
}

void RunnerModel::matchesChanged(const QList<Plasma::QueryMatch> &matches)
{
    //kDebug() << "got matches:" << matches.count();
    beginResetModel();
    m_matches = matches;
    endResetModel();
    emit countChanged();
}

#include "runnermodel.moc"

