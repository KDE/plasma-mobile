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

#ifndef METADATAMODEL_H
#define METADATAMODEL_H

#include "abstractmetadatamodel.h"

#include <QDate>

#include <KFileItem>

#include <Nepomuk/Query/Query>
#include <Nepomuk/Query/Result>
#include <Nepomuk/Query/QueryServiceClient>
#include <Nepomuk/Resource>
#include <Nepomuk/Variant>

namespace Nepomuk {
    class ResourceWatcher;
}



class QTimer;

class KImageCache;

/**
 * This is the main class of the Nepomuk model bindings: given a query built by assigning its properties such as queryString, resourceType, startDate etc, it constructs a model with a resource per row, with direct access of its main properties as roles.
 *
 * @author Marco Martin <mart@kde.org>
 */
class MetadataModel : public AbstractMetadataModel
{
    Q_OBJECT
    /**
     * @property string a free form query in the Nepomuk desktop query language
     */
    Q_PROPERTY(QString queryString READ queryString WRITE setQueryString NOTIFY queryStringChanged)

    /**
     * @property Array list of fields the results will be sorted: their order is the priority in sorting
     */
    Q_PROPERTY(QVariantList sortBy READ sortBy WRITE setSortBy NOTIFY sortByChanged)

    /**
     * @property SortOrder Qt.Ascending or Qt.Descending
     */
    Q_PROPERTY(Qt::SortOrder sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)

    /**
     * @property int optional limit to cut off the results
     */
    Q_PROPERTY(int limit READ limit WRITE setLimit NOTIFY limitChanged)

    /**
     * If true the resources will be filtered and sorted by the most relevant as a whole or in relation to the activity indicated in the activityId property
     */
    Q_PROPERTY(bool scoreResources READ scoreResources WRITE setScoreResources NOTIFY scoreResourcesChanged)

    /**
     * load as less resources as possible from Nepomuk (only load when asked from the view)
     * default is true, you shouldn't need to change it.
     * if lazyLoading is false the results are live-updating, but will take a lot more system resources
     */
    Q_PROPERTY(bool lazyLoading READ lazyLoading WRITE setLazyLoading NOTIFY lazyLoadingChanged)

    /**
     * Use this property to specify the size of thumbnail which the model should attempt to generate for the thumbnail role.
     */
    Q_PROPERTY(QSize thumbnailSize READ thumbnailSize WRITE setThumbnailSize NOTIFY thumbnailSizeChanged)

public:
    enum Roles {
        Label = Qt::UserRole+1,
        Description,
        Types,
        ClassName,
        GenericClassName,
        HasSymbol,
        Icon,
        Thumbnail,
        IsFile,
        Exists,
        Rating,
        NumericRating,
        Symbols,
        ResourceUri,
        ResourceType,
        MimeType,
        Url,
        Topics,
        TopicsNames,
        Tags,
        TagsNames
    };

    MetadataModel(QObject *parent = 0);
    ~MetadataModel();

    void setQuery(const Nepomuk::Query::Query &query);
    Nepomuk::Query::Query query() const;

    virtual int count() const {return m_resources.count();}

    void setQueryString(const QString &query);
    QString queryString() const;



    void setSortBy(const QVariantList &sortBy);
    QVariantList sortBy() const;

    void setSortOrder(Qt::SortOrder sortOrder);
    Qt::SortOrder sortOrder() const;

    void setLazyLoading(bool size);
    bool lazyLoading() const;

    void setLimit(int limit);
    int limit() const;

    void setScoreResources(bool score);
    bool scoreResources() const;

    void setThumbnailSize(const QSize &size);
    QSize thumbnailSize() const;

    /**
     * searches for a resource in the whole model
     * @arg resToFind the uri or url of the resource
     */
    Q_INVOKABLE int find(const QString &resToFind);

    //Reimplemented
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    /**
     * Reimplemented
     * Just signal QSortFilterProxyModel to do the real sorting.
     * Use this class as parameter to QSortFilterProxyModel->setSourceModel (C++) or
     * PlasmaCore.SortFilterModel.sourceModel (QML) to get the real sorting.
     * WARNING: avoid putting this model into SortFilterModel if possible:
     * it would cause loading every single item of the model,
     * while for big models we want lazy loading.
     * rely on its internal sorting feature instead.
     */
    Q_INVOKABLE void sort(int column, Qt::SortOrder order = Qt::AscendingOrder);

    /**
     * Compatibility with ListModel
     */
    Q_INVOKABLE QVariantHash get(int row) const;

Q_SIGNALS:
    void queryStringChanged();

    void sortByChanged();
    void sortOrderChanged();
    void limitChanged();
    void lazyLoadingChanged();
    void scoreResourcesChanged();
    void thumbnailSizeChanged();

protected Q_SLOTS:
    void countQueryResult(const QList< Nepomuk::Query::Result > &entries);
    void newEntries(const QList< Nepomuk::Query::Result > &entries);
    void entriesRemoved(const QList<QUrl> &urls);
    virtual void doQuery();
    void newEntriesDelayed();
    void finishedListing();
    void propertyChanged(Nepomuk::Resource res, Nepomuk::Types::Property prop, QVariant val);
    void showPreview(const KFileItem &item, const QPixmap &preview);
    void previewFailed(const KFileItem &item);
    void delayedPreview();

protected:
    void fetchResultsPage(int page);

private:
    Nepomuk::Query::Query m_query;
    //mapping page->query client
    QHash<int, Nepomuk::Query::QueryServiceClient *> m_queryClients;
    //mapping query client->page
    QHash<Nepomuk::Query::QueryServiceClient *, int> m_pagesForClient;
    //where is the last valid (already populated) index for a given page
    QHash<int, int> m_validIndexForPage;
    //keep always running at most 10 clients, get rid of the old ones
    //won't be possible to monitor forresources going away, but is too heavy
    QList<Nepomuk::Query::QueryServiceClient *> m_queryClientsHistory;
    //how many service clients are running now?
    int m_runningClients;

    Nepomuk::Query::QueryServiceClient *m_countQueryClient;
    Nepomuk::ResourceWatcher* m_watcher;
    QVector<Nepomuk::Resource> m_resources;
    QHash<int, QList<Nepomuk::Resource> > m_resourcesToInsert;
    QHash<QUrl, int> m_uriToResourceIndex;
    QTimer *m_newEntriesTimer;
    QTime m_elapsedTime;

    //pieces to build m_query
    QString m_queryString;
    int m_limit;
    int m_pageSize;
    bool m_scoreResources;

    QStringList m_sortBy;
    Qt::SortOrder m_sortOrder;

    //previews
    QTimer *m_previewTimer;
    QHash<KUrl, QPersistentModelIndex> m_filesToPreview;
    QSize m_thumbnailSize;
    QHash<KUrl, QPersistentModelIndex> m_previewJobs;
    KImageCache* m_imageCache;
    QStringList* m_thumbnailerPlugins;

    QHash<Nepomuk::Resource, QHash<int, QVariant> > m_cachedResources;
};

#endif
