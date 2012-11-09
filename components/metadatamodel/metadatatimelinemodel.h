/*
    Copyright 2012 Marco Martin <notmart@gmail.com>

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

#ifndef METADATATIMELINEMODEL_H
#define METADATATIMELINEMODEL_H

#include "abstractmetadatamodel.h"

#include <QDate>

#include <Nepomuk2/Query/Query>
#include <Nepomuk2/Query/Result>
#include <Nepomuk2/Query/QueryServiceClient>
#include <Nepomuk2/Resource>


namespace Nepomuk2 {
    class ResourceWatcher;
}

class BasicQueryProvider;

/**
 * This model given a query built by assigning its properties such as queryString, resourceType, startDate etc, constructs a timeline that groups pairs of period of time/number of items.
 * It can group by Year, Month, or Day.
 *
 * @author Marco Martin <mart@kde.org>
 */
class MetadataTimelineModel : public AbstractMetadataModel
{
    Q_OBJECT
    /**
     * @property int Total count of resource items: this is not the number of rows of the result, but the aggregate of how many items there are for each separate item.
     */
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)

    Q_PROPERTY(BasicQueryProvider *queryProvider READ queryProvider WRITE setQueryProvider NOTIFY queryProviderChanged)

public:
    enum Roles {
        LabelRole = Qt::UserRole + 1,
        YearRole = Qt::UserRole + 2,
        MonthRole = Qt::UserRole + 3,
        DayRole = Qt::UserRole + 4,
        CountRole = Qt::UserRole + 5
    };

    MetadataTimelineModel(QObject *parent = 0);
    ~MetadataTimelineModel();

    void setQueryProvider(BasicQueryProvider *provider);
    BasicQueryProvider *queryProvider() const;


    virtual int count() const {return m_results.count();}

    int totalCount() const {return m_totalCount;}

    //Reimplemented
    QVariant data(const QModelIndex &index, int role) const;

Q_SIGNALS:
   void totalCountChanged();
   void descriptionChanged();
   void queryProviderChanged();

protected Q_SLOTS:
    void newEntries(const QList< Nepomuk2::Query::Result > &entries);
    void entriesRemoved(const QList<QUrl> &urls);
    virtual void doQuery();
    void finishedListing();

private:
    Nepomuk2::Query::QueryServiceClient *m_queryClient;
    QVector<QHash<Roles, int> > m_results;

    int m_totalCount;
    QWeakPointer<BasicQueryProvider> m_queryProvider;
};

#endif
