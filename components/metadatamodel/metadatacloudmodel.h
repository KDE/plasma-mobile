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

/**
 * This model shows aggregates of results and their count, to build things such as a tag cloud: pairs of tag name/count of items in the cloud.
 * Besides seriving as a tag cloud it can group by any other Nepomuk Resource property, such as date, name, file type etc.
 * @author Marco MArtin <mart@kde.org>
 */
class MetadataCloudModel : public AbstractMetadataModel
{
    Q_OBJECT

    /**
     * @property string Resource property that will be used to aggregate the results in a cloud
     */
    Q_PROPERTY(QString cloudCategory READ cloudCategory WRITE setCloudCategory NOTIFY cloudCategoryChanged)

    /**
     * @property Array A list of all categories that have been collected in the results, depending from cloudCategory.
     * They may be a list of all the present tags, of dates, of types and so on.
     */
    Q_PROPERTY(QVariantList categories READ categories NOTIFY categoriesChanged)

    /**
     * @property Array A white list of category we want in the results. useful if a category such as the resource type has only a small subset that is actually supposed to be user facing
     */
    Q_PROPERTY(QVariantList allowedCategories READ allowedCategories WRITE setAllowedCategories NOTIFY allowedCategoriesChanged)

    /**
     * @property string A resource type. If set all categories properties must be of this type.
     * For instance hasTag can be restricted to only show a grouping of what is actually nao:Tag, or rdf:Type may show only a
     * grouping of stuff that has nfo:Document as type.
     * If this is set eventual empty categories will be shown.
     */
    Q_PROPERTY(QString categoryType READ categoryType WRITE setCategoryType NOTIFY categoryTypeChanged)

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

    void setCategoryType(const QString &type);
    QString categoryType() const;

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
   void categoryTypeChanged();

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
    QString m_categoryType;
};

#endif
