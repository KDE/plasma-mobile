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


#include "resourcequeryprovider.h"

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

ResourceQueryProvider::ResourceQueryProvider(QObject* parent): BasicQueryProvider(parent)
{

}

ResourceQueryProvider::~ResourceQueryProvider()
{

}

void ResourceQueryProvider::setQueryString(const QString &query)
{
    if (query == m_queryString || query == "nepomuk") {
        return;
    }

    m_queryString = query;
    requestRefresh();
    emit queryStringChanged();
}

QString ResourceQueryProvider::queryString() const
{
    return m_queryString;
}

void ResourceQueryProvider::setSortBy(const QVariantList &sortBy)
{
    QStringList stringList = variantToStringList(sortBy);

    if (m_sortBy == stringList) {
        return;
    }

    m_sortBy = stringList;
    requestRefresh();
    emit sortByChanged();
}

QVariantList ResourceQueryProvider::sortBy() const
{
    return stringToVariantList(m_sortBy);
}

void ResourceQueryProvider::setSortOrder(Qt::SortOrder sortOrder)
{
    if (m_sortOrder == sortOrder) {
        return;
    }

    m_sortOrder = sortOrder;
    requestRefresh();
    emit sortOrderChanged();
}

Qt::SortOrder ResourceQueryProvider::sortOrder() const
{
    return m_sortOrder;
}

