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
#include "queryproviders/basicqueryprovider.h"
#include "querythread.h"

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
#include <Nepomuk2/ResourceWatcher>

#include "kao.h"

using namespace Nepomuk2::Vocabulary;
using namespace Soprano::Vocabulary;

MetadataModel::MetadataModel(QObject *parent)
    : AbstractMetadataModel(parent),
      m_limit(0),
      m_pageSize(30),
      m_thumbnailSize(180, 120),
      m_thumbnailerPlugins(new QStringList(KIO::PreviewJob::availablePlugins()))
{
    m_queryThread = new QueryThread(this);
    connect(m_queryThread, SIGNAL(newResults(QList<Nepomuk2::Query::Result>, int)),
            this, SLOT(newEntries(QList<Nepomuk2::Query::Result>, int)));
    connect(m_queryThread, SIGNAL(resultsRemoved(QList<QUrl>)),
            this, SLOT(entriesRemoved(QList<QUrl>)));
    connect(m_queryThread, SIGNAL(countRetrieved(int)),
            this, SLOT(countRetrieved(int)));

    //TODO: error(QString);
    //TODO: runningChanged();

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

    m_watcher = new Nepomuk2::ResourceWatcher(this);

    m_watcher->addProperty(NAO::numericRating());
    connect(m_watcher, SIGNAL(propertyAdded(Nepomuk2::Resource,Nepomuk2::Types::Property,QVariant)),
            this, SLOT(propertyChanged(Nepomuk2::Resource,Nepomuk2::Types::Property,QVariant)));


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
    roleNames[ResourceUri] = "resourceUri";
    roleNames[ResourceType] = "resourceType";
    roleNames[MimeType] = "mimeType";
    roleNames[Url] = "url";
    roleNames[Tags] = "tags";
    roleNames[TagsNames] = "tagsNames";
    setRoleNames(roleNames);
}

MetadataModel::~MetadataModel()
{
    delete m_imageCache;
}


void MetadataModel::setQuery(const Nepomuk2::Query::Query &query)
{
    m_query = query;

    if (Nepomuk2::Query::QueryServiceClient::serviceAvailable()) {
        requestRefresh();
    }
}

Nepomuk2::Query::Query MetadataModel::query() const
{
    return m_query;
}

void MetadataModel::setQueryProvider(BasicQueryProvider *provider)
{
    if (m_queryProvider.data() == provider) {
        return;
    }

    if (m_queryProvider) {
        disconnect(m_queryProvider.data(), 0, this, 0);
    }

    connect(provider, SIGNAL(queryChanged()), this, SLOT(doQuery()));
    connect(provider, SIGNAL(sparqlQueryChanged()), this, SLOT(doQuery()));

    m_queryProvider = provider;
    doQuery();
    emit queryProviderChanged();
}

BasicQueryProvider *MetadataModel::queryProvider() const
{
    return m_queryProvider.data();
}


void MetadataModel::setLimit(int limit)
{
    if (limit == m_limit) {
        return;
    }

    m_limit = limit;
    requestRefresh();
    emit limitChanged();
}

int MetadataModel::limit() const
{
    return m_limit;
}

void MetadataModel::setLazyLoading(bool lazy)
{
    //lazy loading depends from the page zise, that is not directly user controllable
    if (lazy == (m_pageSize > 0)) {
        return;
    }

    //TODO: a way to control this? maybe from the available memory?
    m_pageSize = lazy ? 30 : -1;
    requestRefresh();
    emit lazyLoadingChanged();
}

bool MetadataModel::lazyLoading() const
{
    return (m_pageSize > 0);
}


void MetadataModel::doQuery()
{
    if (!queryProvider()) {
        return;
    }

    m_query = queryProvider()->query();
    kWarning()<<"Sparql query:"<<m_query.toSparqlQuery();

    beginResetModel();
    m_resources = QVector<Nepomuk2::Resource>(0);
    m_uriToRow.clear();
    m_dataToInsert.clear();
    m_validIndexForPage.clear();
    endResetModel();
    emit countChanged();

    if (m_limit > 0) {
        m_query.setLimit(m_limit);
    }

    m_queryThread->setQuery(m_query, m_limit, m_pageSize);

    //if page size is invalid, fetch all
    if (m_pageSize < 1) {
        fetchResultsPage(0);
    }

    //FIXME
    // Nepomuk2::Query::QueryServiceClient does not emit finishedListing signal when there is no new entries (no matches).
    QTimer::singleShot(5000, this, SLOT(finishedListing()));
}

