/*
 *   SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "paginatemodel.h"
#include <QtMath>

class PaginateModel::PaginateModelPrivate
{
public:
    int m_firstItem = 0;
    int m_pageSize = 0;
    QAbstractItemModel *m_sourceModel = nullptr;
    bool m_hasStaticRowCount = false;
};

PaginateModel::PaginateModel(QObject *object)
    : QAbstractListModel(object)
    , d(new PaginateModelPrivate)
{
}

PaginateModel::~PaginateModel() = default;

int PaginateModel::firstItem() const
{
    return d->m_firstItem;
}

void PaginateModel::setFirstItem(int row)
{
    Q_ASSERT(row >= 0 && row < d->m_sourceModel->rowCount());
    if (row != d->m_firstItem) {
        beginResetModel();
        d->m_firstItem = row;
        endResetModel();
        Q_EMIT firstItemChanged();
    }
}

int PaginateModel::pageSize() const
{
    return d->m_pageSize;
}

void PaginateModel::setPageSize(int count)
{
    if (count != d->m_pageSize) {
        const int oldSize = rowsByPageSize(d->m_pageSize);
        const int newSize = rowsByPageSize(count);
        const int difference = newSize - oldSize;
        if (difference == 0) {
            d->m_pageSize = count;
        } else if (difference > 0) {
            beginInsertRows(QModelIndex(), d->m_pageSize, d->m_pageSize + difference - 1);
            d->m_pageSize = count;
            endInsertRows();
        } else {
            beginRemoveRows(QModelIndex(), d->m_pageSize + difference, d->m_pageSize - 1);
            d->m_pageSize = count;
            endRemoveRows();
        }
        Q_EMIT pageSizeChanged();
    }
}

QAbstractItemModel *PaginateModel::sourceModel() const
{
    return d->m_sourceModel;
}

void PaginateModel::setSourceModel(QAbstractItemModel *model)
{
    if (model == d->m_sourceModel) {
        return;
    }

    if (d->m_sourceModel) {
        disconnect(d->m_sourceModel, nullptr, this, nullptr);
    }

    beginResetModel();
    d->m_sourceModel = model;
    if (model) {
        connect(d->m_sourceModel, &QAbstractItemModel::rowsAboutToBeInserted, this, &PaginateModel::_k_sourceRowsAboutToBeInserted);
        connect(d->m_sourceModel, &QAbstractItemModel::rowsInserted, this, &PaginateModel::_k_sourceRowsInserted);
        connect(d->m_sourceModel, &QAbstractItemModel::rowsAboutToBeRemoved, this, &PaginateModel::_k_sourceRowsAboutToBeRemoved);
        connect(d->m_sourceModel, &QAbstractItemModel::rowsRemoved, this, &PaginateModel::_k_sourceRowsRemoved);
        connect(d->m_sourceModel, &QAbstractItemModel::rowsAboutToBeMoved, this, &PaginateModel::_k_sourceRowsAboutToBeMoved);
        connect(d->m_sourceModel, &QAbstractItemModel::rowsMoved, this, &PaginateModel::_k_sourceRowsMoved);

        connect(d->m_sourceModel, &QAbstractItemModel::columnsAboutToBeInserted, this, &PaginateModel::_k_sourceColumnsAboutToBeInserted);
        connect(d->m_sourceModel, &QAbstractItemModel::columnsInserted, this, &PaginateModel::_k_sourceColumnsInserted);
        connect(d->m_sourceModel, &QAbstractItemModel::columnsAboutToBeRemoved, this, &PaginateModel::_k_sourceColumnsAboutToBeRemoved);
        connect(d->m_sourceModel, &QAbstractItemModel::columnsRemoved, this, &PaginateModel::_k_sourceColumnsRemoved);
        connect(d->m_sourceModel, &QAbstractItemModel::columnsAboutToBeMoved, this, &PaginateModel::_k_sourceColumnsAboutToBeMoved);
        connect(d->m_sourceModel, &QAbstractItemModel::columnsMoved, this, &PaginateModel::_k_sourceColumnsMoved);

        connect(d->m_sourceModel, &QAbstractItemModel::dataChanged, this, &PaginateModel::_k_sourceDataChanged);
        connect(d->m_sourceModel, &QAbstractItemModel::headerDataChanged, this, &PaginateModel::_k_sourceHeaderDataChanged);

        connect(d->m_sourceModel, &QAbstractItemModel::modelAboutToBeReset, this, &PaginateModel::_k_sourceModelAboutToBeReset);
        connect(d->m_sourceModel, &QAbstractItemModel::modelReset, this, &PaginateModel::_k_sourceModelReset);

        connect(d->m_sourceModel, &QAbstractItemModel::rowsInserted, this, &PaginateModel::pageCountChanged);
        connect(d->m_sourceModel, &QAbstractItemModel::rowsRemoved, this, &PaginateModel::pageCountChanged);
        connect(d->m_sourceModel, &QAbstractItemModel::modelReset, this, &PaginateModel::pageCountChanged);
    }
    endResetModel();
    Q_EMIT sourceModelChanged();
}

QHash<int, QByteArray> PaginateModel::roleNames() const
{
    return d->m_sourceModel ? d->m_sourceModel->roleNames() : QAbstractItemModel::roleNames();
}

int PaginateModel::rowsByPageSize(int size) const
{
    return d->m_hasStaticRowCount ? size : !d->m_sourceModel ? 0 : qMin(d->m_sourceModel->rowCount() - d->m_firstItem, size);
}

int PaginateModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : rowsByPageSize(d->m_pageSize);
}

QModelIndex PaginateModel::mapToSource(const QModelIndex &idx) const
{
    if (!d->m_sourceModel)
        return QModelIndex();
    return d->m_sourceModel->index(idx.row() + d->m_firstItem, idx.column());
}

QModelIndex PaginateModel::mapFromSource(const QModelIndex &idx) const
{
    Q_ASSERT(idx.model() == d->m_sourceModel);
    if (!d->m_sourceModel)
        return QModelIndex();
    return index(idx.row() - d->m_firstItem, idx.column());
}

QVariant PaginateModel::data(const QModelIndex &index, int role) const
{
    if (!d->m_sourceModel)
        return QVariant();
    QModelIndex idx = mapToSource(index);
    return idx.data(role);
}

void PaginateModel::firstPage()
{
    setFirstItem(0);
}

void PaginateModel::lastPage()
{
    setFirstItem((pageCount() - 1) * d->m_pageSize);
}

void PaginateModel::nextPage()
{
    setFirstItem(d->m_firstItem + d->m_pageSize);
}

void PaginateModel::previousPage()
{
    setFirstItem(d->m_firstItem - d->m_pageSize);
}

int PaginateModel::currentPage() const
{
    if (d->m_pageSize == 0)
        return 0;

    return d->m_firstItem / d->m_pageSize;
}

int PaginateModel::pageCount() const
{
    if (!d->m_sourceModel || d->m_pageSize == 0)
        return 0;
    const int rc = d->m_sourceModel->rowCount();
    const int r = (rc % d->m_pageSize == 0) ? 1 : 0;
    return qMax(qCeil(float(rc) / d->m_pageSize) - r, 1);
}

bool PaginateModel::hasStaticRowCount() const
{
    return d->m_hasStaticRowCount;
}

void PaginateModel::setStaticRowCount(bool src)
{
    if (src == d->m_hasStaticRowCount) {
        return;
    }

    beginResetModel();
    d->m_hasStaticRowCount = src;
    endResetModel();

    Q_EMIT staticRowCountChanged();
}

//////////////////////////////

void PaginateModel::_k_sourceColumnsAboutToBeInserted(const QModelIndex &parent, int start, int end)
{
    Q_UNUSED(end)
    if (parent.isValid() || start != 0) {
        return;
    }
    beginResetModel();
}

void PaginateModel::_k_sourceColumnsAboutToBeMoved(const QModelIndex &sourceParent, int sourceStart, int sourceEnd, const QModelIndex &destParent, int dest)
{
    Q_UNUSED(sourceParent)
    Q_UNUSED(sourceStart)
    Q_UNUSED(sourceEnd)
    Q_UNUSED(destParent)
    Q_UNUSED(dest)
    beginResetModel();
}

void PaginateModel::_k_sourceColumnsAboutToBeRemoved(const QModelIndex &parent, int start, int end)
{
    Q_UNUSED(end)
    if (parent.isValid() || start != 0) {
        return;
    }
    beginResetModel();
}

void PaginateModel::_k_sourceColumnsInserted(const QModelIndex &parent, int start, int end)
{
    Q_UNUSED(end)
    if (parent.isValid() || start != 0) {
        return;
    }
    endResetModel();
}

void PaginateModel::_k_sourceColumnsMoved(const QModelIndex &sourceParent, int sourceStart, int sourceEnd, const QModelIndex &destParent, int dest)
{
    Q_UNUSED(sourceParent)
    Q_UNUSED(sourceStart)
    Q_UNUSED(sourceEnd)
    Q_UNUSED(destParent)
    Q_UNUSED(dest)
    endResetModel();
}

void PaginateModel::_k_sourceColumnsRemoved(const QModelIndex &parent, int start, int end)
{
    Q_UNUSED(end)
    if (parent.isValid() || start != 0) {
        return;
    }
    endResetModel();
}

void PaginateModel::_k_sourceDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles)
{
    if (topLeft.parent().isValid() || bottomRight.row() < d->m_firstItem || topLeft.row() > lastItem()) {
        return;
    }

    QModelIndex idxTop = mapFromSource(topLeft);
    QModelIndex idxBottom = mapFromSource(bottomRight);
    if (!idxTop.isValid())
        idxTop = index(0);
    if (!idxBottom.isValid())
        idxBottom = index(rowCount() - 1);

    Q_EMIT dataChanged(idxTop, idxBottom, roles);
}

void PaginateModel::_k_sourceHeaderDataChanged(Qt::Orientation orientation, int first, int last)
{
    Q_UNUSED(last)
    if (first == 0)
        Q_EMIT headerDataChanged(orientation, 0, 0);
}

void PaginateModel::_k_sourceModelAboutToBeReset()
{
    beginResetModel();
}

void PaginateModel::_k_sourceModelReset()
{
    endResetModel();
}

bool PaginateModel::isIntervalValid(const QModelIndex &parent, int start, int /*end*/) const
{
    return !parent.isValid() && start <= lastItem();
}

