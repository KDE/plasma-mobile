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

#include "metadatamodel.h"

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


MetadataModel::MetadataModel(QObject *parent)
    : AbstractMetadataModel(parent),
      m_queryClient(0)
{
    m_queryTimer = new QTimer(this);
    m_queryTimer->setSingleShot(true);
    connect(m_queryTimer, SIGNAL(timeout()),
            this, SLOT(doQuery()));

    m_newEntriesTimer = new QTimer(this);
    m_newEntriesTimer->setSingleShot(true);
    connect(m_newEntriesTimer, SIGNAL(timeout()),
            this, SLOT(newEntriesDelayed()));

    QHash<int, QByteArray> roleNames;
    roleNames[Label] = "label";
    roleNames[Description] = "description";
    roleNames[Types] = "types";
    roleNames[ClassName] = "className";
    roleNames[GenericClassName] = "genericClassName";
    roleNames[HasSymbol] = "hasSymbol";
    roleNames[Icon] = "icon";
    roleNames[IsFile] = "isFile";
    roleNames[Exists] = "exists";
    roleNames[Rating] = "rating";
    roleNames[NumericRating] = "numericRating";
    roleNames[Symbols] = "symbols";
    roleNames[ResourceUri] = "resourceUri";
    roleNames[ResourceType] = "resourceType";
    roleNames[Url] = "url";
    roleNames[Topics] = "topics";
    roleNames[TopicsNames] = "topicsNames";
    roleNames[Tags] = "tags";
    roleNames[TagsNanes] = "tagsNanes";
    setRoleNames(roleNames);
}

MetadataModel::~MetadataModel()
{
}


void MetadataModel::setQuery(const Nepomuk::Query::Query &query)
{
    m_queryTimer->stop();
    m_query = query;

    if (Nepomuk::Query::QueryServiceClient::serviceAvailable()) {
        doQuery();
    }
}

Nepomuk::Query::Query MetadataModel::query() const
{
    return m_query;
}

void MetadataModel::setQueryString(const QString &query)
{
    if (query == m_queryString) {
        return;
    }

    m_queryString = query;
    m_queryTimer->start(0);
    emit queryStringChanged();
}

QString MetadataModel::queryString() const
{
    return m_queryString;
}



void MetadataModel::setSortBy(const QVariantList &sortBy)
{
    QStringList stringList = variantToStringList(sortBy);

    if (m_sortBy == stringList) {
        return;
    }

    m_sortBy = stringList;
    m_queryTimer->start(0);
    emit sortByChanged();
}

QVariantList MetadataModel::sortBy() const
{
    return stringToVariantList(m_sortBy);
}

void MetadataModel::setSortOrder(Qt::SortOrder sortOrder)
{
    if (m_sortOrder == sortOrder) {
        return;
    }

    m_sortOrder = sortOrder;
    m_queryTimer->start(0);
    emit sortOrderChanged();
}

Qt::SortOrder MetadataModel::sortOrder() const
{
    return m_sortOrder;
}




