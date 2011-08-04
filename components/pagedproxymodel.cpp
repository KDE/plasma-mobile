/*
    Copyright 2010 Marco Martin <notmart@gmail.com>

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

#include "pagedproxymodel.h"

#include <KDebug>

PagedProxyModel::PagedProxyModel(QObject *parent)
    : QAbstractProxyModel(parent),
      m_pageSize(16),
      m_currentPage(0)
{
}

PagedProxyModel::~PagedProxyModel()
{
}

int PagedProxyModel::totalPages()
{
    if (!sourceModel()) {
        return 0;
    }

    return sourceModel()->rowCount() / m_pageSize;
}

void PagedProxyModel::setCurrentPage(const int page)
{
    if (m_currentPage == page) {
        return;
    }

    beginResetModel();
    m_currentPage = page;
    endResetModel();
}

int PagedProxyModel::currentPage() const
{
    return m_currentPage;
}

void PagedProxyModel::setPageSize(const int size)
{
    if (m_pageSize == size) {
        return;
    }

    beginResetModel();
    m_pageSize = size;
    endResetModel();
}

int PagedProxyModel::pageSize() const
{
    return m_pageSize;
}

void PagedProxyModel::setSourceModelObject(QObject *source)
{
    QAbstractItemModel *model = qobject_cast<QAbstractItemModel *>(source);
    if (!model) {
        return;
    }
    if (sourceModel()) {
        disconnect(sourceModel(), 0, this, 0);
    }

    connect(model, SIGNAL(dataChanged(QModelIndex,QModelIndex)),
            this, SLOT(sourceDataChanged(QModelIndex,QModelIndex)));

    connect(model,  SIGNAL(rowsAboutToBeInserted(QModelIndex, int,int)),
            this, SLOT(sourceRowsAboutToBeInserted(QModelIndex,int,int)) );
    connect(model,  SIGNAL(rowsInserted(QModelIndex, int,int)),
            this, SLOT(sourceRowsInserted(QModelIndex,int,int)) );
    connect(model,  SIGNAL(rowsAboutToBeRemoved(QModelIndex, int,int)),
            this, SLOT(sourceRowsAboutToBeRemoved(QModelIndex,int,int)) );
    connect(model,  SIGNAL(rowsRemoved(QModelIndex, int,int)),
            this, SLOT(sourceRowsRemoved(QModelIndex,int,int)) );

    connect(model, SIGNAL(modelAboutToBeReset()),
               this, SIGNAL(modelAboutToBeReset()));
    connect(model, SIGNAL(modelReset()),
               this, SIGNAL(modelReset()));
    setRoleNames(model->roleNames());
    setSourceModel(model);
}

QObject *PagedProxyModel::sourceModelObject() const
{
    return sourceModel();
}


void PagedProxyModel::sourceDataChanged(const QModelIndex &from, const QModelIndex &to)
{
    emit dataChanged(mapFromSource(from), mapFromSource(to));
}

void PagedProxyModel::sourceRowsAboutToBeInserted( const QModelIndex & parentIdx, int start, int end )
{
    beginInsertRows(parentIdx, start, end );
}


void PagedProxyModel::sourceRowsInserted( const QModelIndex& parentIdx, int start, int end )
{
    Q_UNUSED( parentIdx );
    Q_UNUSED( start );
    Q_UNUSED( end );
    endInsertRows();
}


void PagedProxyModel::sourceRowsAboutToBeRemoved( const QModelIndex & parentIdx, int start, int end )
{
    beginRemoveRows(parentIdx, start, end );
}


void PagedProxyModel::sourceRowsRemoved( const QModelIndex& parentIdx, int start, int end )
{
    Q_UNUSED( parentIdx );
    Q_UNUSED( start );
    Q_UNUSED( end );
    endRemoveRows();
}

int PagedProxyModel::rowCount(const QModelIndex &parent) const
{
    if (!sourceModel()) {
        return 0;
    }

    return qMin(m_pageSize, (sourceModel()->rowCount(parent)-m_currentPage*m_pageSize));
}

QVariant PagedProxyModel::data(const QModelIndex &index, int role) const
{
    if (!sourceModel()) {
        return QVariant();
    }

    return sourceModel()->data(PagedProxyModel::index(index.row()+ (m_currentPage*m_pageSize), index.column(), QModelIndex()), role);
}

QModelIndex PagedProxyModel::index(int row, int column, const QModelIndex &parent) const
{
    if (!sourceModel()) {
        return QModelIndex();
    }

    return sourceModel()->index(row, column, parent);
}

QModelIndex PagedProxyModel::parent(const QModelIndex &index) const
{
    return QModelIndex();
}

QModelIndex PagedProxyModel::mapFromSource(const QModelIndex &sourceIndex) const
{
    if (!sourceModel()) {
        return QModelIndex();
    }

    return sourceModel()->index(sourceIndex.row() - (m_currentPage*m_pageSize), sourceIndex.column(), QModelIndex());
}

QModelIndex PagedProxyModel::mapToSource(const QModelIndex &proxyIndex) const
{
    if (!sourceModel()) {
        return QModelIndex();
    }

    return sourceModel()->index(proxyIndex.row() + (m_currentPage*m_pageSize), proxyIndex.column(), QModelIndex());
}

int PagedProxyModel::columnCount(const QModelIndex &index) const
{
    if (!sourceModel()) {
        return 0;
    }
    return sourceModel()->columnCount(index);
}

#include "pagedproxymodel.moc"
