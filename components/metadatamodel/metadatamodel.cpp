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
#include "resourcewatcher.h"

#include <cmath>

#include <QDBusConnection>
#include <QDBusServiceWatcher>
#include <QTimer>

#include <KDebug>
#include <KIcon>
#include <KImageCache>
#include <KMimeType>
#include <KService>
#include <KIO/PreviewJob>

#include <soprano/vocabulary.h>

#include <Nepomuk/File>
#include <Nepomuk/Tag>
#include <Nepomuk/Variant>

#include <Nepomuk/Query/AndTerm>
#include <Nepomuk/Query/NegationTerm>
#include <Nepomuk/Query/ResourceTerm>
#include <Nepomuk/Query/ComparisonTerm>
#include <Nepomuk/Query/LiteralTerm>
#include <Nepomuk/Query/QueryParser>
#include <Nepomuk/Query/ResourceTypeTerm>
#include <Nepomuk/Query/StandardQuery>

#include "kao.h"

using namespace Nepomuk::Vocabulary;
using namespace Soprano::Vocabulary;

MetadataModel::MetadataModel(QObject *parent)
    : AbstractMetadataModel(parent),
      m_runningClients(0),
      m_countQueryClient(0),
      m_limit(0),
      m_pageSize(30),
      m_scoreResources(false),
      m_thumbnailSize(180, 120),
      m_thumbnailerPlugins(new QStringList(KIO::PreviewJob::availablePlugins()))
{
    m_newEntriesTimer = new QTimer(this);
    m_newEntriesTimer->setSingleShot(true);
    connect(m_newEntriesTimer, SIGNAL(timeout()),
            this, SLOT(newEntriesDelayed()));

    m_previewTimer = new QTimer(this);
    m_previewTimer->setSingleShot(true);
    connect(m_previewTimer, SIGNAL(timeout()),
            this, SLOT(delayedPreview()));

    //using the same cache of the engine, they index both by url
    m_imageCache = new KImageCache("plasma_engine_preview", 10485760);

    m_watcher = new Nepomuk::ResourceWatcher(this);

    m_watcher->addProperty(NAO::numericRating());
    connect(m_watcher, SIGNAL(propertyAdded(Nepomuk::Resource, Nepomuk::Types::Property, QVariant)),
            this, SLOT(propertyChanged(Nepomuk::Resource, Nepomuk::Types::Property, QVariant)));


    QHash<int, QByteArray> roleNames;
    roleNames[Qt::DisplayRole] = "display";
    roleNames[Qt::DecorationRole] = "decoration";
    roleNames[Label] = "label";
    roleNames[Description] = "description";
    roleNames[Types] = "types";
    roleNames[ClassName] = "className";
    roleNames[GenericClassName] = "genericClassName";
    roleNames[HasSymbol] = "hasSymbol";
    roleNames[Icon] = "icon";
    roleNames[Thumbnail] = "thumbnail";
    roleNames[IsFile] = "isFile";
    roleNames[Exists] = "exists";
    roleNames[Rating] = "rating";
    roleNames[NumericRating] = "numericRating";
    roleNames[Symbols] = "symbols";
    roleNames[ResourceUri] = "resourceUri";
    roleNames[ResourceType] = "resourceType";
    roleNames[MimeType] = "mimeType";
    roleNames[Url] = "url";
    roleNames[Topics] = "topics";
    roleNames[TopicsNames] = "topicsNames";
    roleNames[Tags] = "tags";
    roleNames[TagsNames] = "tagsNames";
    setRoleNames(roleNames);
}

MetadataModel::~MetadataModel()
{
    delete m_imageCache;
}


void MetadataModel::setQuery(const Nepomuk::Query::Query &query)
{
    m_query = query;

    if (Nepomuk::Query::QueryServiceClient::serviceAvailable()) {
        askRefresh();
    }
}

Nepomuk::Query::Query MetadataModel::query() const
{
    return m_query;
}

void MetadataModel::setQueryString(const QString &query)
{
    if (query == m_queryString || query == "nepomuk") {
        return;
    }

    m_queryString = query;
    askRefresh();
    emit queryStringChanged();
}

QString MetadataModel::queryString() const
{
    return m_queryString;
}

void MetadataModel::setLimit(int limit)
{
    if (limit == m_limit) {
        return;
    }

    m_limit = limit;
    askRefresh();
    emit limitChanged();
}

int MetadataModel::limit() const
{
    return m_limit;
}

