/*
    Copyright (C) 2012  Marco Martin <mart@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/


#ifndef RESOURCEQUERYPROVIDER_H
#define RESOURCEQUERYPROVIDER_H

#include "basicqueryprovider.h"


class ResourceQueryProvider : public BasicQueryProvider
{
    Q_OBJECT
    /**
     * @property string a free form query in the Nepomuk desktop query language
     */
    Q_PROPERTY(QString queryString READ queryString WRITE setQueryString NOTIFY queryStringChanged)

    /**
     * @property Array list of fields the results will be sorted: their order is the priority in sorting
     */
    Q_PROPERTY(QVariantList sortBy READ sortBy WRITE setSortBy NOTIFY sortByChanged)

    /**
     * @property SortOrder Qt.Ascending or Qt.Descending
     */
    Q_PROPERTY(Qt::SortOrder sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)

public:
    ResourceQueryProvider(QObject* parent = 0);
    ~ResourceQueryProvider();

    void setQueryString(const QString &query);
    QString queryString() const;

    void setSortBy(const QVariantList &sortBy);
    QVariantList sortBy() const;

    void setSortOrder(Qt::SortOrder sortOrder);
    Qt::SortOrder sortOrder() const;

Q_SIGNALS:
    void queryStringChanged();
    void sortByChanged();
    void sortOrderChanged();

protected:
    virtual void doQuery();

private:
    QString m_queryString;
    QStringList m_sortBy;
    Qt::SortOrder m_sortOrder;
};

#endif // RESOURCEQUERYPROVIDER_H
