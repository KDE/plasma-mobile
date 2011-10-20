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

#include "metadatacloudmodel.h"

#include <QDBusConnection>
#include <QDBusServiceWatcher>
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


MetadataCloudModel::MetadataCloudModel(QObject *parent)
    : AbstractMetadataModel(parent),
      m_queryClient(0)
{
    m_queryTimer = new QTimer(this);
    m_queryTimer->setSingleShot(true);
    connect(m_queryTimer, SIGNAL(timeout()),
            this, SLOT(doQuery()));


    QHash<int, QByteArray> roleNames;
    roleNames[Label] = "label";
    roleNames[Count] = "count";
    setRoleNames(roleNames);
}

MetadataCloudModel::~MetadataCloudModel()
{
}


void MetadataCloudModel::setCloudCategory(QString category)
{
    if (m_cloudCategory == category) {
        return;
    }

    m_cloudCategory = category;
    m_queryTimer->start(0);
    emit cloudCategoryChanged();
}

QString MetadataCloudModel::cloudCategory() const
{
    return m_cloudCategory;
}



void MetadataCloudModel::doQuery()
{
    QString query = "select distinct ?label count(*) as ?count where { ";

    if (m_cloudCategory == "kext:Activity") {
        query += " ?activity nao:isRelated ?r . ?activity rdf:type kext:Activity . ?activity kext:activityIdentifier ?label ";
    } else {
        query += " ?r " + m_cloudCategory + " ?label";
    }


    if (!resourceType().isEmpty() && m_cloudCategory != "rdf:type") {
        query += " . ?r rdf:type " + resourceType();
    }

    if (!activityId().isEmpty() && m_cloudCategory != "kext:Activity") {
        Nepomuk::Resource acRes(activityId(), Nepomuk::Vocabulary::KEXT::Activity());
        query +=  " . <" + acRes.resourceUri().toString() + "> nao:isRelated ?r ";
    }

    //this is an AND set of tags.. should be allowed OR as well?
    foreach (const QString &tag, tagStrings()) {
        query += ". ?r nao:hasTag ?tagSet \
                  . ?tagSet ?tagLabel ?tag \
                  . ?tagLabel <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://www.w3.org/2000/01/rdf-schema#label> \
                  . FILTER(bif:contains(?tag, \"'"+tag+"'\")) ";
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

    query +=  " . ?r <http://www.semanticdesktop.org/ontologies/2007/08/15/nao#userVisible> ?v1 . FILTER(?v1>0) .  } group by ?label order by ?label";

    kDebug() << "Performing the Sparql query" << query;

    beginResetModel();
    m_results.clear();
    endResetModel();
    emit countChanged();

    delete m_queryClient;
    m_queryClient = new Nepomuk::Query::QueryServiceClient(this);

    connect(m_queryClient, SIGNAL(newEntries(const QList<Nepomuk::Query::Result> &)),
            this, SLOT(newEntries(const QList<Nepomuk::Query::Result> &)));
    connect(m_queryClient, SIGNAL(entriesRemoved(const QList<QUrl> &)),
            this, SLOT(entriesRemoved(const QList<QUrl> &)));

    m_queryClient->sparqlQuery(query);
}

void MetadataCloudModel::newEntries(const QList< Nepomuk::Query::Result > &entries)
{
    QVector<QPair<QString, int> > results;
    foreach (Nepomuk::Query::Result res, entries) {
        QString label;
        int count = res.additionalBinding(QLatin1String("count")).variant().toInt();
        QVariant rawLabel = res.additionalBinding(QLatin1String("label")).variant();

        if (rawLabel.canConvert<Nepomuk::Resource>()) {
            label = rawLabel.value<Nepomuk::Resource>().className();
        } else if (!rawLabel.value<QUrl>().scheme().isEmpty()) {
            const QUrl url = rawLabel.value<QUrl>();
            if (url.scheme() == "nepomuk") {
                label = Nepomuk::Resource(url).genericLabel();
            //TODO: it should convert from ontology url to short form nfo:Document
            } else {
                label = url.fragment();
            }
        } else if (rawLabel.canConvert<QString>()) {
            label = rawLabel.toString();
        } else if (rawLabel.canConvert<int>()) {
            label = QString::number(rawLabel.toInt());
        } else {
            continue;
        }

        if (label.isEmpty()) {
            continue;
        }
        results << QPair<QString, int>(label, count);
    }
    if (results.count() > 0) {
        beginInsertRows(QModelIndex(), m_results.count(), m_results.count()+results.count());
        m_results << results;
        endInsertRows();
        emit countChanged();
    }
}

void MetadataCloudModel::entriesRemoved(const QList<QUrl> &urls)
{
    //TODO
    emit countChanged();
}



QVariant MetadataCloudModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.column() > 0 ||
        index.row() < 0 || index.row() >= m_results.count()){
        return QVariant();
    }

    const QPair<QString, int> row = m_results[index.row()];

    switch (role) {
    case Label:
        return row.first;
    case Count:
        return row.second;
    default:
        return QVariant();
    }
}

#include "metadatacloudmodel.moc"
