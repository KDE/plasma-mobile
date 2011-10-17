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

#include <QAbstractItemModel>

#include <Nepomuk/Query/Query>
#include <Nepomuk/Query/Result>
#include <Nepomuk/Query/QueryServiceClient>
#include <Nepomuk/Resource>


namespace Nepomuk {
    class ResourceWatcher;
}

class QDBusServiceWatcher;
class QTimer;

Q_DECLARE_METATYPE(QStringList)

class MetadataModel : public QAbstractItemModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString queryString READ queryString WRITE setQueryString NOTIFY queryStringChanged)
    Q_PROPERTY(QString resourceType READ resourceType WRITE setResourceType NOTIFY resourceTypeChanged)
    Q_PROPERTY(QString activityId READ activityId WRITE setActivityId NOTIFY activityIdChanged)

    Q_PROPERTY(QString sortBy READ sortBy WRITE setSortBy NOTIFY sortByChanged)
    Q_PROPERTY(Qt::SortOrder sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)

public:
    enum Roles {
        Label = Qt::UserRole+1,
        Description,
        Types,
        ClassName,
        GenericClassName,
        HasSymbol,
        Icon,
        IsFile,
        Exists,
        Rating,
        NumericRating,
        Symbols,
        ResourceUri,
        ResourceType,
        Url,
        Topics,
        TopicsNames,
        Tags,
        TagsNanes
    };

    MetadataModel(QObject *parent = 0);
    ~MetadataModel();

    void setQuery(const Nepomuk::Query::Query &query);
    Nepomuk::Query::Query query() const;

    int count() const {return m_resources.count();}

    void setQueryString(const QString &query);
    QString queryString() const;

    void setResourceType(const QString &type);
    QString resourceType() const;

    void setActivityId(const QString &activityId);
    QString activityId() const;



    //FIXME: QStringLists can't be used as properties... wait, WHAT?
    // and no, QDeclarativeListProperty is pretty useless
    void setSortBy(const QString &sortBy);
    QString sortBy() const;

    void setSortOrder(Qt::SortOrder sortOrder);
    Qt::SortOrder sortOrder() const;


    //Reimplemented
    QVariant data(const QModelIndex &index, int role) const;
    QVariant headerData(int section, Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const;
    QModelIndex index(int row, int column,
                      const QModelIndex &parent = QModelIndex()) const;
    QModelIndex parent(const QModelIndex &child) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;

Q_SIGNALS:
    void countChanged();
    void queryStringChanged();
    void resourceTypeChanged();
    void activityIdChanged();

    void sortByChanged();
    void sortOrderChanged();

protected Q_SLOTS:
    void newEntries(const QList< Nepomuk::Query::Result > &entries);
    void entriesRemoved(const QList<QUrl> &urls);
    void serviceRegistered(const QString &service);
    void doQuery();

protected:
    QString retrieveIconName(const QStringList &types) const;
    /* from nie#url
     * to QUrl("http://www.semanticdesktop.org/ontologies/2007/01/19/nie#url")
     */
    inline QUrl propertyUrl(const QString &property)
    {
        if (property.startsWith("nie#")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2007/01/19/"+property);
        } else if (property.startsWith("nao#")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2007/08/15/"+property);
        } else if (property.startsWith("nco#")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2007/03/22/"+property);
        } else if (property.startsWith("nfo#")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2007/03/22/"+property);
        } else {
            return QUrl();
        }
    }

private:
    Nepomuk::Query::Query m_query;
    Nepomuk::Query::QueryServiceClient *m_queryClient;
    Nepomuk::ResourceWatcher* m_watcher;
    QDBusServiceWatcher *m_queryServiceWatcher;
    QVector<Nepomuk::Resource> m_resources;
    QHash<QUrl, int> m_uriToResourceIndex;
    QHash<QString, QString> m_icons;
    QTimer *m_queryTimer;

    //pieces to build m_query
    QString m_queryString;
    QString m_resourceType;
    QString m_activityId;

    QStringList m_sortBy;
    Qt::SortOrder m_sortOrder;
};

#endif
