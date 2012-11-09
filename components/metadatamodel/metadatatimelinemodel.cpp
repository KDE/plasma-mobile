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

#include "metadatatimelinemodel.h"
#include "basicqueryprovider.h"
#include "timelinequeryprovider.h"


#include <KDebug>
#include <KMimeType>
#include <KCalendarSystem>

#include <soprano/vocabulary.h>

#include <Nepomuk2/File>
#include <Nepomuk2/Query/AndTerm>
#include <Nepomuk2/Query/ResourceTerm>
#include <Nepomuk2/Tag>
#include <Nepomuk2/Variant>
#include <nepomuk2/comparisonterm.h>
#include <nepomuk2/literalterm.h>
#include <nepomuk2/queryparser.h>
#include <nepomuk2/resourcetypeterm.h>
#include <nepomuk2/standardqueries.h>

#include <nepomuk2/nfo.h>
#include <nepomuk2/nie.h>

#include "kao.h"


MetadataTimelineModel::MetadataTimelineModel(QObject *parent)
    : AbstractMetadataModel(parent),
      m_queryClient(0),
      m_totalCount(0)
{
    QHash<int, QByteArray> roleNames;
    roleNames[LabelRole] = "label";
    roleNames[YearRole] = "year";
    roleNames[MonthRole] = "month";
    roleNames[DayRole] = "day";
    roleNames[CountRole] = "count";
    setRoleNames(roleNames);
    requestRefresh();
}

MetadataTimelineModel::~MetadataTimelineModel()
{
}

void MetadataTimelineModel::setQueryProvider(BasicQueryProvider *provider)
{
    if (m_queryProvider.data() == provider) {
        return;
    }

    if (m_queryProvider) {
        disconnect(m_queryProvider.data(), 0, this, 0);
    }

    connect(provider, SIGNAL(queryChanged()), this, SLOT(doQuery()));

    m_queryProvider = provider;
    doQuery();
    emit queryProviderChanged();
}

BasicQueryProvider *MetadataTimelineModel::queryProvider() const
{
    return m_queryProvider.data();
}


void MetadataTimelineModel::doQuery()
{
    QString query = queryProvider()->sparqlQuery();

    m_totalCount = 0;
    kDebug() << "Performing the Sparql query" << query;

    setRunning(true);
    beginResetModel();
    m_results.clear();
    endResetModel();
    emit countChanged();
    emit totalCountChanged();
    emit descriptionChanged();

    if (m_queryClient) {
        m_queryClient->close();
    }
    delete m_queryClient;
    m_queryClient = new Nepomuk2::Query::QueryServiceClient(this);

    connect(m_queryClient, SIGNAL(newEntries(QList<Nepomuk2::Query::Result>)),
            this, SLOT(newEntries(QList<Nepomuk2::Query::Result>)));
    connect(m_queryClient, SIGNAL(entriesRemoved(QList<QUrl>)),
            this, SLOT(entriesRemoved(QList<QUrl>)));
    connect(m_queryClient, SIGNAL(finishedListing()), this, SLOT(finishedListing()));

    m_queryClient->sparqlQuery(query);
}

void MetadataTimelineModel::newEntries(const QList< Nepomuk2::Query::Result > &entries)
{
    QVector<QHash<Roles, int> > results;
    foreach (const Nepomuk2::Query::Result &res, entries) {
        QString label;
        int count = res.additionalBinding(QLatin1String("count")).variant().toInt();
        int year = res.additionalBinding(QLatin1String("year")).variant().toInt();
        int month = res.additionalBinding(QLatin1String("month")).variant().toInt();
        int day = res.additionalBinding(QLatin1String("day")).variant().toInt();

        QHash<Roles, int> resHash;
        resHash[YearRole] = year;
        resHash[MonthRole] = month;
        resHash[DayRole] = day;
        resHash[CountRole] = count;

        m_totalCount += count;
        results << resHash;
    }

    if (results.count() > 0) {
        beginInsertRows(QModelIndex(), m_results.count(), m_results.count()+results.count());
        m_results << results;
        endInsertRows();
        emit countChanged();
        emit totalCountChanged();
        emit descriptionChanged();
    }
}

void MetadataTimelineModel::entriesRemoved(const QList<QUrl> &urls)
{
    //FIXME: we don't have urls here
    return;

    emit countChanged();
    emit totalCountChanged();
}

void MetadataTimelineModel::finishedListing()
{
    setRunning(false);
}



QVariant MetadataTimelineModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.column() != 0 ||
        index.row() < 0 || index.row() >= m_results.count()){
        return QVariant();
    }

    const QHash<Roles, int> row = m_results[index.row()];

    //HACK HACK
    TimelineQueryProvider *tp = qobject_cast<TimelineQueryProvider *>(queryProvider());
    if (!tp) {
        return QVariant();
    }

    if (role == LabelRole) {
        switch(tp->level()) {
        case TimelineQueryProvider::Year:
            return row.value(YearRole);
        case TimelineQueryProvider::Month:
            return KGlobal::locale()->calendar()->monthName(row.value(MonthRole),  row.value(YearRole), KCalendarSystem::LongName);
        case TimelineQueryProvider::Day:
        default:
            return row.value(DayRole);
        }
    }
    return row.value((Roles)role);
}

#include "metadatatimelinemodel.moc"
