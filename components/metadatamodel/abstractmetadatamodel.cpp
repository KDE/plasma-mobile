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

#include "abstractmetadatamodel.h"

#include <QDBusConnection>
#include <QDBusServiceWatcher>
#include <QTimer>

#include <KDebug>
#include <KMimeType>

#include <Nepomuk/ResourceManager>

AbstractMetadataModel::AbstractMetadataModel(QObject *parent)
    : QAbstractItemModel(parent),
      m_status(Idle),
      m_minimumRating(0),
      m_maximumRating(0)
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


    connect(this, SIGNAL(rowsInserted(const QModelIndex &, int, int)),
            this, SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsRemoved(const QModelIndex &, int, int)),
            this, SIGNAL(countChanged()));
    connect(this, SIGNAL(modelReset()),
            this, SIGNAL(countChanged()));


    m_queryTimer = new QTimer(this);
    m_queryTimer->setSingleShot(true);
    if (Nepomuk::ResourceManager::instance()->initialized()) {
        connect(m_queryTimer, SIGNAL(timeout()),
                this, SLOT(doQuery()));
    }

    m_extraParameters = new QDeclarativePropertyMap;
    connect (m_extraParameters, SIGNAL(valueChanged(QString, QVariant)), m_queryTimer, SLOT(start()));

    m_queryServiceWatcher = new QDBusServiceWatcher(QLatin1String("org.kde.nepomuk.services.nepomukqueryservice"),
                        QDBusConnection::sessionBus(),
                        QDBusServiceWatcher::WatchForRegistration,
                        this);
    connect(m_queryServiceWatcher, SIGNAL(serviceRegistered(QString)), this, SLOT(serviceRegistered(QString)));
}

AbstractMetadataModel::~AbstractMetadataModel()
{
    delete m_extraParameters;
}


void AbstractMetadataModel::serviceRegistered(const QString &service)
{
    if (service == "org.kde.nepomuk.services.nepomukqueryservice") {
        disconnect(m_queryTimer, SIGNAL(timeout()),
                this, SLOT(doQuery()));
        connect(m_queryTimer, SIGNAL(timeout()),
                this, SLOT(doQuery()));
        doQuery();
    }
}

void AbstractMetadataModel::setResourceType(const QString &type)
{
    if (m_resourceType == type) {
        return;
    }

    m_resourceType = type;
    m_queryTimer->start(0);
    emit resourceTypeChanged();
}

QString AbstractMetadataModel::resourceType() const
{
    return m_resourceType;
}

void AbstractMetadataModel::setMimeType(const QString &type)
{
    if (m_mimeType == type) {
        return;
    }

    m_mimeType = type;
    m_queryTimer->start(0);
    emit mimeTypeChanged();
}

QString AbstractMetadataModel::mimeType() const
{
    return m_mimeType;
}

void AbstractMetadataModel::setActivityId(const QString &activityId)
{
    if (m_activityId == activityId) {
        return;
    }

    m_activityId = activityId;
    m_queryTimer->start(0);
    emit activityIdChanged();
}

QString AbstractMetadataModel::activityId() const
{
    return m_activityId;
}

void AbstractMetadataModel::setTags(const QVariantList &tags)
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

QVariantList AbstractMetadataModel::tags() const
{
    return stringToVariantList(m_tags);
}

QStringList AbstractMetadataModel::tagStrings() const
{
    return m_tags;
}

AbstractMetadataModel::Status AbstractMetadataModel::status() const
{
    return m_status;
}

void AbstractMetadataModel::setStatus(AbstractMetadataModel::Status status)
{
    if (status == m_status) {
        return;
    }

    m_status = status;
    emit statusChanged();
}

void AbstractMetadataModel::setStartDate(const QDate &date)
{
    if (m_startDate == date) {
        return;
    }

    m_startDate = date;
    m_queryTimer->start(0);
    emit startDateChanged();
}

QDate AbstractMetadataModel::startDate() const
{
    return m_startDate;
}

void AbstractMetadataModel::setEndDate(const QDate &date)
{
    if (m_endDate == date) {
        return;
    }

    m_endDate = date;
    m_queryTimer->start(0);
    emit endDateChanged();
}

QDate AbstractMetadataModel::endDate() const
{
    return m_endDate;
}

void AbstractMetadataModel::setMinimumRating(int rating)
{
    if (m_minimumRating == rating) {
        return;
    }

    m_minimumRating = rating;
    m_queryTimer->start(0);
    emit minimumRatingChanged();
}

int AbstractMetadataModel::minimumRating() const
{
    return m_minimumRating;
}

void AbstractMetadataModel::setMaximumRating(int rating)
{
    if (m_maximumRating == rating) {
        return;
    }

    m_maximumRating = rating;
    m_queryTimer->start(0);
    emit maximumRatingChanged();
}

int AbstractMetadataModel::maximumRating() const
{
    return m_maximumRating;
}

QObject *AbstractMetadataModel::extraParameters() const
{
    return m_extraParameters;
}



void AbstractMetadataModel::doQuery()
{
    //Abstract, implement in subclasses
}




QVariant AbstractMetadataModel::headerData(int section, Qt::Orientation orientation,
                                   int role) const
{
    Q_UNUSED(section)
    Q_UNUSED(orientation)
    Q_UNUSED(role)

    return QVariant();
}

QModelIndex AbstractMetadataModel::index(int row, int column,
                                 const QModelIndex &parent) const
{
    if (parent.isValid() || column != 0 || row < 0 || row >= rowCount()) {
        return QModelIndex();
    }

    return createIndex(row, column, 0);
}

QModelIndex AbstractMetadataModel::parent(const QModelIndex &child) const
{
    Q_UNUSED(child)

    return QModelIndex();
}

int AbstractMetadataModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return count();
}

int AbstractMetadataModel::columnCount(const QModelIndex &parent) const
{
    //no trees
    if (parent.isValid()) {
        return 0;
    }

    return 1;
}


QString AbstractMetadataModel::retrieveIconName(const QStringList &types) const
{
    // keep searching until the most specific icon is found
    QString _icon = "nepomuk";
    foreach(const QString &t, types) {
        QString shortType = t.split('#').last();
        if (shortType.isEmpty()) {
            shortType = t;
        }
        if (m_icons.keys().contains(shortType)) {
            _icon = m_icons[shortType];
            //kDebug() << "found icon for type" << shortType << _icon;
        }
    }
    return _icon;
}

#include "abstractmetadatamodel.moc"
