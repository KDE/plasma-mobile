/*
    Copyright 2011 Marco Martin <notmart@gmail.com>

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

#include "metadatamodel.h"

#include <KDebug>

MetadataModel::MetadataModel(QObject *parent)
    : QAbstractItemModel(parent)
{
    
}

MetadataModel::~MetadataModel()
{
}


QVariant MetadataModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.column() > 0 ||
        index.row() < 0 || index.row() >= m_resources.count()){
        return QVariant();
    }

    const Nepomuk::Resource &res = m_resources[index.row()];

    switch (role) {
    case Label:
        return res.label();
    default:
        return QVariant();
    }
}

QVariant MetadataModel::headerData(int section, Qt::Orientation orientation,
                                   int role) const
{
    Q_UNUSED(section)
    Q_UNUSED(orientation)
    Q_UNUSED(role)

    return QVariant();
}

QModelIndex MetadataModel::index(int row, int column,
                                 const QModelIndex &parent) const
{
    if (parent.isValid() || column > 0 || row < 0 || rowCount()) {
        return QModelIndex();
    }

    return createIndex(row, column, 0);
}

QModelIndex MetadataModel::parent(const QModelIndex &child) const
{
    Q_UNUSED(child)

    return QModelIndex();
}

int MetadataModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_resources.count();
}

int MetadataModel::columnCount(const QModelIndex &parent) const
{
    //no trees
    if (parent.isValid()) {
        return 0;
    }

    return 1;
}


#include "metadatamodel.moc"
