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

#include <Nepomuk2/Query/Query>
#include <Nepomuk2/Query/Result>
#include <Nepomuk2/Query/QueryServiceClient>
#include <Nepomuk2/Resource>
#include <Nepomuk2/Variant>

namespace Nepomuk2 {
    class ResourceWatcher;
}



class QTimer;

class KImageCache;

class BasicQueryProvider;
class QueryThread;

/**
 * This is the main class of the Nepomuk model bindings: given a query built by assigning its properties such as queryString, resourceType, startDate etc, it constructs a model with a resource per row, with direct access of its main properties as roles.
 *
 * @author Marco Martin <mart@kde.org>
 */
class MetadataModel : public AbstractMetadataModel
{
    Q_OBJECT

    /**
     * @property int optional limit to cut off the results
     */
    Q_PROPERTY(int limit READ limit WRITE setLimit NOTIFY limitChanged)

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

    Q_PROPERTY(BasicQueryProvider *queryProvider READ queryProvider WRITE setQueryProvider NOTIFY queryProviderChanged)

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
        ResourceUri,
        ResourceType,
        MimeType,
        Url,
        Tags,
        TagsNames
    };

    MetadataModel(QObject *parent = 0);
    ~MetadataModel();

    void setQuery(const Nepomuk2::Query::Query &query);
    Nepomuk2::Query::Query query() const;

    void setQueryProvider(BasicQueryProvider *provider);
    BasicQueryProvider *queryProvider() const;

    virtual int count() const {return m_resources.count();}

    void setLazyLoading(bool size);
    bool lazyLoading() const;

    void setLimit(int limit);
    int limit() const;

    void setThumbnailSize(const QSize &size);
    QSize thumbnailSize() const;

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
     * @see sortBy
     */
    Q_INVOKABLE void sort(int column, Qt::SortOrder order = Qt::AscendingOrder);

    /**
     * Compatibility with ListModel
     * @returns an Object that represents the item with all roles as properties
     */
    Q_INVOKABLE QVariantHash get(int row) const;

Q_SIGNALS:
    void queryProviderChanged();
    void limitChanged();
    void lazyLoadingChanged();
    void thumbnailSizeChanged();

protected Q_SLOTS:
    void countRetrieved(int count);
    void newEntries(const QList< Nepomuk2::Query::Result > &entries, int page);
    void entriesRemoved(const QList<QUrl> &urls);
    virtual void doQuery();
    void newEntriesDelayed();
    void propertyChanged(Nepomuk2::Resource res, Nepomuk2::Types::Property prop, QVariant val);
    void showPreview(const KFileItem &item, const QPixmap &preview);
    void previewFailed(const KFileItem &item);
    void delayedPreview();

protected:
    void fetchResultsPage(int page);

    //FIXME: move to the provider
    QString resourceIcon(const Nepomuk2::Resource &resource) const;

private:
    //query construction is completely delegated to this
    QWeakPointer<BasicQueryProvider> m_queryProvider;

    //perform all the queries in this thread
    QueryThread *m_queryThread;

    //actual query performed
    Nepomuk2::Query::Query m_query;
    //pieces to limit how much stuff we fetch
    int m_limit;
    int m_pageSize;

    //where is the last valid (already populated) index for a given page
    QHash<int, int> m_validIndexForPage;


    //actual main data
    QVector<Nepomuk2::Resource> m_resources;
    //some properties may change dynamically
    Nepomuk2::ResourceWatcher* m_watcher;
    //used to event compress new results arriving
    QTimer *m_newEntriesTimer;
    //a queue by page of the data that will be inserted in the model with event compression
    QHash<int, QList<Nepomuk2::Resource> > m_dataToInsert;
    //maps uris ro row numbers, so when entriesRemoved arrived, we know what rows to remove
    QHash<QUrl, int> m_uriToRow;

    //used purely for benchmark
    QTime m_elapsedTime;


    //previews
    QTimer *m_previewTimer;
    QHash<KUrl, QPersistentModelIndex> m_filesToPreview;
    QSize m_thumbnailSize;
    QHash<KUrl, QPersistentModelIndex> m_previewJobs;
    KImageCache* m_imageCache;
    QStringList* m_thumbnailerPlugins;
};

#endif