void MetadataModel::fetchResultsPage(int page)
{
    m_validIndexForPage[page] = 0;

    m_queryThread->fetchResultsPage(page);
}

void MetadataModel::countRetrieved(int count)
{
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

void MetadataModel::newEntries(const QList< Nepomuk2::Query::Result > &entries, int page)
{
    foreach (const Nepomuk2::Query::Result &res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //kDebug() << "Result label:" << res.genericLabel();

        Nepomuk2::Resource resource = res.resource();
        if (resource.property(propertyUrl("nie:url")).toString().isEmpty()) {
            continue;
        }
        m_dataToInsert[page] << resource;

        /*



        //FIXME: symbols seems broken on Mer
        //indagate after PA3
        if (0&&!resource.symbols().isEmpty()) {
            m_cachedResources[resource][Icon] = resource.symbols().first();
        } else {
            //if it's an application, fetch the icon from the desktop file
            Nepomuk2::Types::Class resClass(resource.type());
            if (resClass.label() == "Application") {
                KService::Ptr serv = KService::serviceByDesktopPath(m_cachedResources[resource][Url].toUrl().path());
                if (serv) {
                    m_cachedResources[resource][Icon] = serv->icon();
                } else {
                    m_cachedResources[resource][Icon] = KMimeType::iconNameForUrl(m_cachedResources[resource][Url].toString());
                }
            } else {
                m_cachedResources[resource][Icon] = KMimeType::iconNameForUrl(m_cachedResources[resource][Url].toString());
            }
        }

        //those seems to not be possible avoiding to access the resource
       // m_cachedResources[resource][MimeType] = resource.mimeType();
        m_cachedResources[resource][MimeType] = resource.property(propertyUrl("nie:mimeType")).toString();

        */
    }

    if (!m_newEntriesTimer->isActive() && !m_dataToInsert[page].isEmpty()) {
        m_newEntriesTimer->start(200);
    }
}

void MetadataModel::newEntriesDelayed()
{
    if (m_dataToInsert.isEmpty()) {
        return;
    }

    m_elapsedTime.start();
    QHash<int, QList<Nepomuk2::Resource> >::const_iterator i;
    for (i = m_dataToInsert.constBegin(); i != m_dataToInsert.constEnd(); ++i) {
        const QList<Nepomuk2::Resource> resourcesToInsert = i.value();

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

        foreach (const Nepomuk2::Resource &res, resourcesToInsert) {
            kDebug() << "Result!!!" << res.genericLabel() << res.type();
            kDebug() << "Page:" << i.key() << "Index:"<< pageStart + offset;

            m_uriToRow[res.uri()] = pageStart + offset;
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
    m_dataToInsert.clear();
}

void MetadataModel::propertyChanged(Nepomuk2::Resource res, Nepomuk2::Types::Property prop, QVariant val)
{
    Q_UNUSED(prop)
    Q_UNUSED(val)

    const int index = m_uriToRow.value(res.uri());
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
        const int index = m_uriToRow.value(url);
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

    //another loop, we don't depend to m_uriToRow in data(), but we take this doublesafety
    foreach (const QUrl &url, urls) {
        m_uriToRow.remove(url);
    }

    //FIXME: this loop makes all the optimizations useless, get rid either of it or the optimizations
    for (int i = 0; i < m_resources.count(); ++i) {
        m_uriToRow[m_resources[i].uri()] = i;
    }

    emit countChanged();
}

QString MetadataModel::resourceIcon(const Nepomuk2::Resource &resource) const
{
    //FIXME: symbols seems broken on Mer
    //indagate after PA3
    if (0&&!resource.symbols().isEmpty()) {
        return resource.symbols().first();
    } else {
        //if it's an application, fetch the icon from the desktop file
        Nepomuk2::Types::Class resClass(resource.type());
        if (resClass.label() == "Application") {
            KService::Ptr serv = KService::serviceByDesktopPath(resource.property(propertyUrl("nie:url")).toUrl().path());
            if (serv) {
                return serv->icon();
            } else {
                return KMimeType::iconNameForUrl(resource.property(propertyUrl("nie:url")).toString());
            }
        } else {
            return KMimeType::iconNameForUrl(resource.property(propertyUrl("nie:url")).toString());
        }
    }
}

QVariant MetadataModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.column() != 0 ||
        index.row() < 0 || index.row() >= m_resources.count()){
        return QVariant();
    }

    const Nepomuk2::Resource &resource = m_resources[index.row()];


    if (!resource.isValid() && m_pageSize > 0 && !m_queryThread->hasQueryOnPage(floor(index.row()/m_pageSize))) {
        //HACK
        //const_cast<MetadataModel *>(this)->fetchResultsPage(floor(index.row()/m_pageSize));
        m_queryThread->fetchResultsPage(floor(index.row()/m_pageSize));
        return QVariant();
    //m_pageSize <= 0, means fetch all
    } else if (!resource.isValid() && !m_queryThread->hasQueryOnPage(0)) {
        //HACK
        //const_cast<MetadataModel *>(this)->fetchResultsPage(0);
        m_queryThread->fetchResultsPage(0);
        return QVariant();
    } else if (!resource.isValid()) {
        return QVariant();
    }


    switch (role) {
    case Qt::DisplayRole:
    case Label:
        return resource.genericLabel();
    case Description:
        return resource.description();
    case Qt::DecorationRole: 
        return KIcon(resourceIcon(resource));
    case HasSymbol:
    case Icon:
        return resourceIcon(resource);
    case Thumbnail: {
        KUrl url(resource.property(propertyUrl("nie:url")).toString());
        if (resource.isFile() && url.isLocalFile()) {
            QImage preview = QImage(m_thumbnailSize, QImage::Format_ARGB32_Premultiplied);

            if (m_imageCache->findImage(url.prettyUrl(), &preview)) {
                return preview;
            }

            m_previewTimer->start(100);
            const_cast<MetadataModel *>(this)->m_filesToPreview[url] = QPersistentModelIndex(index);
        }
        return QVariant();
    }
    case Url:
        return resource.property(propertyUrl("nie:url")).toString();
    case ClassName:
        return resource.type().toString().section( QRegExp( "[#:]" ), -1 );
    //FIXME: The most complicated of all, this should really be simplified
    case GenericClassName: {
        //FIXME: a more elegant way is needed
        //if a Bookmark is a Document too, Bookmark wins
        if (resource.types().contains(NFO::Bookmark())) {
            return "Bookmark";

        } else {
            Nepomuk2::Types::Class resClass(resource.type());
            foreach (const Nepomuk2::Types::Class &parentClass, resClass.parentClasses()) {
                const QString label = parentClass.label();
                if (label == "Document" ||
                    label == "Audio" ||
                    label == "Video" ||
                    label == "Image" ||
                    label == "Contact") {
                    return label;
                    break;
                //two cases where the class is 2 levels behind the level of generalization we want
                } else if (parentClass.label() == "RasterImage") {
                    return "Image";
                } else if (parentClass.label() == "TextDocument") {
                    return "Document";
                }
            }
        }
        //this should never happen
        return QVariant();
    }
    case ResourceType:
        return resource.type();
    case MimeType:
        return resource.property(propertyUrl("nie:mimeType")).toString();
    case IsFile:
        return resource.isFile();
    case Exists:
        return resource.exists();
    case Rating:
        return resource.rating();
    case NumericRating:
        return resource.property(NAO::numericRating()).toString();
    case ResourceUri:
        return resource.uri();
    case Types: {
        QStringList types;
        foreach (const QUrl &u, resource.types()) {
            types << u.toString();
        }
        return types;
    }
    case Tags: {
        QStringList tags;
        foreach (const Nepomuk2::Tag &tag, resource.tags()) {
            tags << tag.uri().toString();
        }
        return tags;
    }
    case TagsNames: {
        QStringList tagNames;
        foreach (const Nepomuk2::Tag &tag, resource.tags()) {
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
        connect(job, SIGNAL(gotPreview(KFileItem,QPixmap)),
                this, SLOT(showPreview(KFileItem,QPixmap)));
        connect(job, SIGNAL(failed(KFileItem)),
                this, SLOT(previewFailed(KFileItem)));
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
