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

#include "metadatacloudmodel.h"

#include <QDBusConnection>
#include <QDBusServiceWatcher>
#include <QTimer>

#include <KDebug>
#include <KMimeType>

#include <soprano/vocabulary.h>

#include <Nepomuk/File>
#include <Nepomuk/Query/AndTerm>
#include <Nepomuk/Query/ResourceTerm>
#include <Nepomuk/Tag>
#include <Nepomuk/Variant>
#include <nepomuk/comparisonterm.h>
#include <nepomuk/literalterm.h>
#include <nepomuk/queryparser.h>
#include <nepomuk/resourcetypeterm.h>
#include <nepomuk/standardqueries.h>

#include <nepomuk/nfo.h>
#include <nepomuk/nie.h>

#include "kext.h"


MetadataCloudModel::MetadataCloudModel(QObject *parent)
    : QAbstractItemModel(parent),
      m_queryClient(0),
      m_cloudCategory(NoCategory)
{
    // Add fallback icons here from generic to specific
    // The list of types is also sorted in this way, so
    // we're returning the most specific icon, even with
    // the hardcoded mapping.

    // Files
    //m_icons["FileDataObject"] = QString("audio-x-generic");

    // Audio
    m_icons["Audio"] = QString("audio-x-generic");
    m_icons["MusicPiece"] = QString("audio-x-generic");

    // Images
    m_icons["Image"] = QString("image-x-generic");
    m_icons["RasterImage"] = QString("image-x-generic");

    m_icons["Email"] = QString("internet-mail");
    m_icons["Document"] = QString("kword");
    m_icons["PersonContact"] = QString("x-office-contact");

    // Filesystem
    m_icons["Website"] = QString("text-html");

    // ... add some more
    // Filesystem
    m_icons["Bookmark"] = QString("bookmarks");
    m_icons["BookmarksFolder"] = QString("bookmarks-organize");

    m_icons["FileDataObject"] = QString("unknown");
    m_icons["TextDocument"] = QString("text-enriched");



    m_queryTimer = new QTimer(this);
    m_queryTimer->setSingleShot(true);
    connect(m_queryTimer, SIGNAL(timeout()),
            this, SLOT(doQuery()));


    connect(this, SIGNAL(rowsInserted(const QModelIndex &, int, int)),
            this, SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsRemoved(const QModelIndex &, int, int)),
            this, SIGNAL(countChanged()));
    connect(this, SIGNAL(modelReset()),
            this, SIGNAL(countChanged()));

    QHash<int, QByteArray> roleNames;
    roleNames[Label] = "label";
    roleNames[Count] = "count";
    setRoleNames(roleNames);

    m_queryServiceWatcher = new QDBusServiceWatcher(QLatin1String("org.kde.nepomuk.services.nepomukqueryservice"),
                        QDBusConnection::sessionBus(),
                        QDBusServiceWatcher::WatchForRegistration,
                        this);
    connect(m_queryServiceWatcher, SIGNAL(serviceRegistered(QString)), this, SLOT(serviceRegistered(QString)));
}

MetadataCloudModel::~MetadataCloudModel()
{
}


void MetadataCloudModel::serviceRegistered(const QString &service)
{
    if (service == "org.kde.nepomuk.services.nepomukqueryservice") {
        delete m_queryClient; //m_queryClient still doesn't fix itself
        doQuery();
    }
}

void MetadataCloudModel::setQuery(const Nepomuk::Query::Query &query)
{
    m_queryTimer->stop();
    m_query = query;

    if (Nepomuk::Query::QueryServiceClient::serviceAvailable()) {
        doQuery();
    }
}

Nepomuk::Query::Query MetadataCloudModel::query() const
{
    return m_query;
}

void MetadataCloudModel::setCloudCategory(MetadataCloudModel::CloudCategory category)
{
    if (m_cloudCategory == category) {
        return;
    }

    m_cloudCategory = category;
    m_queryTimer->start(0);
    emit cloudCategoryChanged();
}

MetadataCloudModel::CloudCategory MetadataCloudModel::cloudCategory() const
{
    return m_cloudCategory;
}

void MetadataCloudModel::setResourceType(const QString &type)
{
    if (m_resourceType == type) {
        return;
    }

    m_resourceType = type;
    m_queryTimer->start(0);
    emit resourceTypeChanged();
}

QString MetadataCloudModel::resourceType() const
{
    return m_resourceType;
}

void MetadataCloudModel::setActivityId(const QString &activityId)
{
    if (m_activityId == activityId) {
        return;
    }

    m_activityId = activityId;
    m_queryTimer->start(0);
    emit activityIdChanged();
}

QString MetadataCloudModel::activityId() const
{
    return m_activityId;
}

void MetadataCloudModel::setTags(const QVariantList &tags)
{
    //FIXME: not exactly efficient
    QStringList stringList = variantToStringList(tags);

    if (m_tags == stringList) {
        return;
    }

    m_tags = stringList;
    m_queryTimer->start(0);
    emit tagsChanged();
}

QVariantList MetadataCloudModel::tags() const
{
    return stringToVariantList(m_sortBy);
}

void MetadataCloudModel::setStartDate(const QDate &date)
{
    if (m_startDate == date) {
        return;
    }

    m_startDate = date;
    m_queryTimer->start(0);
    emit startDateChanged();
}

QDate MetadataCloudModel::startDate() const
{
    return m_startDate;
}

void MetadataCloudModel::setEndDate(const QDate &date)
{
    if (m_endDate == date) {
        return;
    }

    m_endDate = date;
    m_queryTimer->start(0);
    emit endDateChanged();
}

QDate MetadataCloudModel::endDate() const
{
    return m_endDate;
}

