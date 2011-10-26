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

#include <Nepomuk/Query/Query>
#include <Nepomuk/Query/Result>
#include <Nepomuk/Query/QueryServiceClient>
#include <Nepomuk/Resource>

namespace Nepomuk {
    class ResourceWatcher;
}

namespace Plasma {
    class Service;
}


class QDBusServiceWatcher;
class QTimer;

class MetadataService;

class MetadataModel : public AbstractMetadataModel
{
    Q_OBJECT
    Q_PROPERTY(QString queryString READ queryString WRITE setQueryString NOTIFY queryStringChanged)

    Q_PROPERTY(QVariantList sortBy READ sortBy WRITE setSortBy NOTIFY sortByChanged)
    Q_PROPERTY(Qt::SortOrder sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)

    Q_PROPERTY(Plasma::Service *service READ service CONSTANT)

public:
    enum Roles {
        Label = Qt::UserRole+1,
        Description,
        Types,
        ClassName,
        HasSymbol,
        Icon,
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

    Plasma::Service *service();

    /**
     * searches for a resource in the whole model
     * @arg resToFind the uri or url of the resource
     */
    Q_INVOKABLE int find(const QString &resToFind);

    //Reimplemented
    QVariant data(const QModelIndex &index, int role) const;

Q_SIGNALS:
    void queryStringChanged();

    void sortByChanged();
    void sortOrderChanged();

protected Q_SLOTS:
    void newEntries(const QList< Nepomuk::Query::Result > &entries);
    void entriesRemoved(const QList<QUrl> &urls);
    virtual void doQuery();
    void newEntriesDelayed();
    void finishedListing();
    void propertyChanged(Nepomuk::Resource res, Nepomuk::Types::Property prop, QVariant val);

private:
    Nepomuk::Query::Query m_query;
    Nepomuk::Query::QueryServiceClient *m_queryClient;
    Nepomuk::ResourceWatcher* m_watcher;
    QVector<Nepomuk::Resource> m_resources;
    QList<Nepomuk::Resource> m_resourcesToInsert;
    QHash<QUrl, int> m_uriToResourceIndex;
    QTimer *m_queryTimer;
    QTimer *m_newEntriesTimer;
    MetadataService *m_service;

    //pieces to build m_query
    QString m_queryString;

    QStringList m_sortBy;
    Qt::SortOrder m_sortOrder;
};

#endif
