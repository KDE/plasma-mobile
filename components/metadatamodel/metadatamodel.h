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

namespace Nepomuk {
    class ResourceWatcher;
}



class QTimer;

class KImageCache;

class MetadataModel : public AbstractMetadataModel
{
    Q_OBJECT
    Q_PROPERTY(QString queryString READ queryString WRITE setQueryString NOTIFY queryStringChanged)

    Q_PROPERTY(QVariantList sortBy READ sortBy WRITE setSortBy NOTIFY sortByChanged)
    Q_PROPERTY(Qt::SortOrder sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)
    Q_PROPERTY(int limit READ limit WRITE setLimit NOTIFY limitChanged)
    /**
     * load as less resources as possible from Nepomuk (only load when asked from the view)
     * default is true, you shouldn't need to change it
     */
    Q_PROPERTY(bool lazyLoading READ lazyLoading WRITE setLazyLoading NOTIFY lazyLoadingChanged)

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
     */
    Q_INVOKABLE void sort(int column, Qt::SortOrder order = Qt::AscendingOrder);

Q_SIGNALS:
    void queryStringChanged();

    void sortByChanged();
    void sortOrderChanged();
    void limitChanged();
    void lazyLoadingChanged();

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
    QHash<int, Nepomuk::Query::QueryServiceClient *>m_queryClients;
    //mapping query client->page
    QHash<Nepomuk::Query::QueryServiceClient *, int>m_pagesForClient;
    //where is the last valid (already populated) index for a given page
    QHash<int, int> m_validIndexForPage;

    Nepomuk::Query::QueryServiceClient *m_countQueryClient;
    Nepomuk::ResourceWatcher* m_watcher;
    QVector<Nepomuk::Resource> m_resources;
    QHash<int, QList<Nepomuk::Resource> > m_resourcesToInsert;
    QHash<QUrl, int> m_uriToResourceIndex;
    QTimer *m_newEntriesTimer;

    //pieces to build m_query
    QString m_queryString;
    int m_limit;
    int m_pageSize;

    QStringList m_sortBy;
    Qt::SortOrder m_sortOrder;

    //previews
    QTimer *m_previewTimer;
    QHash<KUrl, QPersistentModelIndex> m_filesToPreview;
    QSize m_screenshotSize;
    QHash<KUrl, QPersistentModelIndex> m_previewJobs;
    KImageCache* m_imageCache;
};

#endif
