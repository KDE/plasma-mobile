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


class CloudQueryProvider : public BasicQueryProvider
{
    Q_OBJECT
    /**
     * @property string Resource property that will be used to aggregate the results in a cloud
     */
    Q_PROPERTY(QString cloudCategory READ cloudCategory WRITE setCloudCategory NOTIFY cloudCategoryChanged)

    /**
     * @property Array A white list of category we want in the results. useful if a category such as the resource type has only a small subset that is actually supposed to be user facing
     */
    Q_PROPERTY(QVariantList allowedCategories READ allowedCategories WRITE setAllowedCategories NOTIFY allowedCategoriesChanged)

    /**
     * @property bool if true empty categories will be shown.
     * Default: false
     */
    Q_PROPERTY(bool showEmptyCategories READ showEmptyCategories WRITE setShowEmptyCategories NOTIFY showEmptyCategoriesChanged)


public:
    enum Roles {
        Label = Qt::UserRole+1,
        Count,
        TotalCount
    };
    CloudQueryProvider(QObject* parent = 0);
    ~CloudQueryProvider();
    QVariant formatData(const Nepomuk2::Query::Result &row, const QPersistentModelIndex &index, int role) const;

    QVariantList categories() const;

    void setAllowedCategories(const QVariantList &whitelist);
    QVariantList allowedCategories() const;

    void setShowEmptyCategories(bool show);
    bool showEmptyCategories() const;

    /**
     * rdf:type
     * nao:numericRating
     */
    void setCloudCategory(QString category);
    QString cloudCategory() const;

Q_SIGNALS:
    void cloudCategoryChanged();
    void allowedCategoriesChanged();
    void showEmptyCategoriesChanged();

protected:
    virtual void doQuery();

private:
    QString m_cloudCategory;
    bool m_showEmptyCategories;
    QSet<QString> m_allowedCategories;
};

#endif // CLOUDQUERYPROVIDER_H
