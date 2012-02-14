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

    connect(model, SIGNAL(rowsMoved(QModelIndex, int, int, const QModelIndex, int)),
            this, SLOT(sourceRowsMoved(QModelIndex, int, int, const QModelIndex, int)));

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

void PagedProxyModel::sourceRowsMoved(const QModelIndex &sourceParent, int sourceStart, int sourceEnd, const QModelIndex &destinationParent, int destinationRow)
{
    const int pageStart = (m_currentPage*m_pageSize);
    int newStart = qMin(m_pageSize, qMax(0, sourceStart - pageStart));
    int newEnd = qMin(m_pageSize, newStart + (sourceEnd - sourceStart));
    int newDestinationRow = qMin(m_pageSize, qMax(0, destinationRow - pageStart));

    emit beginMoveRows(sourceParent, newStart, newEnd, destinationParent, newDestinationRow);
    endMoveRows();
}

void PagedProxyModel::sourceRowsAboutToBeInserted( const QModelIndex & parentIdx, int start, int end )
{
    const int pageStart = (m_currentPage*m_pageSize);
    const int pageEnd = (m_currentPage*m_pageSize + m_pageSize);

    //insert in pages bigger than us, not interested
    if (start > pageEnd) {
        return;
    }

    //FIXME: proper indexes should be calculated
    beginResetModel();
    return;

    int newStart = qMin(m_pageSize, qMax(0, start - pageStart));
    int newEnd = qMin(m_pageSize, newStart + (end - start));

    m_oldRowCount = rowCount();
    //insert only the ones that are beyond the count
    if (newEnd > m_oldRowCount) {
        beginInsertRows(parentIdx, rowCount() - newEnd, newEnd );
    }
}


void PagedProxyModel::sourceRowsInserted( const QModelIndex& parentIdx, int start, int end )
{
    Q_UNUSED( parentIdx );

    const int pageStart = (m_currentPage*m_pageSize);
    const int pageEnd = (m_currentPage*m_pageSize + m_pageSize);

    if (start > pageEnd) {
        return;
    }

    //FIXME: proper mapped indexes should be calculated
    endResetModel();
    return;

    if (rowCount() > m_oldRowCount) {
        endInsertRows();
    }
    int newStart = qMin(m_pageSize, qMax(0, start - pageStart));
    int newEnd = qMin(m_pageSize, newStart + (end - start));

    if (newStart <= m_oldRowCount) {
        emit dataChanged(PagedProxyModel::index(newStart, 0),
                         PagedProxyModel::index(qMin(newEnd, m_oldRowCount), 0));
    }
}


void PagedProxyModel::sourceRowsAboutToBeRemoved( const QModelIndex & parentIdx, int start, int end )
{
    const int pageStart = (m_currentPage*m_pageSize);
    const int pageEnd = (m_currentPage*m_pageSize + m_pageSize);

    if (start > pageEnd) {
        return;
    }

    //FIXME: proper mapped indexes should be calculated
    beginResetModel();
    return;

    int newStart = qMin(m_pageSize, qMax(0, start - pageStart));
    int newEnd = qMin(m_pageSize, qMax(0, end - pageStart));

    m_oldRowCount = rowCount();
    //insert only the ones that are beyond the count
    if (newEnd < m_oldRowCount) {
        beginRemoveRows(parentIdx, newStart, newEnd );
    }
}


void PagedProxyModel::sourceRowsRemoved( const QModelIndex& parentIdx, int start, int end )
{
    Q_UNUSED( parentIdx );

    const int pageStart = (m_currentPage*m_pageSize);
    const int pageEnd = (m_currentPage*m_pageSize + m_pageSize);

    if (start > pageEnd) {
        return;
    }

    //FIXME: proper mapped indexes should be calculated
    endResetModel();
    return;

    if (rowCount() < m_oldRowCount) {
        endRemoveRows();
    }
    int newStart = qMin(m_pageSize, qMax(0, start - pageStart));
    int newEnd = qMin(m_pageSize, newStart + (end - start));

    if (sourceModel()->rowCount() - pageStart > rowCount()) {
        emit dataChanged(PagedProxyModel::index(newStart, 0),
                         PagedProxyModel::index(qMin((sourceModel()->rowCount() - pageStart), qMin(newEnd, m_oldRowCount)), 0));
    }
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
    Q_UNUSED(index)
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
