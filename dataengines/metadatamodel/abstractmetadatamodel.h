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



namespace Nepomuk {
    class ResourceWatcher;
}

class QDBusServiceWatcher;
class QTimer;

Q_DECLARE_METATYPE(QStringList)

class AbstractMetadataModel : public QAbstractItemModel
{
    Q_OBJECT
    Q_PROPERTY(QString resourceType READ resourceType WRITE setResourceType NOTIFY resourceTypeChanged)
    Q_PROPERTY(QString activityId READ activityId WRITE setActivityId NOTIFY activityIdChanged)
    Q_PROPERTY(QVariantList tags READ tags WRITE setTags NOTIFY tagsChanged)
    Q_PROPERTY(QDate startDate READ startDate WRITE setStartDate NOTIFY startDateChanged)
    Q_PROPERTY(QDate endDate READ endDate WRITE setEndDate NOTIFY endDateChanged)
    Q_PROPERTY(int rating READ rating WRITE setRating NOTIFY ratingChanged)

public:
    AbstractMetadataModel(QObject *parent = 0);
    ~AbstractMetadataModel();

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

    //Reimplemented
    QVariant headerData(int section, Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const;
    QModelIndex index(int row, int column,
                      const QModelIndex &parent = QModelIndex()) const;
    QModelIndex parent(const QModelIndex &child) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;

Q_SIGNALS:
    void resourceTypeChanged();
    void activityIdChanged();
    void tagsChanged();
    void startDateChanged();
    void endDateChanged();
    void ratingChanged();

protected Q_SLOTS:
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
    QDBusServiceWatcher *m_queryServiceWatcher;
    QHash<QString, QString> m_icons;
    QTimer *m_queryTimer;

    QString m_resourceType;
    QString m_activityId;
    QStringList m_tags;
    QDate m_startDate;
    QDate m_endDate;
    int m_rating;
};

#endif
