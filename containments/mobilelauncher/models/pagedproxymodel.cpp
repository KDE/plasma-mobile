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
    : QProxyModel(parent),
      m_pageSize(16),
      m_currentPage(0)
{
}

PagedProxyModel::~PagedProxyModel()
{
}

int PagedProxyModel::totalPages()
{
    if (!model()) {
        return 0;
    }

    return model()->rowCount() / m_pageSize;
}

void PagedProxyModel::setCurrentPage(const int page)
{
    if (m_currentPage == page) {
        return;
    }

    m_currentPage = page;
    emit modelReset();
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

    m_pageSize = size;
    emit modelReset();
}

int PagedProxyModel::pageSize() const
{
    return m_pageSize;
}

void PagedProxyModel::setSourceModel(QObject *source)
{
    QAbstractItemModel *model = qobject_cast<QAbstractItemModel *>(source);
    if (!model) {
        return;
    }
    setRoleNames(model->roleNames());
    setModel(model);
}

QObject *PagedProxyModel::sourceModel() const
{
    return model();
}


int PagedProxyModel::rowCount(const QModelIndex &parent) const
{
    return qMin(m_pageSize, (QProxyModel::rowCount(parent)-m_currentPage*m_pageSize));
}

QVariant PagedProxyModel::data(const QModelIndex &index, int role) const
{
    return QProxyModel::data(QProxyModel::index(index.row()+(m_pageSize*m_currentPage), index.column()), role);
}

#include "pagedproxymodel.moc"
