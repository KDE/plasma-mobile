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


#ifndef CLOUDQUERYPROVIDER_H
#define CLOUDQUERYPROVIDER_H

#include "basicqueryprovider.h"

class CloudQueryProviderPrivate;

class CloudQueryProvider : public BasicQueryProvider
{
    Q_OBJECT
    /**
     * @property string Resource property that will be used to aggregate the results in a cloud
     */
    Q_PROPERTY(QString cloudCategory READ cloudCategory WRITE setCloudCategory NOTIFY cloudCategoryChanged)

public:
    enum Roles {
        Label = Qt::UserRole+1,
        Count,
        TotalCount
    };

    CloudQueryProvider(QObject* parent = 0);
    ~CloudQueryProvider();

    /**
     * examples:
     * rdf:type
     * nao:numericRating
     */
    void setCloudCategory(QString category);
    QString cloudCategory() const;

    /**
     * Reimplemented fron AbstractQueryProvider
     */
    virtual QVariant formatData(const Nepomuk2::Query::Result &row, const QPersistentModelIndex &index, int role) const;

Q_SIGNALS:
    void cloudCategoryChanged();

protected Q_SLOTS:
    virtual void doQuery();

private:
    CloudQueryProviderPrivate *const d;
};

#endif // CLOUDQUERYPROVIDER_H
