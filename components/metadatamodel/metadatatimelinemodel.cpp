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

#include <QTimer>

#include <KDebug>
#include <KMimeType>

#include <soprano/vocabulary.h>

#include <Nepomuk/File>
#include <Nepomuk/Query/AndTerm>
#include <Nepomuk/Query/ResourceTerm>
#include <Nepomuk/Tag>
#include <Nepomuk/Variant>
#include <nepomuk/comparisonterm.h>
#include <nepomuk/literalterm.h>
#include <nepomuk/queryparser.h>
#include <nepomuk/resourcetypeterm.h>
#include <nepomuk/standardqueries.h>

#include <nepomuk/nfo.h>
#include <nepomuk/nie.h>

#include "kext.h"


MetadataTimelineModel::MetadataTimelineModel(QObject *parent)
    : AbstractMetadataModel(parent),
      m_queryClient(0),
      m_totalCount(0)
{
    m_queryTimer = new QTimer(this);
    m_queryTimer->setSingleShot(true);
    connect(m_queryTimer, SIGNAL(timeout()),
            this, SLOT(doQuery()));


    QHash<int, QByteArray> roleNames;
    roleNames[YearRole] = "year";
    roleNames[MonthRole] = "month";
    roleNames[DayRole] = "month";
    roleNames[CountRole] = "count";
    setRoleNames(roleNames);
    m_queryTimer->start(100);
}

MetadataTimelineModel::~MetadataTimelineModel()
{
}


void MetadataTimelineModel::setLevel(MetadataTimelineModel::Level level)
{
    if (m_level == level) {
        return;
    }

    m_level = level;
    m_queryTimer->start(0);
    emit levelChanged();
}

MetadataTimelineModel::Level MetadataTimelineModel::level() const
{
    return m_level;
}



