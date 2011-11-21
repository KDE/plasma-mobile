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

#include <Plasma/RunnerManager>

RunnerModel::RunnerModel(QObject *parent)
    : QAbstractItemModel(parent),
      m_manager(0)
{
}

QModelIndex RunnerModel::index(int, int, const QModelIndex&) const
{
    return QModelIndex();
}

QModelIndex RunnerModel::parent(const QModelIndex&) const
{
    return QModelIndex();
}

int RunnerModel::rowCount(const QModelIndex&) const
{
    return 0;
}

int RunnerModel::columnCount(const QModelIndex&) const
{
    return 0;
}

QVariant RunnerModel::data(const QModelIndex&, int) const
{
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
    }

    if (query != m_manager->query()) {
        m_manager->launchQuery(query);
        emit queryChanged();
    }
}

#include "runnermodel.moc"

