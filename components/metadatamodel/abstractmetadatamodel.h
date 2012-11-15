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
#include <Nepomuk2/Vocabulary/NIE>
#include <Nepomuk2/Vocabulary/NFO>
#include <Nepomuk2/Vocabulary/NCO>
#include <Nepomuk2/Vocabulary/NMO>
#include <Nepomuk2/Vocabulary/NDO>
#include <Nepomuk2/Vocabulary/NCAL>
#include <Nepomuk2/Vocabulary/NEXIF>
#include <Nepomuk2/Vocabulary/NUAO>
#include <Nepomuk2/Vocabulary/PIMO>
#include <Nepomuk2/Vocabulary/NMM>
#include <Nepomuk2/Vocabulary/TMO>
#include <Soprano/Vocabulary/RDF>
#include <Soprano/Vocabulary/RDFS>
#include <Soprano/Vocabulary/NRL>

namespace Nepomuk2 {
    class ResourceWatcher;
}

class QDBusServiceWatcher;
class QTimer;

/**
 * This is the base class for the Nepomuk metadata models: all its properties, signals and slots are available in MetadataModel, MetadataCloudModel and MetadataTimelineModel
 *
 * The properties of this class will be used to build a query.
 * The string properties can have a ! as prefix to negate the match.
 *
 * @author Marco Martin <mart@kde.org>
 */
class AbstractMetadataModel : public QAbstractItemModel
{
    Q_OBJECT

    /**
     * @property int the total number of rows in this model
     */
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    AbstractMetadataModel(QObject *parent = 0);
    ~AbstractMetadataModel();

    virtual int count() const = 0;


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
    void mimeTypesChanged();
    void activityIdChanged();
    void tagsChanged();
    void startDateChanged();
    void endDateChanged();
    void minimumRatingChanged();
    void maximumRatingChanged();

protected Q_SLOTS:
    virtual void doQuery();

private Q_SLOTS:
    void serviceRegistered(const QString &service);

protected:
    QString retrieveIconName(const QStringList &types) const;
    /* from nie:url
     * to QUrl("http://www.semanticdesktop.org/ontologies/2007/01/19/nie#url")
     */
    static inline QUrl propertyUrl(const QString &property)
    {
        static QHash<QString, QUrl> namespaceResolution;
        if( namespaceResolution.isEmpty() ) {
            using namespace Nepomuk2::Vocabulary;
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
        QString str;
        foreach (const QVariant &val, list) {
            str = val.toString().trimmed();
            if (!str.isEmpty()) {
                stringList << str;
            }
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
    QStringList mimeTypeStrings() const;
    void requestRefresh();

private:
    QDBusServiceWatcher *m_queryServiceWatcher;
    QHash<QString, QString> m_icons;
    QTimer *m_queryTimer;

    QString m_resourceType;
    QStringList m_mimeTypes;
    QString m_activityId;
    QStringList m_tags;
    QDate m_startDate;
    QDate m_endDate;
    int m_minimumRating;
    int m_maximumRating;
    QDeclarativePropertyMap *m_extraParameters;
};

#endif
