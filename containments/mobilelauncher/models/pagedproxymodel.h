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

#ifndef PAGEDPROXYMODEL_H
#define PAGEDPROXYMODEL_H

#include <QProxyModel>

class PagedProxyModel : public QProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int currentPage READ currentPage WRITE setCurrentPage)
    Q_PROPERTY(int pageSize READ pageSize WRITE setPageSize)
    Q_PROPERTY(QObject *sourceModel READ sourceModel WRITE setSourceModel)

public:
    PagedProxyModel(QObject *parent = 0);
    ~PagedProxyModel();

    void setSourceModel(QObject *source);
    QObject *sourceModel() const;

    int totalPages();

    void setCurrentPage(const int page);
    int currentPage() const;

    void setPageSize(const int size);
    int pageSize() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

Q_SIGNALS:
    void modelReset();

private:
    int m_pageSize;
    int m_currentPage;
};

#endif
