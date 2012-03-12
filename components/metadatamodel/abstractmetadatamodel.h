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

#include "nso.h"
#include "kao.h"
#include <Nepomuk/Vocabulary/NIE>
#include <Nepomuk/Vocabulary/NFO>
#include <Nepomuk/Vocabulary/NCO>
#include <Nepomuk/Vocabulary/NMO>
#include <Nepomuk/Vocabulary/NDO>
#include <Nepomuk/Vocabulary/NCAL>
#include <Nepomuk/Vocabulary/NEXIF>
#include <Nepomuk/Vocabulary/NUAO>
#include <Nepomuk/Vocabulary/PIMO>
#include <Nepomuk/Vocabulary/NMM>
#include <Nepomuk/Vocabulary/TMO>
#include <Soprano/Vocabulary/RDF>
#include <Soprano/Vocabulary/RDFS>
#include <Soprano/Vocabulary/NRL>

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
    Q_PROPERTY(QString mimeType READ mimeType WRITE setMimeType NOTIFY mimeTypeChanged)
    Q_PROPERTY(QString activityId READ activityId WRITE setActivityId NOTIFY activityIdChanged)
    Q_PROPERTY(QVariantList tags READ tags WRITE setTags NOTIFY tagsChanged)
    //HACK: should be a qdate, but the qml management of qdates is horrible++
    Q_PROPERTY(QString startDate READ startDateString WRITE setStartDateString NOTIFY startDateChanged)
    Q_PROPERTY(QString endDate READ endDateString WRITE setEndDateString NOTIFY endDateChanged)
    Q_PROPERTY(int minimumRating READ minimumRating WRITE setMinimumRating NOTIFY minimumRatingChanged)
    Q_PROPERTY(int maximumRating READ maximumRating WRITE setMaximumRating NOTIFY maximumRatingChanged)
    Q_PROPERTY(QObject *extraParameters READ extraParameters CONSTANT)
    Q_PROPERTY(Status status READ status NOTIFY statusChanged)
    Q_ENUMS(Status)

public:
    //Idle: the query client is doing nothing
    //Waiting: the query client is waiting for the first result
    //Running: some results came, listing not finished
    enum Status {
        Idle = 0,
        Waiting,
        Running
    };

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



    //HACK: normal getters and setters still presents, the one with strings are mapped to QML
    void setStartDate(const QDate &date);
    QDate startDate() const;

    void setEndDate(const QDate &date);
    QDate endDate() const;

    void setStartDateString(const QString &date);
    QString startDateString() const;

    void setEndDateString(const QString &date);
    QString endDateString() const;


 
    void setMinimumRating(int rating);
    int minimumRating() const;

    void setMaximumRating(int rating);
    int maximumRating() const;

    QObject *extraParameters() const;

    Status status() const;

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
    void statusChanged();

protected Q_SLOTS:
    void serviceRegistered(const QString &service);
    virtual void doQuery();

protected:
    QString retrieveIconName(const QStringList &types) const;
    /* from nie:url
     * to QUrl("http://www.semanticdesktop.org/ontologies/2007/01/19/nie#url")
     */
    static inline QUrl propertyUrl(const QString &property)
    {
        static QHash<QString, QUrl> namespaceResolution;
        if( namespaceResolution.isEmpty() ) {
            using namespace Nepomuk::Vocabulary;
            using namespace Soprano::Vocabulary;

            namespaceResolution.insert(QLatin1String("rdf"), RDF::rdfNamespace());
            namespaceResolution.insert(QLatin1String("kao"), KAO::kaoNamespace());
            namespaceResolution.insert(QLatin1String("rdf-schema"), RDFS::rdfsNamespace());
            namespaceResolution.insert(QLatin1String("nie"), NIE::nieNamespace());
            namespaceResolution.insert(QLatin1String("nfo"), NFO::nfoNamespace());
            namespaceResolution.insert(QLatin1String("nco"), NCO::ncoNamespace());
            namespaceResolution.insert(QLatin1String("ncal"), NCAL::ncalNamespace());
            namespaceResolution.insert(QLatin1String("ndo"), NDO::ndoNamespace());
            namespaceResolution.insert(QLatin1String("nmm"), NMM::nmmNamespace());
            namespaceResolution.insert(QLatin1String("nmo"), NMO::nmoNamespace());
            namespaceResolution.insert(QLatin1String("nmo"), NMO::nmoNamespace());
            namespaceResolution.insert(QLatin1String("nrl"), NRL::nrlNamespace());
            namespaceResolution.insert(QLatin1String("nso"), NSO::nsoNamespace());
            namespaceResolution.insert(QLatin1String("nrl"), NRL::nrlNamespace());
            namespaceResolution.insert(QLatin1String("nuao"), NUAO::nuaoNamespace());
            namespaceResolution.insert(QLatin1String("tmo"), TMO::tmoNamespace());
            namespaceResolution.insert(QLatin1String("pimo"), PIMO::pimoNamespace());
            namespaceResolution.insert(QLatin1String("nexif"), NEXIF::nexifNamespace());
            //namespaceResolution.insert(QLatin1String("nid3"), NID3::nid3Namespace());
        }
        int colonPosition = property.indexOf(QChar::fromAscii(':'));
        if( colonPosition == -1 )
            return QUrl();

        QHash<QString, QUrl>::const_iterator it = namespaceResolution.constFind( property.mid(0, colonPosition) );
        if( it == namespaceResolution.constEnd() )
            return QUrl();

        return it.value().toString() + property.mid(colonPosition+1);
    }

    static inline QString propertyShortName(const QUrl &url)
    {
        //vHanda: not always, again store all the ontologies and use a hash map
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
    void setStatus(Status status);
    void askRefresh();

private:
    QDBusServiceWatcher *m_queryServiceWatcher;
    QHash<QString, QString> m_icons;
    QTimer *m_queryTimer;
    Status m_status;

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
