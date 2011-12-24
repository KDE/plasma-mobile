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

#include <QDBusConnection>
#include <QDBusServiceWatcher>
#include <QTimer>

#include <KDebug>
#include <KIcon>
#include <KImageCache>
#include <KMimeType>
#include <KIO/PreviewJob>

#include <soprano/vocabulary.h>

#include <Nepomuk/File>
#include <Nepomuk/Query/AndTerm>
#include <Nepomuk/Query/NegationTerm>
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
      m_queryClient(0),
      m_screenshotSize(180, 120)
{
    m_queryTimer = new QTimer(this);
    m_queryTimer->setSingleShot(true);
    connect(m_queryTimer, SIGNAL(timeout()),
            this, SLOT(doQuery()));

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

    m_watcher->addProperty(QUrl("http://www.semanticdesktop.org/ontologies/2007/08/15/nao#numericRating"));
    connect(m_watcher, SIGNAL(propertyAdded(Nepomuk::Resource, Nepomuk::Types::Property, QVariant)),
            this, SLOT(propertyChanged(Nepomuk::Resource, Nepomuk::Types::Property, QVariant)));


    QHash<int, QByteArray> roleNames;
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


int MetadataModel::find(const QString &resourceUri)
{
    int index = -1;
    int i = 0;
    Nepomuk::Resource resToFind(resourceUri);

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
            Nepomuk::Query::ComparisonTerm term(propertyUrl(key), Nepomuk::Query::LiteralTerm(parameter), Nepomuk::Query::ComparisonTerm::Regexp);

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
        Nepomuk::Resource acRes(activity, Nepomuk::Vocabulary::KEXT::Activity());
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
                                    Nepomuk::Query::LiteralTerm(individualTag));
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
    connect(m_queryClient, SIGNAL(finishedListing()), this, SLOT(finishedListing()));

    /*FIXME: safe without limit?
    if (limit > RESULT_LIMIT || limit <= 0) {
        m_query.setLimit(RESULT_LIMIT);
    }
    */

    m_queryClient->query(m_query);
}

void MetadataModel::newEntries(const QList< Nepomuk::Query::Result > &entries)
{
    setStatus(Running);
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

    m_watcher->stop();

    foreach (Nepomuk::Resource res, m_resourcesToInsert) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //kDebug() << "Result label:" << res.genericLabel();
        m_uriToResourceIndex[res.resourceUri()] = m_resources.count();
        m_resources << res;
        m_watcher->addResource(res);
    }

    m_watcher->start();

    m_resourcesToInsert.clear();

    endInsertRows();
    emit countChanged();
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
    setStatus(Idle);
}



QVariant MetadataModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.column() != 0 ||
        index.row() < 0 || index.row() >= m_resources.count()){
        return QVariant();
    }

    const Nepomuk::Resource &resource = m_resources[index.row()];

    switch (role) {
    case Qt::DisplayRole:
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
        //FIXME: most bookmarks are Document too, so Bookmark wins
        if (resource.types().contains(QUrl::fromEncoded("http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#Bookmark"))) {
            return "Bookmark";
        }
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
    case Qt::DecorationRole: {
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
        return KIcon(icon);
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
    case Thumbnail:
        if (resource.isFile() && resource.toFile().url().isLocalFile()) {
            KUrl file(resource.toFile().url());
            QImage preview = QImage(m_screenshotSize, QImage::Format_ARGB32_Premultiplied);

            if (m_imageCache->findImage(file.prettyUrl(), &preview)) {
                return preview;
            }

            m_previewTimer->start(100);
            const_cast<MetadataModel *>(this)->m_filesToPreview[file] = QPersistentModelIndex(index);
        }
        return QVariant();
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
    case MimeType:
        return resource.property(QUrl("http://www.semanticdesktop.org/ontologies/2007/01/19/nie#mimeType")).toString();
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
        KIO::PreviewJob* job = KIO::filePreview(list, m_screenshotSize);
        job->setIgnoreMaximumSize(true);
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

#include "metadatamodel.moc"
