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
#include <QDate>

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
    Q_PROPERTY(QVariantList tags READ tags WRITE setTags NOTIFY tagsChanged)
    Q_PROPERTY(QDate startDate READ startDate WRITE setStartDate NOTIFY startDateChanged)
    Q_PROPERTY(QDate endDate READ endDate WRITE setEndDate NOTIFY endDateChanged)
    Q_PROPERTY(int rating READ rating WRITE setRating NOTIFY ratingChanged)

    Q_PROPERTY(QVariantList sortBy READ sortBy WRITE setSortBy NOTIFY sortByChanged)
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

    void setTags(const QVariantList &tags);
    QVariantList tags() const;

    void setStartDate(const QDate &date);
    QDate startDate() const;

    void setEndDate(const QDate &date);
    QDate endDate() const;

    void setRating(int rating);
    int rating() const;



    void setSortBy(const QVariantList &sortBy);
    QVariantList sortBy() const;

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
    void tagsChanged();
    void startDateChanged();
    void endDateChanged();
    void ratingChanged();

    void sortByChanged();
    void sortOrderChanged();

protected Q_SLOTS:
    void newEntries(const QList< Nepomuk::Query::Result > &entries);
    void entriesRemoved(const QList<QUrl> &urls);
    void serviceRegistered(const QString &service);
    void doQuery();
    void newEntriesDelayed();

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

    static inline QStringList variantToStringList(const QVariantList &list)
    {
        QStringList stringList;
        foreach (const QVariant &val, list) {
            stringList << val.toString();
        }
        return stringList;
    }

    static inline QVariantList stringToVariantList(const QStringList &list)
    {
        QVariantList variantList;
        foreach (const QString &val, list) {
            variantList << val;
        }
        return variantList;
    }

private:
    Nepomuk::Query::Query m_query;
    Nepomuk::Query::QueryServiceClient *m_queryClient;
    Nepomuk::ResourceWatcher* m_watcher;
    QDBusServiceWatcher *m_queryServiceWatcher;
    QVector<Nepomuk::Resource> m_resources;
    QList<Nepomuk::Resource> m_resourcesToInsert;
    QHash<QUrl, int> m_uriToResourceIndex;
    QHash<QString, QString> m_icons;
    QTimer *m_queryTimer;
    QTimer *m_newEntriesTimer;

    //pieces to build m_query
    QString m_queryString;
    QString m_resourceType;
    QString m_activityId;
    QStringList m_tags;
    QDate m_startDate;
    QDate m_endDate;
    int m_rating;

    QStringList m_sortBy;
    Qt::SortOrder m_sortOrder;
};

#endif
