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


#include "cloudqueryprovider.h"

#include <KDebug>

#include <soprano/vocabulary.h>

#include <Nepomuk2/File>
#include <Nepomuk2/Tag>
#include <Nepomuk2/Variant>

#include <Nepomuk2/Query/AndTerm>
#include <Nepomuk2/Query/OrTerm>
#include <Nepomuk2/Query/NegationTerm>
#include <Nepomuk2/Query/ResourceTerm>
#include <Nepomuk2/Query/ComparisonTerm>
#include <Nepomuk2/Query/LiteralTerm>
#include <Nepomuk2/Query/QueryParser>
#include <Nepomuk2/Query/ResourceTypeTerm>
#include <Nepomuk2/Query/StandardQuery>

CloudQueryProvider::CloudQueryProvider(QObject* parent)
    : BasicQueryProvider(parent)
{
    QHash<int, QByteArray> roleNames;
    roleNames[Label] = "label";
    roleNames[Count] = "count";
    roleNames[TotalCount] = "totalCount";

    setRoleNames(roleNames);
}

CloudQueryProvider::~CloudQueryProvider()
{

}

void CloudQueryProvider::setCloudCategory(QString category)
{
    if (m_cloudCategory == category) {
        return;
    }

    m_cloudCategory = category;
    requestRefresh();
    emit cloudCategoryChanged();
}

QString CloudQueryProvider::cloudCategory() const
{
    return m_cloudCategory;
}

void CloudQueryProvider::doQuery()
{
    QDeclarativePropertyMap *parameters = qobject_cast<QDeclarativePropertyMap *>(extraParameters());

    //check if really all properties to build the query are null
    if (m_cloudCategory.isEmpty()) {
        return;
    }

    QString query;

    query += "select distinct ?label "
          "count(*) as ?count "
        "where {";

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

    if (!mimeTypeStrings().isEmpty()) {
        query += " { ";
        bool first = true;
        foreach (QString type, mimeTypeStrings()) {
            bool negation = false;
            if (!first) {
                query += " UNION ";
            }
            first = false;
            if (type.startsWith('!')) {
                type = type.remove(0, 1);
                negation = true;
            }
            if (negation) {
                query += " { . FILTER(!bif:exists((select (1) where { ?r nie:mimeType \"" + type + "\"^^<http://www.w3.org/2001/XMLSchema#string> . }))) } ";
            } else {
                query += " { ?r nie:mimeType \"" + type + "\"^^<http://www.w3.org/2001/XMLSchema#string> . } ";
            }
        }
        query += " } ";
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
        Nepomuk2::Resource acRes(activity, Nepomuk2::Vocabulary::KAO::Activity());

        if (negation) {
            query +=  ". FILTER(!bif:exists((select (1) where { <" + acRes.uri().toString() + "> <http://www.semanticdesktop.org/ontologies/2007/08/15/nao#isRelated> ?r . }))) ";
        } else {
            query +=  " . <" + acRes.uri().toString() + "> nao:isRelated ?r ";
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
    query += " . ?r nie:url ?h . ";

    //User visibility filter doesn't seem to have an acceptable speed
    //query +=  " . FILTER(bif:exists((select (1) where { ?r a [ <http://www.semanticdesktop.org/ontologies/2007/08/15/nao#userVisible> \"true\"^^<http://www.w3.org/2001/XMLSchema#boolean> ] . }))) } group by ?label order by ?label";

    query +=  " } group by ?label order by ?label";

    setSparqlQuery(query);
}

QVariant CloudQueryProvider::formatData(const Nepomuk2::Query::Result &row, const QPersistentModelIndex &index, int role) const
{
    Q_UNUSED(index)

    switch(role) {
    case Label: {
        const QVariant rawLabel = row.additionalBinding("label").variant();

        if (rawLabel.canConvert<Nepomuk2::Resource>()) {
            return rawLabel.value<Nepomuk2::Resource>().type().toString().section( QRegExp( "[#:]" ), -1 );
        } else if (!rawLabel.value<QUrl>().scheme().isEmpty()) {
            const QUrl url = rawLabel.value<QUrl>();
            if (url.scheme() == "nepomuk") {
                return Nepomuk2::Resource(url).genericLabel();
            } else {
                return url.path().split("/").last() + ":" + url.fragment();
            }
        } else {
            return rawLabel;
        }
    }
    case Count:
        return row.additionalBinding("count").variant();
    case TotalCount:
        return row.additionalBinding("totalCount").variant();
    default:
        return QVariant();
    }
}

#include "cloudqueryprovider.moc"