void MetadataModel::setScoreResources(bool score)
{
    if (m_scoreResources == score) {
        return;
    }

    m_scoreResources = score;
    askRefresh();
    emit scoreResourcesChanged();
}

bool MetadataModel::scoreResources() const
{
    return m_scoreResources;
}

void MetadataModel::setLazyLoading(bool lazy)
{
    //lazy loading depends from the page zise, that is not directly user controllable
    if (lazy == (m_pageSize > 0)) {
        return;
    }

    //TODO: a way to control this? maybe from the available memory?
    m_pageSize = lazy ? 30 : -1;
    askRefresh();
    emit lazyLoadingChanged();
}

bool MetadataModel::lazyLoading() const
{
    return (m_pageSize > 0);
}



void MetadataModel::setSortBy(const QVariantList &sortBy)
{
    QStringList stringList = variantToStringList(sortBy);

    if (m_sortBy == stringList) {
        return;
    }

    m_sortBy = stringList;
    askRefresh();
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
    askRefresh();
    emit sortOrderChanged();
}

Qt::SortOrder MetadataModel::sortOrder() const
{
    return m_sortOrder;
}


int MetadataModel::find(const QString &resourceUri)
{
    int index = -1;
    int i = 0;
    Nepomuk::Resource resToFind = Nepomuk::Resource::fromResourceUri(resourceUri);

    foreach (const Nepomuk::Resource &res, m_resources) {
        if (res == resToFind) {
            index = i;
            break;
        }
        ++i;
    }

    return index;
}



