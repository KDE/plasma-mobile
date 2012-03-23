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

#include <kao.h>


MetadataCloudModel::MetadataCloudModel(QObject *parent)
    : AbstractMetadataModel(parent),
      m_queryClient(0)
{
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
    askRefresh();
    emit cloudCategoryChanged();
}

QString MetadataCloudModel::cloudCategory() const
{
    return m_cloudCategory;
}

QVariantList MetadataCloudModel::categories() const
{
    return m_categories;
}

void MetadataCloudModel::setAllowedCategories(const QVariantList &whitelist)
{
    QSet<QString> set = variantToStringList(whitelist).toSet();

    if (set == m_allowedCategories) {
        return;
    }

    m_allowedCategories = set;
    emit allowedCategoriesChanged();
}

QVariantList MetadataCloudModel::allowedCategories() const
{
    return stringToVariantList(m_allowedCategories.values());
}


void MetadataCloudModel::doQuery()
{
    QDeclarativePropertyMap *parameters = qobject_cast<QDeclarativePropertyMap *>(extraParameters());

    //check if really all properties to build the query are null
    if (m_cloudCategory.isEmpty()) {
        return;
    }

    setStatus(Waiting);
    QString query = "select distinct ?label count(*) as ?count where { ";

    if (m_cloudCategory == "kao:Activity") {
        query += " ?activity nao:isRelated ?r . ?activity rdf:type kao:Activity . ?activity kao:activityIdentifier ?label ";
    } else {
        query += " ?r " + m_cloudCategory + " ?label";
    }


    if (!resourceType().isEmpty()) {
        QString type = resourceType();
        bool negation = false;
        if (type.startsWith('!')) {
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
        if (type.startsWith('!')) {
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
            if (parameter.startsWith('!')) {
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
        if (activity.startsWith('!')) {
            activity = activity.remove(0, 1);
            negation = true;
        }
        Nepomuk::Resource acRes(activity, Nepomuk::Vocabulary::KAO::Activity());

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

        if (individualTag.startsWith('!')) {
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

    //Exclude who doesn't have url
    query += " . FILTER(bif:exists((select (1) where { ?r nie:url ?h . }))) ";

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
    connect(m_queryClient, SIGNAL(finishedListing()), this, SLOT(finishedListing()));

    m_queryClient->sparqlQuery(query);
}

void MetadataCloudModel::newEntries(const QList< Nepomuk::Query::Result > &entries)
{
    setStatus(Running);
    QVector<QPair<QString, int> > results;
    QVariantList categories;

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
                label = propertyShortName(url);
            }
        } else if (rawLabel.canConvert<QString>()) {
            label = rawLabel.toString();
        } else if (rawLabel.canConvert<int>()) {
            label = QString::number(rawLabel.toInt());
        } else {
            continue;
        }

        if (label.isEmpty() ||
            !(m_allowedCategories.isEmpty() || m_allowedCategories.contains(label))) {
            continue;
        }
        results << QPair<QString, int>(label, count);
        categories << label;
    }
    if (results.count() > 0) {
        beginInsertRows(QModelIndex(), m_results.count(), m_results.count()+results.count()-1);
        m_results << results;
        m_categories << categories;
        endInsertRows();
        emit countChanged();
        emit categoriesChanged();
    }
}

void MetadataCloudModel::entriesRemoved(const QList<QUrl> &urls)
{
    //FIXME: optimize
    kDebug()<<urls;
    foreach (const QUrl &url, urls) {
        const QString propName = propertyShortName(url);
        int i = 0;
        int index = -1;
        foreach (const QVariant &v, m_categories) {
            QString cat = v.toString();
            if (cat == propName) {
                index = i;
                break;
            }
            ++i;
        }
        if (index >= 0) {
            beginRemoveRows(QModelIndex(), index, index);
            m_results.remove(index);
            endRemoveRows();
        }
    }
    emit countChanged();
}

void MetadataCloudModel::finishedListing()
{
    setStatus(Idle);
}



QVariant MetadataCloudModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.column() != 0 ||
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