void MetadataTimelineModel::doQuery()
{
    QDeclarativePropertyMap *parameters = qobject_cast<QDeclarativePropertyMap *>(extraParameters());

    m_totalCount = 0;

    setStatus(Waiting);
    QString monthQuery;
    QString dayQuery;

    if (m_level >= Month) {
        monthQuery = "bif:month(?label)";
    } else {
        monthQuery = "0";
    }
    if (m_level >= Day) {
        dayQuery = "bif:dayofmonth(?label)";
    } else {
        dayQuery = "0";
    }

    QString query = QString("select distinct bif:year(?label) as ?year %1 as ?month %2 as ?day count(*) as ?count where { ?r nie:lastModified ?label  ").arg(monthQuery).arg(dayQuery);


    if (!resourceType().isEmpty()) {
        QString type = resourceType();
        bool negation = false;
        if (type.startsWith("!")) {
            type = type.remove(0, 1);
            negation = true;
        }
        if (negation) {
            query += " . FILTER(!bif:exists((select (1) where { ?r rdf:type " + type + " . }))) ";
        } else {
            query += " . ?r rdf:type " + type;
        }

        if (type != "nfo:Bookmark") {
            //FIXME: remove bookmarks if not explicitly asked for
            query += " . FILTER(!bif:exists((select (1) where { ?r a <http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Bookmark> . }))) ";
        }
    }

    if (!mimeType().isEmpty()) {
        QString type = mimeType();
        bool negation = false;
        if (type.startsWith("!")) {
            type = type.remove(0, 1);
            negation = true;
        }
        if (negation) {
            query += " . FILTER(!bif:exists((select (1) where { ?r nie:mimeType ?mimeType . FILTER(bif:contains(?mimeType, \"'" + type + "'\")) . }))) ";
        } else {
            query += " . ?r nie:mimeType ?mimeType . FILTER(bif:contains(?mimeType, \"'" + type + "'\")) ";
        }
    }

    if (parameters && parameters->size() > 0) {
        foreach (const QString &key, parameters->keys()) {
            QString parameter = parameters->value(key).toString();
            bool negation = false;
            if (parameter.startsWith("!")) {
                parameter = parameter.remove(0, 1);
                negation = true;
            }

            if (negation) {
                query += " . FILTER(!bif:exists((select (1) where { ?r " + key + " ?mimeType . FILTER(bif:contains(?mimeType, \"'" + parameter + "'\")) . }))) ";
            } else {
                query += " . ?r " + key + " ?mimeType . FILTER(bif:contains(?mimeType, \"'" + parameter + "'\")) ";
            }
        }
    }

    if (!activityId().isEmpty()) {
        QString activity = activityId();
        bool negation = false;
        if (activity.startsWith("!")) {
            activity = activity.remove(0, 1);
            negation = true;
        }
        Nepomuk::Resource acRes(activity, Nepomuk::Vocabulary::KEXT::Activity());

        if (negation) {
            query +=  ". FILTER(!bif:exists((select (1) where { <" + acRes.resourceUri().toString() + "> <http://www.semanticdesktop.org/ontologies/2007/08/15/nao#isRelated> ?r . }))) ";
        } else {
            query +=  " . <" + acRes.resourceUri().toString() + "> nao:isRelated ?r ";
        }
    }

    //this is an AND set of tags.. should be allowed OR as well?
    foreach (const QString &tag, tagStrings()) {
        QString individualTag = tag;
        bool negation = false;

        if (individualTag.startsWith("!")) {
            individualTag = individualTag.remove(0, 1);
            negation = true;
        }

        if (negation) {
            query += ". FILTER(!bif:exists((select (1) where { ?r nao:hasTag ?tagSet \
                    . ?tagSet ?tagLabel ?tag \
                    . ?tagLabel <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://www.w3.org/2000/01/rdf-schema#label> \
                    . FILTER(bif:contains(?tag, \"'"+individualTag+"'\"))}))) ";
        } else {
            query += ". ?r nao:hasTag ?tagSet \
                    . ?tagSet ?tagLabel ?tag \
                    . ?tagLabel <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://www.w3.org/2000/01/rdf-schema#label> \
                    . FILTER(bif:contains(?tag, \"'"+individualTag+"'\")) ";
        }
    }

    if (startDate().isValid() || endDate().isValid()) {
        if (startDate().isValid()) {
            query += " . { \
            ?r <http://www.semanticdesktop.org/ontologies/2007/01/19/nie#lastModified> ?v2 . FILTER(?v2>\"" + startDate().toString(Qt::ISODate) + "\"^^<http://www.w3.org/2001/XMLSchema#dateTime>) . \
            } UNION {\
            ?r <http://www.semanticdesktop.org/ontologies/2007/01/19/nie#contentCreated> ?v3 . FILTER(?v3>\"" + startDate().toString(Qt::ISODate) + "\"^^<http://www.w3.org/2001/XMLSchema#dateTime>) . \
            } UNION {\
            ?v4 <http://www.semanticdesktop.org/ontologies/2010/01/25/nuao#involves> ?r .\
            ?v4 <http://www.semanticdesktop.org/ontologies/2010/01/25/nuao#start> ?v5 .\ FILTER(?v5>\"" + startDate().toString(Qt::ISODate) + "\"^^<http://www.w3.org/2001/XMLSchema#dateTime>) . \
            }";
        }
        if (endDate().isValid()) {
            query += " . { \
            ?r <http://www.semanticdesktop.org/ontologies/2007/01/19/nie#lastModified> ?v2 . FILTER(?v2<\"" + endDate().toString(Qt::ISODate) + "\"^^<http://www.w3.org/2001/XMLSchema#dateTime>) . \
            } UNION {\
            ?r <http://www.semanticdesktop.org/ontologies/2007/01/19/nie#contentCreated> ?v3 . FILTER(?v3<\"" + endDate().toString(Qt::ISODate) + "\"^^<http://www.w3.org/2001/XMLSchema#dateTime>) . \
            } UNION {\
            ?v4 <http://www.semanticdesktop.org/ontologies/2010/01/25/nuao#involves> ?r .\
            ?v4 <http://www.semanticdesktop.org/ontologies/2010/01/25/nuao#start> ?v5 .\ FILTER(?v5<\"" + endDate().toString(Qt::ISODate) + "\"^^<http://www.w3.org/2001/XMLSchema#dateTime>) . \
            }";
        }
    }

    if (minimumRating() > 0) {
        query += " . ?r nao:numericRating ?rating filter (?rating >=" + QString::number(minimumRating()) + ") ";
    }

    if (maximumRating() > 0) {
        query += " . ?r nao:numericRating ?rating filter (?rating <=" + QString::number(maximumRating()) + ") ";
    }

    query +=  " . ?r <http://www.semanticdesktop.org/ontologies/2007/08/15/nao#userVisible> ?v1 . FILTER(?v1>0) .  } ";

    //Group by construction
    query += " group by bif:year(?label) ";
    if (m_level >= Month) {
        query += " bif:month(?label) ";
    }
    if (m_level >= Day) {
        query += " bif:dayofmonth(?label) ";
    }
    query += " order by ?year ?month ?day ";

    kDebug() << "Performing the Sparql query" << query;

    beginResetModel();
    m_results.clear();
    endResetModel();
    emit countChanged();
    emit totalCountChanged();

    delete m_queryClient;
    m_queryClient = new Nepomuk::Query::QueryServiceClient(this);

    connect(m_queryClient, SIGNAL(newEntries(const QList<Nepomuk::Query::Result> &)),
            this, SLOT(newEntries(const QList<Nepomuk::Query::Result> &)));
    connect(m_queryClient, SIGNAL(entriesRemoved(const QList<QUrl> &)),
            this, SLOT(entriesRemoved(const QList<QUrl> &)));
    connect(m_queryClient, SIGNAL(finishedListing()), this, SLOT(finishedListing()));

    m_queryClient->sparqlQuery(query);
}

void MetadataTimelineModel::newEntries(const QList< Nepomuk::Query::Result > &entries)
{
    setStatus(Running);
    QVector<QHash<Roles, int> > results;
    QVariantList categories;

    foreach (Nepomuk::Query::Result res, entries) {
        QString label;
        int count = res.additionalBinding(QLatin1String("count")).variant().toInt();
        int year = res.additionalBinding(QLatin1String("year")).variant().toInt();
        int month = res.additionalBinding(QLatin1String("month")).variant().toInt();
        int day = res.additionalBinding(QLatin1String("month")).variant().toInt();

        QHash<Roles, int> res;
        res[YearRole] = year;
        res[MonthRole] = month;
        res[DayRole] = day;
        res[CountRole] = count;
        m_totalCount += count;
        results << res;
    }

    if (results.count() > 0) {
        beginInsertRows(QModelIndex(), m_results.count(), m_results.count()+results.count());
        m_results << results;
        m_categories << categories;
        endInsertRows();
        emit countChanged();
        emit totalCountChanged();
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
    setStatus(Idle);
}



QVariant MetadataTimelineModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.column() != 0 ||
        index.row() < 0 || index.row() >= m_results.count()){
        return QVariant();
    }

    const QHash<Roles, int> row = m_results[index.row()];

    return row.value((Roles)role);
}

#include "metadatatimelinemodel.moc"