void MetadataModel::doQuery()
{
    QDeclarativePropertyMap *parameters = qobject_cast<QDeclarativePropertyMap *>(extraParameters());

    //check if really all properties to build the query are null
    if (m_queryString.isEmpty() && resourceType().isEmpty() &&
        mimeType().isEmpty() && activityId().isEmpty() &&
        tagStrings().size() == 0 && !startDate().isValid() &&
        !endDate().isValid() && minimumRating() <= 0 &&
        maximumRating() <= 0 && parameters->size() == 0) {
        return;
    }
    setStatus(Waiting);
    m_query = Nepomuk::Query::Query();
    m_query.setQueryFlags(Nepomuk::Query::Query::WithoutFullTextExcerpt);
    Nepomuk::Query::AndTerm rootTerm;

    if (!m_queryString.isEmpty()) {
        rootTerm.addSubTerm(Nepomuk::Query::QueryParser::parseQuery(m_queryString).term());
    }

    if (!resourceType().isEmpty()) {
        //FIXME: more elegant
        QString type = resourceType();
        bool negation = false;
        if (type.startsWith("!")) {
            type = type.remove(0, 1);
            negation = true;
        }

        if (negation) {
            rootTerm.addSubTerm(Nepomuk::Query::NegationTerm::negateTerm(Nepomuk::Query::ResourceTypeTerm(propertyUrl(type))));
        } else {
            rootTerm.addSubTerm(Nepomuk::Query::ResourceTypeTerm(propertyUrl(type)));
            if (type != "nfo:Bookmark") {
                //FIXME: remove bookmarks if not explicitly asked for
                rootTerm.addSubTerm(Nepomuk::Query::NegationTerm::negateTerm(Nepomuk::Query::ResourceTypeTerm(propertyUrl("nfo:Bookmark"))));
            }
        }
    }

    if (!mimeType().isEmpty()) {
        QString type = mimeType();
        bool negation = false;
        if (type.startsWith("!")) {
            type = type.remove(0, 1);
            negation = true;
        }

        Nepomuk::Query::ComparisonTerm term(Nepomuk::Vocabulary::NIE::mimeType(), Nepomuk::Query::LiteralTerm(type));

        if (negation) {
            rootTerm.addSubTerm(Nepomuk::Query::NegationTerm::negateTerm(term));
        } else {
            rootTerm.addSubTerm(term);
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

            //FIXME: Contains should work, but doesn't match for file names
            Nepomuk::Query::ComparisonTerm term(propertyUrl(key), Nepomuk::Query::LiteralTerm(parameter));
            if (negation) {
                rootTerm.addSubTerm(Nepomuk::Query::NegationTerm::negateTerm(term));
            } else {
                rootTerm.addSubTerm(term);
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
        kDebug() << "Asking for resources of activity" << activityId();
        Nepomuk::Resource acRes(activity, Nepomuk::Vocabulary::KAO::Activity());
        Nepomuk::Query::ComparisonTerm term(Soprano::Vocabulary::NAO::isRelated(), Nepomuk::Query::ResourceTerm(acRes));
        term.setInverted(true);
        if (negation) {
            rootTerm.addSubTerm(Nepomuk::Query::NegationTerm::negateTerm(term));
        } else {
            rootTerm.addSubTerm(term);
        }
    }

    foreach (const QString &tag, tagStrings()) {
        QString individualTag = tag;
        bool negation = false;
        if (individualTag.startsWith("!")) {
            individualTag = individualTag.remove(0, 1);
            negation = true;
        }
        Nepomuk::Query::ComparisonTerm term( Soprano::Vocabulary::NAO::hasTag(),
                                    Nepomuk::Query::ResourceTerm(Nepomuk::Tag(individualTag)));
        if (negation) {
            rootTerm.addSubTerm(Nepomuk::Query::NegationTerm::negateTerm(term));
        } else {
            rootTerm.addSubTerm(term);
        }
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

    if (m_scoreResources) {
        QString activity = activityId();
        if (activity.startsWith("!")) {
            activity = activity.remove(0, 1);
        }

        Nepomuk::Query::ComparisonTerm term = Nepomuk::Query::ComparisonTerm(propertyUrl("kao:targettedResource"), Nepomuk::Query::Term());
        term.setVariableName("c");
        term.setInverted(true);

        Nepomuk::Query::AndTerm andTerm = Nepomuk::Query::AndTerm();
        Nepomuk::Query::ResourceTypeTerm typeTerm(KAO::ResourceScoreCache());
        andTerm.addSubTerm(typeTerm);
        if (!activity.isEmpty()) {
            Nepomuk::Query::ComparisonTerm usedActivityTerm(propertyUrl("kao:usedActivity"),
                                        Nepomuk::Query::ResourceTerm(Nepomuk::Resource(activity, Nepomuk::Vocabulary::KAO::Activity()))
                                                           );
            andTerm.addSubTerm(usedActivityTerm);
        }
        Nepomuk::Query::ComparisonTerm cachedScoreTerm(propertyUrl("kao:cachedScore"),
                                        Nepomuk::Query::Term());
        cachedScoreTerm.setVariableName("score");
        cachedScoreTerm.setSortWeight(1, Qt::DescendingOrder);
        andTerm.addSubTerm(cachedScoreTerm);

        term.setSubTerm(andTerm);
        rootTerm.addSubTerm(term);
    }

    //bind directly some properties, to avoid calling hyper inefficient resource::property
    {
        m_query.addRequestProperty(Nepomuk::Query::Query::RequestProperty(NIE::url()));
        m_query.addRequestProperty(Nepomuk::Query::Query::RequestProperty(NAO::hasSymbol()));
        m_query.addRequestProperty(Nepomuk::Query::Query::RequestProperty(NIE::mimeType()));
        m_query.addRequestProperty(Nepomuk::Query::Query::RequestProperty(NAO::description()));
        m_query.addRequestProperty(Nepomuk::Query::Query::RequestProperty(Xesam::description()));
        m_query.addRequestProperty(Nepomuk::Query::Query::RequestProperty(RDFS::comment()));
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

    delete m_countQueryClient;
    //qDeleteAll is broken in 4.8
    foreach (Nepomuk::Query::QueryServiceClient *client, m_queryClients) {
        delete client;
    }
    m_queryClients.clear();
    m_pagesForClient.clear();
    m_validIndexForPage.clear();
    m_queryClientsHistory.clear();
    m_cachedResources.clear();
    m_runningClients = 0;
    m_countQueryClient = new Nepomuk::Query::QueryServiceClient(this);

    connect(m_countQueryClient, SIGNAL(newEntries(const QList<Nepomuk::Query::Result> &)),
            this, SLOT(countQueryResult(const QList<Nepomuk::Query::Result> &)));

    if (m_limit > 0) {
        m_query.setLimit(m_limit);
    }

    m_countQueryClient->sparqlQuery(m_query.toSparqlQuery(Nepomuk::Query::Query::CreateCountQuery));

    //if page size is invalid, fetch all
    if (m_pageSize < 1) {
        fetchResultsPage(0);
    }
}

void MetadataModel::fetchResultsPage(int page)
{
    Nepomuk::Query::QueryServiceClient *client = new Nepomuk::Query::QueryServiceClient(this);

    m_queryClients[page] = client;
    m_pagesForClient[client] = page;
    m_validIndexForPage[page] = 0;

    Nepomuk::Query::Query pageQuery(m_query);
    if (m_pageSize > 0) {
        pageQuery.setOffset(m_pageSize*page);
        pageQuery.setLimit(m_pageSize);
    }

    client->query(pageQuery);

    connect(client, SIGNAL(newEntries(const QList<Nepomuk::Query::Result> &)),
            this, SLOT(newEntries(const QList<Nepomuk::Query::Result> &)));
    connect(client, SIGNAL(entriesRemoved(const QList<QUrl> &)),
            this, SLOT(entriesRemoved(const QList<QUrl> &)));
    connect(client, SIGNAL(finishedListing()), this, SLOT(finishedListing()));

    m_queryClientsHistory << client;
    ++m_runningClients;
}

void MetadataModel::countQueryResult(const QList< Nepomuk::Query::Result > &entries)
{
    setStatus(Running);
    //this should be always 1
    foreach (Nepomuk::Query::Result res, entries) {
        int count = res.additionalBinding(QLatin1String("cnt")).variant().toInt();

        if (count < m_resources.size()) {
            beginRemoveRows(QModelIndex(), count-1, m_resources.size()-1);
            m_resources.resize(count);
            endRemoveRows();
        } else if (count > m_resources.size()) {
            beginInsertRows(QModelIndex(), m_resources.size(), count-1);
            m_resources.resize(count);
            endInsertRows();
        }
    }
}

void MetadataModel::newEntries(const QList< Nepomuk::Query::Result > &entries)
{
    setStatus(Running);
    const int page = m_pagesForClient.value(qobject_cast<Nepomuk::Query::QueryServiceClient *>(sender()));

    foreach (Nepomuk::Query::Result res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //kDebug() << "Result label:" << res.genericLabel();
        Nepomuk::Resource resource = res.resource();
        if (res.requestProperties().value(propertyUrl("nie:url")).toString().isEmpty()) {
            continue;
        }
        m_resourcesToInsert[page] << resource;

        //pre-popuplating of the cache to avoid accessing properties directly
        //label is a bit too complex to take from query
        m_cachedResources[resource][Label] = resource.genericLabel();

        QString description = res.requestProperties().value(NAO::description()).toString();
        if (description.isEmpty()) {
            description = res.requestProperties().value(Xesam::description()).toString();
        }
        if (description.isEmpty()) {
            description = res.requestProperties().value(RDFS::comment()).toString();
        }
        if (!description.isEmpty()) {
            m_cachedResources[resource][Description] = description;
        }

        m_cachedResources[resource][Url] = res.requestProperties().value(propertyUrl("nie:url")).toString();

        QStringList types;
        foreach (const QUrl &u, resource.types()) {
            types << u.toString();
        }
        m_cachedResources[resource][Types] = types;

        Soprano::Node symbol = res.requestProperties().value(NAO::hasSymbol());
        if (!symbol.toString().isEmpty()) {
            m_cachedResources[resource][Icon] = symbol.toString();
        } else {
            m_cachedResources[resource][Icon] = KMimeType::iconNameForUrl(m_cachedResources[resource][Url].toString());
        }

        //those seems to not be possible avoiding to access the resource
        m_cachedResources[resource][ClassName] = resource.className();
        m_cachedResources[resource][ResourceType] = resource.resourceType();
        m_cachedResources[resource][IsFile] = resource.isFile();
        m_cachedResources[resource][HasSymbol] = res.requestProperties().value(NAO::hasSymbol()).toString();
        m_cachedResources[resource][MimeType] = res.requestProperties().value(NIE::mimeType()).toString();

        //FIXME: The most complicated of all, this should really be simplified
        {
            //FIXME: a more elegant way is needed
            QString genericClassName = m_cachedResources.value(resource).value(ClassName).toString();
            //FIXME: most bookmarks are Document too, so Bookmark wins
            if (m_cachedResources.value(resource).value(Label).value<QList<QUrl> >().contains(NFO::Bookmark())) {
                m_cachedResources[resource][GenericClassName] = "Bookmark";

            } else {
                Nepomuk::Types::Class resClass(resource.resourceType());
                foreach (Nepomuk::Types::Class parentClass, resClass.parentClasses()) {
                    const QString label = parentClass.label();
                    if (label == "Document" ||
                        label == "Audio" ||
                        label == "Video" ||
                        label == "Image" ||
                        label == "Contact") {
                        genericClassName = label;
                        break;
                    //two cases where the class is 2 levels behind the level of generalization we want
                    } else if (parentClass.label() == "RasterImage") {
                        genericClassName = "Image";
                    } else if (parentClass.label() == "TextDocument") {
                        genericClassName = "Document";
                    }
                }
                m_cachedResources[resource][GenericClassName] = genericClassName;
            }
        }
    }

    if (!m_newEntriesTimer->isActive() && !m_resourcesToInsert[page].isEmpty()) {
        m_newEntriesTimer->start(200);
    }
}

void MetadataModel::newEntriesDelayed()
{
    if (m_resourcesToInsert.isEmpty()) {
        return;
    }

    m_elapsedTime.start();
    QHash<int, QList<Nepomuk::Resource> >::const_iterator i;
    for (i = m_resourcesToInsert.constBegin(); i != m_resourcesToInsert.constEnd(); ++i) {
        const QList<Nepomuk::Resource> resourcesToInsert = i.value();

        m_watcher->stop();

        int pageStart = 0;
        if (m_pageSize > 0) {
            pageStart = i.key() * m_pageSize;
        }
        int startOffset = m_validIndexForPage.value(i.key());
        int offset = startOffset;

        //if new result arrive on an already running query, they may arrive before countQueryResult
        if (m_resources.size() < pageStart + startOffset + 1) {
            beginInsertRows(QModelIndex(), m_resources.size(), pageStart + startOffset);
            m_resources.resize(pageStart + startOffset + 1);
            endInsertRows();
        }
        //this happens only when m_validIndexForPage has been invalidate by row removal
        if (!m_validIndexForPage.contains(i.key()) && m_resources[pageStart + startOffset].isValid()) {
            while (startOffset < m_resources.size() && m_resources[pageStart + startOffset].isValid()) {
                ++startOffset;
                ++offset;
            }
        }

        foreach (Nepomuk::Resource res, resourcesToInsert) {
            //kDebug() << "Result!!!" << res.genericLabel() << res.type();
            //kDebug() << "Page:" << i.key() << "Index:"<< pageStart + offset;

            m_uriToResourceIndex[res.resourceUri()] = pageStart + offset;
            //there can be new results before the count query gets updated
            if (pageStart + offset < m_resources.size()) {
                m_resources[pageStart + offset] = res;
                m_watcher->addResource(res);
                ++offset;
            } else {
                beginInsertRows(QModelIndex(), m_resources.size(), pageStart + offset);
                m_resources.resize(pageStart + offset + 1);
                m_resources[pageStart + offset] = res;
                m_watcher->addResource(res);
                ++offset;
                endInsertRows();
            }
        }

        m_validIndexForPage[i.key()] = offset;

        m_watcher->start();
        emit dataChanged(createIndex(pageStart + startOffset, 0),
                         createIndex(pageStart + startOffset + resourcesToInsert.count()-1, 0));
    }
    kDebug() << "Elapsed time populating the model" << m_elapsedTime.elapsed();
    m_resourcesToInsert.clear();
}

void MetadataModel::propertyChanged(Nepomuk::Resource res, Nepomuk::Types::Property prop, QVariant val)
{
    Q_UNUSED(prop)
    Q_UNUSED(val)

    const int index = m_uriToResourceIndex.value(res.resourceUri());
    if (index >= 0) {
        emit dataChanged(createIndex(index, 0, 0), createIndex(index, 0, 0));
    }
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

    //all the page indexes may be invalid now
    m_validIndexForPage.clear();

    QMap<int, int>::const_iterator i = toRemove.constEnd();

    while (i != toRemove.constBegin()) {
        --i;
        beginRemoveRows(QModelIndex(), i.key(), i.key()+i.value()-1);
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

void MetadataModel::finishedListing()
{
    --m_runningClients;

    if (m_runningClients <= 0) {
        setStatus(Idle);

        if (m_queryClientsHistory.count() > 10) {
            for (int i = 0; i < m_queryClientsHistory.count() - 10; ++i) {
                Nepomuk::Query::QueryServiceClient *client = m_queryClientsHistory.first();
                m_queryClientsHistory.pop_front();

                int page = m_pagesForClient.value(client);
                m_queryClients.remove(page);
                m_pagesForClient.remove(client);
                delete client;
            }
        }
    }
}



QVariant MetadataModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.column() != 0 ||
        index.row() < 0 || index.row() >= m_resources.count()){
        return QVariant();
    }

    const Nepomuk::Resource &resource = m_resources[index.row()];


    if (!resource.isValid() && m_pageSize > 0 && !m_queryClients.contains(floor(index.row()/m_pageSize))) {
        //HACK
        const_cast<MetadataModel *>(this)->fetchResultsPage(floor(index.row()/m_pageSize));
        return QVariant();
    //m_pageSize <= 0, means fetch all
    } else if (!resource.isValid() && !m_queryClients.contains(0)) {
        //HACK
        const_cast<MetadataModel *>(this)->fetchResultsPage(0);
        return QVariant();
    } else if (!resource.isValid()) {
        return QVariant();
    }

    //We're lucky: was cached
    if (m_cachedResources.value(resource).contains(role)) {
        return m_cachedResources.value(resource).value(role);
    }

    switch (role) {
    case Qt::DisplayRole:
    case Label:
        return m_cachedResources.value(resource).value(Label);
    case Qt::DecorationRole: 
        return KIcon(m_cachedResources.value(resource).value(Icon).toString());
    case HasSymbol:
    case Icon:
        return m_cachedResources.value(resource).value(Icon).toString();
    case Thumbnail: {
        KUrl url(m_cachedResources.value(resource).value(Url).toString());
        if (m_cachedResources.value(resource).value(IsFile).toBool() && url.isLocalFile()) {
            QImage preview = QImage(m_thumbnailSize, QImage::Format_ARGB32_Premultiplied);

            if (m_imageCache->findImage(url.prettyUrl(), &preview)) {
                return preview;
            }

            m_previewTimer->start(100);
            const_cast<MetadataModel *>(this)->m_filesToPreview[url] = QPersistentModelIndex(index);
        }
        return QVariant();
    }
    case Exists:
        return resource.exists();
    case Rating:
        return resource.rating();
    case NumericRating:
        return resource.property(NAO::numericRating()).toString();
    case Symbols:
        return resource.symbols();
    case ResourceUri:
        return resource.resourceUri();
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
    case TagsNames: {
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

QVariantHash MetadataModel::get(int row) const
{
    QModelIndex idx = index(row, 0);
    QVariantHash hash;

    QHash<int, QByteArray>::const_iterator i;
    for (i = roleNames().constBegin(); i != roleNames().constEnd(); ++i) {
        hash[i.value()] = data(idx, i.key());
    }

    return hash;
}

void MetadataModel::delayedPreview()
{
    QHash<KUrl, QPersistentModelIndex>::const_iterator i = m_filesToPreview.constBegin();

    KFileItemList list;

    while (i != m_filesToPreview.constEnd()) {
        KUrl file = i.key();
        QPersistentModelIndex index = i.value();


        if (!m_previewJobs.contains(file) && file.isValid()) {
            list.append(KFileItem(file, QString(), 0));
            m_previewJobs.insert(file, QPersistentModelIndex(index));
        }

        ++i;
    }

    if (list.size() > 0) {


        KIO::PreviewJob* job = KIO::filePreview(list, m_thumbnailSize, m_thumbnailerPlugins);
        //job->setIgnoreMaximumSize(true);
        kDebug() << "Created job" << job;
        connect(job, SIGNAL(gotPreview(const KFileItem&, const QPixmap&)),
                this, SLOT(showPreview(const KFileItem&, const QPixmap&)));
        connect(job, SIGNAL(failed(const KFileItem&)),
                this, SLOT(previewFailed(const KFileItem&)));
    }

    m_filesToPreview.clear();
}

void MetadataModel::showPreview(const KFileItem &item, const QPixmap &preview)
{
    QPersistentModelIndex index = m_previewJobs.value(item.url());
    m_previewJobs.remove(item.url());

    if (!index.isValid()) {
        return;
    }

    m_imageCache->insertImage(item.url().prettyUrl(), preview.toImage());
    //kDebug() << "preview size:" << preview.size();
    emit dataChanged(index, index);
}

void MetadataModel::previewFailed(const KFileItem &item)
{
    m_previewJobs.remove(item.url());
}

// Just signal QSortFilterProxyModel to do the real sorting.
void MetadataModel::sort(int column, Qt::SortOrder order)
{
    Q_UNUSED(column);
    Q_UNUSED(order);

    beginResetModel();
    endResetModel();
}

void MetadataModel::setThumbnailSize(const QSize& size)
{
    m_thumbnailSize = size;
    emit thumbnailSizeChanged();
}

QSize MetadataModel::thumbnailSize() const
{
    return m_thumbnailSize;
}

#include "metadatamodel.moc"
