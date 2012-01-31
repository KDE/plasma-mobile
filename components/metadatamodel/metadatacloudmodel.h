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

#ifndef METADATACLOUDMODEL_H
#define METADATACLOUDMODEL_H

#include "abstractmetadatamodel.h"

#include <QDate>

#include <Nepomuk/Query/Query>
#include <Nepomuk/Query/Result>
#include <Nepomuk/Query/QueryServiceClient>
#include <Nepomuk/Resource>


namespace Nepomuk {
    class ResourceWatcher;
}

class MetadataCloudModel : public AbstractMetadataModel
{
    Q_OBJECT

    Q_PROPERTY(QString cloudCategory READ cloudCategory WRITE setCloudCategory NOTIFY cloudCategoryChanged)
    Q_PROPERTY(QVariantList categories READ categories NOTIFY categoriesChanged)
    Q_PROPERTY(QVariantList allowedCategories READ allowedCategories WRITE setAllowedCategories NOTIFY allowedCategoriesChanged)

public:
    enum Roles {
        Label = Qt::UserRole+1,
        Count
    };

    MetadataCloudModel(QObject *parent = 0);
    ~MetadataCloudModel();

    virtual int count() const {return m_results.count();}

    QVariantList categories() const;

    void setAllowedCategories(const QVariantList &whitelist);
    QVariantList allowedCategories() const;

    /**
     * rdf:type
     * nao:numericRating
     */
    void setCloudCategory(QString category);
    QString cloudCategory() const;

    //Reimplemented
    QVariant data(const QModelIndex &index, int role) const;

Q_SIGNALS:
   void cloudCategoryChanged();
   void categoriesChanged();
   void allowedCategoriesChanged();

protected Q_SLOTS:
    void newEntries(const QList< Nepomuk::Query::Result > &entries);
    void entriesRemoved(const QList<QUrl> &urls);
    virtual void doQuery();
    void finishedListing();

private:
    Nepomuk::Query::QueryServiceClient *m_queryClient;
    QVector<QPair<QString, int> > m_results;
    QVariantList m_categories;
    QSet<QString> m_allowedCategories;

    //pieces to build m_query
    QString m_cloudCategory;
};

#endif