bool PaginateModel::canSizeChange() const
{
    return !d->m_hasStaticRowCount && currentPage() == pageCount() - 1;
}

void PaginateModel::_k_sourceRowsAboutToBeInserted(const QModelIndex &parent, int start, int end)
{
    if (!isIntervalValid(parent, start, end)) {
        return;
    }

    if (canSizeChange()) {
        const int newStart = qMax(start - d->m_firstItem, 0);
        const int insertedCount = qMin(end - start, pageSize() - newStart - 1);
        beginInsertRows(QModelIndex(), newStart, newStart + insertedCount);
    } else {
        beginResetModel();
    }
}

void PaginateModel::_k_sourceRowsInserted(const QModelIndex &parent, int start, int end)
{
    if (!isIntervalValid(parent, start, end)) {
        return;
    }

    if (canSizeChange()) {
        endInsertRows();
    } else {
        endResetModel();
    }
}

void PaginateModel::_k_sourceRowsAboutToBeMoved(const QModelIndex &sourceParent, int sourceStart, int sourceEnd, const QModelIndex &destParent, int dest)
{
    Q_UNUSED(sourceParent)
    Q_UNUSED(sourceStart)
    Q_UNUSED(sourceEnd)
    Q_UNUSED(destParent)
    Q_UNUSED(dest)
    // NOTE could optimize, unsure if it makes sense
    beginResetModel();
}

void PaginateModel::_k_sourceRowsMoved(const QModelIndex &sourceParent, int sourceStart, int sourceEnd, const QModelIndex &destParent, int dest)
{
    Q_UNUSED(sourceParent)
    Q_UNUSED(sourceStart)
    Q_UNUSED(sourceEnd)
    Q_UNUSED(destParent)
    Q_UNUSED(dest)
    endResetModel();
}

void PaginateModel::_k_sourceRowsAboutToBeRemoved(const QModelIndex &parent, int start, int end)
{
    if (!isIntervalValid(parent, start, end)) {
        return;
    }

    if (canSizeChange()) {
        const int removedCount = end - start;
        const int newStart = qMax(start - d->m_firstItem, 0);
        beginRemoveRows(QModelIndex(), newStart, newStart + removedCount);
    } else {
        beginResetModel();
    }
}

void PaginateModel::_k_sourceRowsRemoved(const QModelIndex &parent, int start, int end)
{
    if (!isIntervalValid(parent, start, end)) {
        return;
    }

    if (canSizeChange()) {
        endRemoveRows();
    } else {
        endResetModel();
    }
}

int PaginateModel::lastItem() const
{
    return d->m_firstItem + rowCount();
}