void MetadataModel::doQuery()
{
    m_query = Nepomuk::Query::Query();
    m_query.setQueryFlags(Nepomuk::Query::Query::WithoutFullTextExcerpt);
    Nepomuk::Query::AndTerm rootTerm;

    if (!m_queryString.isEmpty()) {
        rootTerm.addSubTerm(Nepomuk::Query::QueryParser::parseQuery(m_queryString).term());
    }

    if (!resourceType().isEmpty()) {
        //FIXME: more elegant
        QString type = resourceType().replace(":", "#");
        //FIXME: query by mimetype
        if (resourceType() == "nfo:Video") {
            // Strigi doesn't index videos it seems
            rootTerm.addSubTerm(Nepomuk::Query::ComparisonTerm(Nepomuk::Vocabulary::NIE::mimeType(), Nepomuk::Query::LiteralTerm("video")));
        } else if (resourceType() == "OpenDocumentTextDocument") {
            rootTerm.addSubTerm(Nepomuk::Query::ComparisonTerm(Nepomuk::Vocabulary::NIE::mimeType(), Nepomuk::Query::LiteralTerm("vnd.oasis.opendocument.text")));
        } else {
            rootTerm.addSubTerm(Nepomuk::Query::ResourceTypeTerm(propertyUrl(resourceType())));
        }
    }


    if (!activityId().isEmpty()) {
        kDebug() << "Asking for resources of activity" << activityId();
        Nepomuk::Resource acRes(activityId(), Nepomuk::Vocabulary::KEXT::Activity());
        Nepomuk::Query::ComparisonTerm term(Soprano::Vocabulary::NAO::isRelated(), Nepomuk::Query::ResourceTerm(acRes));
        term.setInverted(true);
        rootTerm.addSubTerm(term);
    }

    foreach (const QString &tag, tagStrings()) {
        Nepomuk::Query::ComparisonTerm term( Soprano::Vocabulary::NAO::hasTag(),
                                    Nepomuk::Query::LiteralTerm(tag));
        rootTerm.addSubTerm(term);
    }

    if (startDate().isValid() || endDate().isValid()) {
        rootTerm.addSubTerm(Nepomuk::Query::dateRangeQuery(startDate(), endDate()).term());
    }

    if (minimumRating() > 0) {
        const Nepomuk::Query::LiteralTerm ratingTerm(minimumRating());
        Nepomuk::Query::ComparisonTerm term = Nepomuk::Types::Property(propertyUrl("nao:numericRating")) > ratingTerm;
        rootTerm.addSubTerm(term);
    }

    if (maximumRating() > 0) {
        const Nepomuk::Query::LiteralTerm ratingTerm(maximumRating());
        Nepomuk::Query::ComparisonTerm term = Nepomuk::Types::Property(propertyUrl("nao:numericRating")) < ratingTerm;
        rootTerm.addSubTerm(term);
    }


    int weight = m_sortBy.length() + 1;
    foreach (const QString &sortProperty, m_sortBy) {
        Nepomuk::Query::ComparisonTerm sortTerm(propertyUrl(sortProperty), Nepomuk::Query::Term());
        sortTerm.setSortWeight(weight, m_sortOrder);
        rootTerm.addSubTerm(sortTerm);
        --weight;
    }

    m_query.setTerm(rootTerm);
    kDebug()<<"Sparql query:"<<m_query.toSparqlQuery();


    beginResetModel();
    m_resources.clear();
    m_uriToResourceIndex.clear();
    endResetModel();
    emit countChanged();

    delete m_queryClient;
    m_queryClient = new Nepomuk::Query::QueryServiceClient(this);

    connect(m_queryClient, SIGNAL(newEntries(const QList<Nepomuk::Query::Result> &)),
            this, SLOT(newEntries(const QList<Nepomuk::Query::Result> &)));
    connect(m_queryClient, SIGNAL(entriesRemoved(const QList<QUrl> &)),
            this, SLOT(entriesRemoved(const QList<QUrl> &)));

    /*FIXME: safe without limit?
    if (limit > RESULT_LIMIT || limit <= 0) {
        m_query.setLimit(RESULT_LIMIT);
    }
    */

    m_queryClient->query(m_query);
}

void MetadataModel::newEntries(const QList< Nepomuk::Query::Result > &entries)
{

    foreach (Nepomuk::Query::Result res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //kDebug() << "Result label:" << res.genericLabel();
        m_resourcesToInsert << res.resource();
    }

    if (!m_newEntriesTimer->isActive()) {
        m_newEntriesTimer->start(200);
    }
}

void MetadataModel::newEntriesDelayed()
{
    beginInsertRows(QModelIndex(), m_resources.count(), m_resources.count()+m_resourcesToInsert.count()-1);


    foreach (Nepomuk::Resource res, m_resourcesToInsert) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //kDebug() << "Result label:" << res.genericLabel();
        m_uriToResourceIndex[res.resourceUri()] = m_resources.count();
        m_resources << res;
    }

    m_resourcesToInsert.clear();

    endInsertRows();
    emit countChanged();
}

