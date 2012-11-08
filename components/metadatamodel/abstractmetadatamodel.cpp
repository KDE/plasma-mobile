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
#include <QDBusConnectionInterface>
#include <QTimer>

#include <KDebug>
#include <KMimeType>

#include <Nepomuk2/ResourceManager>

AbstractMetadataModel::AbstractMetadataModel(QObject *parent)
    : QAbstractItemModel(parent),
      m_running(false),
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


    connect(this, SIGNAL(rowsInserted(QModelIndex,int,int)),
            this, SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsRemoved(QModelIndex,int,int)),
            this, SIGNAL(countChanged()));
    connect(this, SIGNAL(modelReset()),
            this, SIGNAL(countChanged()));


    m_queryTimer = new QTimer(this);
    m_queryTimer->setInterval(0);
    m_queryTimer->setSingleShot(true);

    m_extraParameters = new QDeclarativePropertyMap;
    connect (m_extraParameters, SIGNAL(valueChanged(QString,QVariant)), m_queryTimer, SLOT(start()));

    m_queryServiceWatcher = new QDBusServiceWatcher(QLatin1String("org.kde.nepomuk.services.nepomukqueryservice"),
                        QDBusConnection::sessionBus(),
                        QDBusServiceWatcher::WatchForRegistration,
                        this);
    connect(m_queryServiceWatcher, SIGNAL(serviceRegistered(QString)), this, SLOT(serviceRegistered(QString)));


    QDBusConnectionInterface* interface = m_queryServiceWatcher->connection().interface();

    if (interface->isServiceRegistered("org.kde.nepomuk.services.nepomukqueryservice")) {
        connect(m_queryTimer, SIGNAL(timeout()), this, SLOT(doQuery()));
    }
}

AbstractMetadataModel::~AbstractMetadataModel()
{
    delete m_extraParameters;
}


void AbstractMetadataModel::serviceRegistered(const QString &service)
{
    if (service == QLatin1String("org.kde.nepomuk.services.nepomukqueryservice")) {
        disconnect(m_queryTimer, SIGNAL(timeout()), this, SLOT(doQuery()));
        connect(m_queryTimer, SIGNAL(timeout()), this, SLOT(doQuery()));
        doQuery();
    }
}

bool AbstractMetadataModel::isRunning() const
{
    return m_running;
}

void AbstractMetadataModel::setRunning(bool running)
{
    if (running == m_running) {
        return;
    }

    m_running = running;
    emit runningChanged(running);
}

void AbstractMetadataModel::requestRefresh()
{
    m_queryTimer->start();
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