void MetadataCloudModel::setRating(int rating)
{
    if (m_rating == rating) {
        return;
    }

    m_rating = rating;
    m_queryTimer->start(0);
    emit ratingChanged();
}

int MetadataCloudModel::rating() const
{
    return m_rating;
}



void MetadataCloudModel::doQuery()
{
    QString query = "select distinct ?label count(*) as ?count where { ";

    switch (m_cloudCategory) {
    case TypeCategory:
        query += " ?r rdf:type ?label";
        break;
    case RatingCategory:
        query += " ?r nao:numericRating ?label";
        break;
    default:
        return;
    }


    if (!m_resourceType.isEmpty() && m_cloudCategory != TypeCategory) {
        query += " . ?r rdf:type " + m_resourceType;
    }

    if (!m_activityId.isEmpty()) {
        Nepomuk::Resource acRes(m_activityId, Nepomuk::Vocabulary::KEXT::Activity());
        query +=  " . <" + acRes.resourceUri().toString() + "> nao:isRelated ?r ";
    }

    foreach (const QString &tag, m_tags) {
        query += " ?r nao:hasTag " + tag;
    }

    if (m_startDate.isValid() || m_endDate.isValid()) {
        query += " . { \
        ?r <http://www.semanticdesktop.org/ontologies/2007/01/19/nie#lastModified> ?v2 . FILTER(?v2>\"" + m_startDate.toString(Qt::ISODate) + "\"^^<http://www.w3.org/2001/XMLSchema#dateTime>) . \
        } UNION {\
        ?r <http://www.semanticdesktop.org/ontologies/2007/01/19/nie#contentCreated> ?v3 . FILTER(?v3>\"" + m_startDate.toString(Qt::ISODate) + "\"^^<http://www.w3.org/2001/XMLSchema#dateTime>) . \
        } UNION {\
        ?v4 <http://www.semanticdesktop.org/ontologies/2010/01/25/nuao#involves> ?r .\
        ?v4 <http://www.semanticdesktop.org/ontologies/2010/01/25/nuao#start> ?v5 .\ FILTER(?v5>\"" + m_startDate.toString(Qt::ISODate) + "\"^^<http://www.w3.org/2001/XMLSchema#dateTime>) . \
        }";
    }

    if (m_rating > 0) {
        query += " . ?r nao:numericRating ?v2 ";
    }

    query +=  " . ?r <http://www.semanticdesktop.org/ontologies/2007/08/15/nao#userVisible> ?v1 . FILTER(?v1>0) .  } group by ?label order by ?label";


    beginResetModel();
    m_results.clear();
    m_uriToResourceIndex.clear();
    endResetModel();
    emit countChanged();

    delete m_queryClient;
    m_queryClient = new Nepomuk::Query::QueryServiceClient(this);

    connect(m_queryClient, SIGNAL(newEntries(const QList<Nepomuk::Query::Result> &)),
            this, SLOT(newEntries(const QList<Nepomuk::Query::Result> &)));
    connect(m_queryClient, SIGNAL(entriesRemoved(const QList<QUrl> &)),
            this, SLOT(entriesRemoved(const QList<QUrl> &)));

    m_queryClient->sparqlQuery(query);
}

void MetadataCloudModel::newEntries(const QList< Nepomuk::Query::Result > &entries)
{
    QVector<QPair<QString, int> > results;
    foreach (Nepomuk::Query::Result res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //kDebug() << "Result label:" << res.genericLabel();

        QString label;
        int count = res.additionalBinding(QLatin1String("count")).variant().toInt();
        QVariant rawLabel = res.additionalBinding(QLatin1String("label")).variant();
        if (rawLabel.canConvert<Nepomuk::Resource>()) {
            label = rawLabel.value<Nepomuk::Resource>().className();
        } else if (rawLabel.canConvert<QUrl>()) {
            label = rawLabel.value<QUrl>().fragment();
        } else if (rawLabel.canConvert<QString>()) {
            label = rawLabel.toString();
        } else if (rawLabel.canConvert<int>()) {
            label = QString::number(rawLabel.toInt());
        } else {
            continue;
        }

        if (label.isEmpty()) {
            continue;
        }
        results << QPair<QString, int>(label, count);
    }
    if (results.count() > 0) {
        beginInsertRows(QModelIndex(), m_results.count(), m_results.count()+results.count());
        m_results << results;
        endInsertRows();
        emit countChanged();
    }
}

void MetadataCloudModel::entriesRemoved(const QList<QUrl> &urls)
{
    //TODO
    emit countChanged();
}



QVariant MetadataCloudModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.column() > 0 ||
        index.row() < 0 || index.row() >= m_results.count()){
        return QVariant();
    }

    const QPair<QString, int> row = m_results[index.row()];

    switch (role) {
    case Label:
        return row.first;
    case Count:
        return row.second;
    default:
        return QVariant();
    }
}

QVariant MetadataCloudModel::headerData(int section, Qt::Orientation orientation,
                                   int role) const
{
    Q_UNUSED(section)
    Q_UNUSED(orientation)
    Q_UNUSED(role)

    return QVariant();
}

QModelIndex MetadataCloudModel::index(int row, int column,
                                 const QModelIndex &parent) const
{
    if (parent.isValid() || column > 0 || row < 0 || row >= rowCount()) {
        return QModelIndex();
    }

    return createIndex(row, column, 0);
}

QModelIndex MetadataCloudModel::parent(const QModelIndex &child) const
{
    Q_UNUSED(child)

    return QModelIndex();
}

int MetadataCloudModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_results.count();
}

int MetadataCloudModel::columnCount(const QModelIndex &parent) const
{
    //no trees
    if (parent.isValid()) {
        return 0;
    }

    return 1;
}

#include "metadatacloudmodel.moc"