void ResourceQueryProvider::doQuery()
{
    QDeclarativePropertyMap *parameters = qobject_cast<QDeclarativePropertyMap *>(extraParameters());

    //check if really all properties to build the query are null
    if (m_queryString.isEmpty() && resourceType().isEmpty() &&
        mimeTypeStrings().isEmpty() && activityId().isEmpty() &&
        tagStrings().size() == 0 && !startDate().isValid() &&
        !endDate().isValid() && minimumRating() <= 0 &&
        maximumRating() <= 0 && parameters->size() == 0) {
        return;
    }
    Nepomuk2::Query::Query query = Nepomuk2::Query::Query();
    query.setQueryFlags(Nepomuk2::Query::Query::NoResultRestrictions);
    Nepomuk2::Query::AndTerm rootTerm;

    if (!m_queryString.isEmpty()) {
        rootTerm.addSubTerm(Nepomuk2::Query::QueryParser::parseQuery(m_queryString).term());
    }

    if (!resourceType().isEmpty()) {
        QString type = resourceType();

        if (type.startsWith('!')) {
            // negation
            type = type.remove(0, 1);
            rootTerm.addSubTerm(Nepomuk2::Query::NegationTerm::negateTerm(Nepomuk2::Query::ResourceTypeTerm(propertyUrl(type))));
        } else {
            rootTerm.addSubTerm(Nepomuk2::Query::ResourceTypeTerm(propertyUrl(type)));
            /*if (type != "nfo:Bookmark") {
                //FIXME: remove bookmarks if not explicitly asked for
                rootTerm.addSubTerm(Nepomuk2::Query::NegationTerm::negateTerm(Nepomuk2::Query::ResourceTypeTerm(propertyUrl("nfo:Bookmark"))));
            }*/
        }

        if (type == "nfo:Archive") {
            Nepomuk2::Query::ComparisonTerm term(Nepomuk2::Vocabulary::NIE::mimeType(), Nepomuk2::Query::LiteralTerm("application/epub+zip"));
            rootTerm.addSubTerm(Nepomuk2::Query::NegationTerm::negateTerm(term));
        }
    }

    if (!mimeTypeStrings().isEmpty()) {
        Nepomuk2::Query::OrTerm mimeTerm;
        foreach (QString type, mimeTypeStrings()) {
            if (type.isEmpty()) {
                continue;
            }
            bool negation = false;
            if (type.startsWith('!')) {
                type = type.remove(0, 1);
                negation = true;
            }

            Nepomuk2::Query::ComparisonTerm term(Nepomuk2::Vocabulary::NIE::mimeType(), Nepomuk2::Query::LiteralTerm(type), Nepomuk2::Query::ComparisonTerm::Equal);

            if (negation) {
                mimeTerm.addSubTerm(Nepomuk2::Query::NegationTerm::negateTerm(term));
            } else {
                mimeTerm.addSubTerm(term);
            }
        }
        rootTerm.addSubTerm(mimeTerm);
    }


    if (parameters && parameters->size() > 0) {
        foreach (const QString &key, parameters->keys()) {
            QString parameter = parameters->value(key).toString();
            if (parameter.isEmpty()) {
                continue;
            }
            bool negation = false;
            if (parameter.startsWith('!')) {
                parameter = parameter.remove(0, 1);
                negation = true;
            }

            //FIXME: Contains should work, but doesn't match for file names
            // we must prepend and append "*" to the file name for the default Nepomuk match type (Contains) really work.
            Nepomuk2::Query::ComparisonTerm term(propertyUrl(key), Nepomuk2::Query::LiteralTerm(parameter));

            if (negation) {
                rootTerm.addSubTerm(Nepomuk2::Query::NegationTerm::negateTerm(term));
            } else {
                rootTerm.addSubTerm(term);
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
        kDebug() << "Asking for resources of activity" << activityId();
        Nepomuk2::Resource acRes(activity, Nepomuk2::Vocabulary::KAO::Activity());
        Nepomuk2::Query::ComparisonTerm term(Soprano::Vocabulary::NAO::isRelated(), Nepomuk2::Query::ResourceTerm(acRes));
        term.setInverted(true);
        if (negation) {
            rootTerm.addSubTerm(Nepomuk2::Query::NegationTerm::negateTerm(term));
        } else {
            rootTerm.addSubTerm(term);
        }
    }

    foreach (const QString &tag, tagStrings()) {
        QString individualTag = tag;
        bool negation = false;
        if (individualTag.startsWith('!')) {
            individualTag = individualTag.remove(0, 1);
            negation = true;
        }
        Nepomuk2::Query::ComparisonTerm term( Soprano::Vocabulary::NAO::hasTag(),
                                    Nepomuk2::Query::ResourceTerm(Nepomuk2::Tag(individualTag)));
        if (negation) {
            rootTerm.addSubTerm(Nepomuk2::Query::NegationTerm::negateTerm(term));
        } else {
            rootTerm.addSubTerm(term);
        }
    }

    if (startDate().isValid() || endDate().isValid()) {
        rootTerm.addSubTerm(Nepomuk2::Query::dateRangeQuery(startDate(), endDate()).term());
    }

    if (minimumRating() > 0) {
        const Nepomuk2::Query::LiteralTerm ratingTerm(minimumRating());
        Nepomuk2::Query::ComparisonTerm term = Nepomuk2::Types::Property(propertyUrl("nao:numericRating")) > ratingTerm;
        rootTerm.addSubTerm(term);
    }

    if (maximumRating() > 0) {
        const Nepomuk2::Query::LiteralTerm ratingTerm(maximumRating());
        Nepomuk2::Query::ComparisonTerm term = Nepomuk2::Types::Property(propertyUrl("nao:numericRating")) < ratingTerm;
        rootTerm.addSubTerm(term);
    }

    //bind directly some properties, to avoid calling hyper inefficient resource::property
    /*{
        query.addRequestProperty(Nepomuk2::Query::Query::RequestProperty(NIE::url()));
        query.addRequestProperty(Nepomuk2::Query::Query::RequestProperty(NAO::hasSymbol()));
        query.addRequestProperty(Nepomuk2::Query::Query::RequestProperty(NIE::mimeType()));
        query.addRequestProperty(Nepomuk2::Query::Query::RequestProperty(NAO::description()));
        query.addRequestProperty(Nepomuk2::Query::Query::RequestProperty(Xesam::description()));
        query.addRequestProperty(Nepomuk2::Query::Query::RequestProperty(RDFS::comment()));
    }*/

    int weight = m_sortBy.length() + 1;
    foreach (const QString &sortProperty, m_sortBy) {
        if (sortProperty.isEmpty()) {
            continue;
        }
        Nepomuk2::Query::ComparisonTerm sortTerm(propertyUrl(sortProperty), Nepomuk2::Query::Term());
        sortTerm.setSortWeight(weight, m_sortOrder);
        rootTerm.addSubTerm(sortTerm);
        --weight;
    }

    query.setTerm(rootTerm);
    setQuery(query);
}

#include "resourcequeryprovider.moc"
