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


#include "timelinequeryprovider.h"

#include <KDebug>
#include <KCalendarSystem>

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

TimelineQueryProvider::TimelineQueryProvider(QObject* parent): BasicQueryProvider(parent)
{

}

TimelineQueryProvider::~TimelineQueryProvider()
{

}

void TimelineQueryProvider::setLevel(TimelineQueryProvider::Level level)
{
    if (m_level == level) {
        return;
    }

    m_level = level;
    requestRefresh();
    emit levelChanged();
}

TimelineQueryProvider::Level TimelineQueryProvider::level() const
{
    return m_level;
}

QString TimelineQueryProvider::description() const
{

    //TODO: manage cases where start and enddate cover more than one year/month
    switch (m_level) {
    case Year:
        return i18n("All years");
    case Month:
        return KGlobal::locale()->calendar()->yearString(startDate(), KCalendarSystem::LongFormat);
    case Day:
    default:
        return i18nc("Month and year, such as March 2007", "%1 %2", KGlobal::locale()->calendar()->monthName(startDate(), KCalendarSystem::LongName), KGlobal::locale()->calendar()->yearString(startDate(), KCalendarSystem::LongFormat));
    }
}


void TimelineQueryProvider::doQuery()
{
    QDeclarativePropertyMap *parameters = qobject_cast<QDeclarativePropertyMap *>(extraParameters());

    QString monthQuery;
    QString dayQuery;

    if (m_level >= Month) {
        monthQuery = "bif:month(?label)";
    } else {
        monthQuery = '0';
    }
    if (m_level >= Day) {
        dayQuery = "bif:dayofmonth(?label)";
    } else {
        dayQuery = '0';
    }

    QString query = QString("select distinct bif:year(?label) as ?year %1 as ?month %2 as ?day count(*) as ?count where { ?r nie:lastModified ?label  ").arg(monthQuery).arg(dayQuery);


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
            query += ". ?r <http://www.semanticdesktop.org/ontologies/2007/01/19/nie#lastModified> ?v2 . FILTER(?v2>\"" + startDate().toString(Qt::ISODate) + "\"^^<http://www.w3.org/2001/XMLSchema#dateTime>) ";
        }
        if (endDate().isValid()) {
            query += ". ?r <http://www.semanticdesktop.org/ontologies/2007/01/19/nie#lastModified> ?v2 . FILTER(?v2<\"" + endDate().toString(Qt::ISODate) + "\"^^<http://www.w3.org/2001/XMLSchema#dateTime>) ";
        }
    }

    if (minimumRating() > 0) {
        query += " . ?r nao:numericRating ?rating filter (?rating >=" + QString::number(minimumRating()) + ") ";
    }

    if (maximumRating() > 0) {
        query += " . ?r nao:numericRating ?rating filter (?rating <=" + QString::number(maximumRating()) + ") ";
    }

    //user visibility is too slow
    //query +=  " . FILTER(bif:exists((select (1) where { ?r a [ <http://www.semanticdesktop.org/ontologies/2007/08/15/nao#userVisible> \"true\"^^<http://www.w3.org/2001/XMLSchema#boolean> ] . }))) }";
    query += "}";

    //Group by construction
    query += " group by bif:year(?label) ";
    if (m_level >= Month) {
        query += " bif:month(?label) ";
    }
    if (m_level >= Day) {
        query += " bif:dayofmonth(?label) ";
    }
    query += " order by ?year ?month ?day ";

    setSparqlQuery(query);
}

#include "timelinequeryprovider.moc"
