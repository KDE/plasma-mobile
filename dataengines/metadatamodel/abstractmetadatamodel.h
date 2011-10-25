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

#ifndef ABSTRACTMETADATAMODEL_H
#define ABSTRACTMETADATAMODEL_H

#include <QAbstractItemModel>
#include <QDate>
#include <QStringList>
#include <QUrl>
#include <QDeclarativePropertyMap>


namespace Nepomuk {
    class ResourceWatcher;
}

class QDBusServiceWatcher;
class QTimer;

class AbstractMetadataModel : public QAbstractItemModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString resourceType READ resourceType WRITE setResourceType NOTIFY resourceTypeChanged)
    Q_PROPERTY(QString mimeType READ resourceType WRITE setMimeType NOTIFY mimeTypeChanged)
    Q_PROPERTY(QString activityId READ activityId WRITE setActivityId NOTIFY activityIdChanged)
    Q_PROPERTY(QVariantList tags READ tags WRITE setTags NOTIFY tagsChanged)
    Q_PROPERTY(QDate startDate READ startDate WRITE setStartDate NOTIFY startDateChanged)
    Q_PROPERTY(QDate endDate READ endDate WRITE setEndDate NOTIFY endDateChanged)
    Q_PROPERTY(int minimumRating READ minimumRating WRITE setMinimumRating NOTIFY minimumRatingChanged)
    Q_PROPERTY(int maximumRating READ maximumRating WRITE setMaximumRating NOTIFY maximumRatingChanged)
    Q_PROPERTY(QObject *extraParameters READ extraParameters CONSTANT)

public:
    AbstractMetadataModel(QObject *parent = 0);
    ~AbstractMetadataModel();

    virtual int count() const = 0;

    void setResourceType(const QString &type);
    QString resourceType() const;

    void setMimeType(const QString &type);
    QString mimeType() const;

    void setActivityId(const QString &activityId);
    QString activityId() const;

    void setTags(const QVariantList &tags);
    QVariantList tags() const;

    void setStartDate(const QDate &date);
    QDate startDate() const;

    void setEndDate(const QDate &date);
    QDate endDate() const;

    void setMinimumRating(int rating);
    int minimumRating() const;

    void setMaximumRating(int rating);
    int maximumRating() const;

    QObject *extraParameters() const;

    //Reimplemented
    QVariant headerData(int section, Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const;
    QModelIndex index(int row, int column,
                      const QModelIndex &parent = QModelIndex()) const;
    QModelIndex parent(const QModelIndex &child) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;

Q_SIGNALS:
    void countChanged();
    void resourceTypeChanged();
    void mimeTypeChanged();
    void activityIdChanged();
    void tagsChanged();
    void startDateChanged();
    void endDateChanged();
    void minimumRatingChanged();
    void maximumRatingChanged();

protected Q_SLOTS:
    void serviceRegistered(const QString &service);
    virtual void doQuery();

protected:
    QString retrieveIconName(const QStringList &types) const;
    /* from nie:url
     * to QUrl("http://www.semanticdesktop.org/ontologies/2007/01/19/nie#url")
     */
    inline QUrl propertyUrl(const QString &property) const
    {
        const QString prop = QString(property).split(":").last();
        if (property.startsWith("rdf:")) {
            return QUrl("http://www.w3.org/1999/02/22-rdf-syntax-ns#"+prop);
        } else if (property.startsWith("rdf-schema:")) {
            return QUrl("http://www.w3.org/2000/01/rdf-schema#"+prop);
        } else if (property.startsWith("nie:")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2007/01/19/nie#"+prop);
        } else if (property.startsWith("nao:")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2007/08/15/nao#"+prop);
        } else if (property.startsWith("nco:")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2007/03/22/nco#"+prop);
        } else if (property.startsWith("nfo:")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#"+prop);
        } else if (property.startsWith("ncal:")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2007/04/02/ncal#"+prop);
        } else if (property.startsWith("ndo:")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2010/04/30/ndo#"+prop);
        } else if (property.startsWith("nexif:")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2007/05/10/nexif#"+prop);
        } else if (property.startsWith("nid3:")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2007/05/10/nid3#"+prop);
        } else if (property.startsWith("nmm:")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2009/02/19/nmm#"+prop);
        } else if (property.startsWith("nmo:")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2007/03/22/nmo#"+prop);
        } else if (property.startsWith("nrl:")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2007/08/15/nrl#"+prop);
        } else if (property.startsWith("nso:")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2009/11/08/nso#"+prop);
        } else if (property.startsWith("nuao:")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2010/01/25/nuao#"+prop);
        } else if (property.startsWith("pimo:")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2007/11/01/pimo#"+prop);
        } else if (property.startsWith("tmo:")) {
            return QUrl("http://www.semanticdesktop.org/ontologies/2008/05/20/tmo#"+prop);
        } else {
            return QUrl();
        }
    }

    inline QString propertyShortName(const QUrl &url)
    {
        //http://www.semanticdesktop.org/ontologies/2007/03/22/nfo will become nfo
        return url.path().split("/").last() + ":" + url.fragment();
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

    QStringList tagStrings() const;

private:
    QDBusServiceWatcher *m_queryServiceWatcher;
    QHash<QString, QString> m_icons;
    QTimer *m_queryTimer;

    QString m_resourceType;
    QString m_mimeType;
    QString m_activityId;
    QStringList m_tags;
    QDate m_startDate;
    QDate m_endDate;
    int m_minimumRating;
    int m_maximumRating;
    QDeclarativePropertyMap *m_extraParameters;
};

#endif