void MetadataModel::entriesRemoved(const QList<QUrl> &urls)
{
    int prevIndex = -100;
    //pack all the stuff to remove in groups, to emit the least possible signals
    //this assumes urls are in the same order they arrived ion the results
    //it's a map because we want to remove values from the vector in inverted order to keep indexes valid trough the remove loop
    QMap<int, int> toRemove;
    foreach (const QUrl &url, urls) {
        const int index = m_uriToResourceIndex.value(url);
        if (index == prevIndex + 1) {
            toRemove[prevIndex]++;
        } else {
            toRemove[index] = 1;
        }
        prevIndex = index;
    }

    QMap<int, int>::const_iterator i = toRemove.constEnd();

    while (i != toRemove.constBegin()) {
        --i;
        beginRemoveRows(QModelIndex(), i.key(), i.key()+i.value());
        m_resources.remove(i.key(), i.value());
        endRemoveRows();
    }

    //another loop, we don't depend to m_uriToResourceIndex in data(), but we take this doublesafety
    foreach (const QUrl &url, urls) {
        m_uriToResourceIndex.remove(url);
    }

    //FIXME: this loop makes all the optimizations useless, get rid either of it or the optimizations
    for (int i = 0; i < m_resources.count(); ++i) {
        m_uriToResourceIndex[m_resources[i].resourceUri()] = i;
    }

    emit countChanged();
}



QVariant MetadataModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.column() > 0 ||
        index.row() < 0 || index.row() >= m_resources.count()){
        return QVariant();
    }

    const Nepomuk::Resource &resource = m_resources[index.row()];

    switch (role) {
    case Label:
        return resource.genericLabel();
    case Description:
        return resource.genericDescription();
    case Types: {
        QStringList types;
        foreach (const QUrl &u, resource.types()) {
            types << u.toString();
        }
        return types;
    }
    case ClassName:
        return resource.className();
    case GenericClassName: {
        //FIXME: a more elegant way is needed
        QString genericClassName = resource.className();
        Nepomuk::Types::Class resClass(resource.resourceType());
        foreach (Nepomuk::Types::Class parentClass, resClass.parentClasses()) {
            if (parentClass.label() == "Document" ||
                parentClass.label() == "Audio" ||
                parentClass.label() == "Video" ||
                parentClass.label() == "Image" ||
                parentClass.label() == "Contact") {
                genericClassName = parentClass.label();
                break;
            //two cases where the class is 2 levels behind the level of generalization we want
            } else if (parentClass.label() == "RasterImage") {
                genericClassName = "Image";
            } else if (parentClass.label() == "TextDocument") {
                genericClassName = "Document";
            }
        }
        return genericClassName;
    }
    case HasSymbol:
    case Icon: {
        QString icon = resource.genericIcon();
        if (icon.isEmpty() && resource.isFile()) {
            KUrl url = resource.toFile().url();
            if (!url.isEmpty()) {
                icon = KMimeType::iconNameForUrl(url);
            }
        }
        if (icon.isEmpty()) {
            // use resource types to find a suitable icon.
            //TODO
            icon = retrieveIconName(QStringList(resource.className()));
            //kDebug() << "symbol" << icon;
        }
        if (icon.split(",").count() > 1) {
            kDebug() << "More than one icon!" << icon;
            icon = icon.split(",").last();
        }
        return icon;
    }
    case IsFile:
        return resource.isFile();
    case Exists:
        return resource.exists();
    case Rating:
        return resource.rating();
    case NumericRating:
        return resource.property(QUrl("http://www.semanticdesktop.org/ontologies/2007/08/15/nao#numericRating")).toString();
    case Symbols:
        return resource.symbols();
    case ResourceUri:
        return resource.resourceUri();
    case ResourceType:
        return resource.resourceType();
    case Url: {
        if (resource.isFile() && resource.toFile().url().isLocalFile()) {
            return resource.toFile().url().prettyUrl();
        } else {
            return resource.property(QUrl("http://www.semanticdesktop.org/ontologies/2007/01/19/nie#url")).toString();
        }
    }
    case Topics: {
        QStringList topics;
        foreach (const Nepomuk::Resource &u, resource.topics()) {
            topics << u.resourceUri().toString();
        }
        return topics;
    }
    case TopicsNames: {
        QStringList topicNames;
        foreach (const Nepomuk::Resource &u, resource.topics()) {
            topicNames << u.genericLabel();
        }
        return topicNames;
    }
    case Tags: {
        QStringList tags;
        foreach (const Nepomuk::Tag &tag, resource.tags()) {
            tags << tag.resourceUri().toString();
        }
        return tags;
    }
    case TagsNanes: {
        QStringList tagNames;
        foreach (const Nepomuk::Tag &tag, resource.tags()) {
            tagNames << tag.genericLabel();
        }
        return tagNames;
    }
    default:
        return QVariant();
    }
}

#include "metadatamodel.moc"
