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

#include "metadatamodel.h"

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

#include <nepomuk/nfo.h>
#include <nepomuk/nie.h>

#include "kext.h"


MetadataModel::MetadataModel(QObject *parent)
    : QAbstractItemModel(parent),
      m_queryClient(0)
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
    roleNames[Description] = "description";
    roleNames[Types] = "types";
    roleNames[ClassName] = "className";
    roleNames[GenericClassName] = "genericClassName";
    roleNames[HasSymbol] = "hasSymbol";
    roleNames[Icon] = "icon";
    roleNames[IsFile] = "isFile";
    roleNames[Exists] = "exists";
    roleNames[Rating] = "rating";
    roleNames[NumericRating] = "numericRating";
    roleNames[Symbols] = "symbols";
    roleNames[ResourceUri] = "resourceUri";
    roleNames[ResourceType] = "resourceType";
    roleNames[Url] = "url";
    roleNames[Topics] = "topics";
    roleNames[TopicsNames] = "topicsNames";
    roleNames[Tags] = "tags";
    roleNames[TagsNanes] = "tagsNanes";
    setRoleNames(roleNames);

    m_queryServiceWatcher = new QDBusServiceWatcher(QLatin1String("org.kde.nepomuk.services.nepomukqueryservice"),
                        QDBusConnection::sessionBus(),
                        QDBusServiceWatcher::WatchForRegistration,
                        this);
    connect(m_queryServiceWatcher, SIGNAL(serviceRegistered(QString)), this, SLOT(serviceRegistered(QString)));
}

MetadataModel::~MetadataModel()
{
}


void MetadataModel::serviceRegistered(const QString &service)
{
    if (service == "org.kde.nepomuk.services.nepomukqueryservice") {
        delete m_queryClient; //m_queryClient still doesn't fix itself
        doQuery();
    }
}

void MetadataModel::setQuery(const Nepomuk::Query::Query &query)
{
    m_queryTimer->stop();
    m_query = query;

    if (Nepomuk::Query::QueryServiceClient::serviceAvailable()) {
        doQuery();
    }
}

Nepomuk::Query::Query MetadataModel::query() const
{
    return m_query;
}

void MetadataModel::setQueryString(const QString &query)
{
    if (query == m_queryString) {
        return;
    }

    m_queryString = query;
    m_queryTimer->start(0);
    emit queryStringChanged();
}

QString MetadataModel::queryString() const
{
    return m_queryString;
}

void MetadataModel::setResourceType(const QString &type)
{
    if (m_resourceType == type) {
        return;
    }

    m_resourceType = type;
    m_queryTimer->start(0);
    emit resourceTypeChanged();
}

QString MetadataModel::resourceType() const
{
    return m_resourceType;
}

void MetadataModel::setActivityId(const QString &activityId)
{
    if (m_activityId == activityId) {
        return;
    }

    m_activityId = activityId;
    m_queryTimer->start(0);
    emit activityIdChanged();
}

QString MetadataModel::activityId() const
{
    return m_activityId;
}


void MetadataModel::doQuery()
{
    m_query = Nepomuk::Query::Query();
    m_query.setQueryFlags(Nepomuk::Query::Query::WithoutFullTextExcerpt);
    Nepomuk::Query::AndTerm rootTerm;

    if (!m_queryString.isEmpty()) {
        rootTerm.addSubTerm(Nepomuk::Query::QueryParser::parseQuery(m_queryString).term());
    }

    if (!m_resourceType.isEmpty()) {
        //FIXME: more elegant
        if (m_resourceType == "Contact") {
            rootTerm.addSubTerm(Nepomuk::Query::ResourceTypeTerm(QUrl("http://www.semanticdesktop.org/ontologies/2007/03/22/nco#"+m_resourceType)));
        } else if (m_resourceType == "Video") {
            // Strigi doesn't index videos it seems
            rootTerm.addSubTerm(Nepomuk::Query::ComparisonTerm(Nepomuk::Vocabulary::NIE::mimeType(), Nepomuk::Query::LiteralTerm("video")));
        } else if (m_resourceType == "OpenDocumentTextDocument") {
            rootTerm.addSubTerm(Nepomuk::Query::ComparisonTerm(Nepomuk::Vocabulary::NIE::mimeType(), Nepomuk::Query::LiteralTerm("vnd.oasis.opendocument.text")));
        } else {
            rootTerm.addSubTerm(Nepomuk::Query::ResourceTypeTerm(QUrl("http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#"+m_resourceType)));
        }
    }

    if (!m_activityId.isEmpty()) {
        kDebug() << "Asking for resources of activity" << m_activityId;
        Nepomuk::Resource acRes(m_activityId, Nepomuk::Vocabulary::KEXT::Activity());
        Nepomuk::Query::ComparisonTerm term(Soprano::Vocabulary::NAO::isRelated(), Nepomuk::Query::ResourceTerm(acRes));
        term.setInverted(true);
        rootTerm.addSubTerm(term);
    }

    //TODO: configurable sorting
    Nepomuk::Query::ComparisonTerm sortTerm(Soprano::Vocabulary::NAO::lastModified(), Nepomuk::Query::Term());
    sortTerm.setSortWeight(1, Qt::DescendingOrder);
    rootTerm.addSubTerm(sortTerm);

    m_query.setTerm(rootTerm);



    beginResetModel();
    m_resources.clear();
    m_uriToResourceIndex.clear();
    endResetModel();
    emit countChanged();

    delete m_queryClient;
    m_queryClient = new Nepomuk::Query::QueryServiceClient(this);

    connect(m_queryClient, SIGNAL(newEntries(const QList<Nepomuk::Query::Result> &)),
            this, SLOT(newEntries(const QList<Nepomuk::Query::Result> &)));
    connect(m_queryClient, SIGNAL(entriesRemoved(const QList<QUrl> &)),
            this, SLOT(entriesRemoved(const QList<QUrl> &)));

    /*FIXME: safe without limit?
    if (limit > RESULT_LIMIT || limit <= 0) {
        m_query.setLimit(RESULT_LIMIT);
    }
    */

    m_queryClient->query(m_query);
}

void MetadataModel::newEntries(const QList< Nepomuk::Query::Result > &entries)
{
    beginInsertRows(QModelIndex(), m_resources.count(), m_resources.count()+entries.count());

    foreach (Nepomuk::Query::Result res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //kDebug() << "Result label:" << res.genericLabel();
        m_uriToResourceIndex[res.resource().resourceUri()] = m_resources.count();
        m_resources << res.resource();
    }
    endInsertRows();
    emit countChanged();
}

void MetadataModel::entriesRemoved(const QList<QUrl> &urls)
{
    int prevIndex = -100;
    //pack all the stuff to remove in groups, to emit the least possible signals
    //this assumes urls are in the same order they arrived ion the results
    //it's a map because we want to remove values from the vector in inverted order to keep indexes valid trough the remove loop
    QMap<int, int> toRemove;
    foreach (const QUrl &url, urls) {
        const int index = m_uriToResourceIndex.value(url);
        if (index == prevIndex + 1) {
            toRemove[prevIndex]++;
        } else {
            toRemove[index] = 1;
        }
        prevIndex = index;
    }

    QMap<int, int>::const_iterator i = toRemove.constEnd();
    --i;
    do {
        beginRemoveRows(QModelIndex(), i.key(), i.key()+i.value());
        m_resources.remove(i.key(), i.value());
        endRemoveRows();
        --i;
    } while (i != toRemove.constBegin());

    //another loop, we don't depend to m_uriToResourceIndex in data(), but we take this doublesafety
    foreach (const QUrl &url, urls) {
        m_uriToResourceIndex.remove(url);
    }
    emit countChanged();
}



QVariant MetadataModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.column() > 0 ||
        index.row() < 0 || index.row() >= m_resources.count()){
        return QVariant();
    }

    const Nepomuk::Resource &resource = m_resources[index.row()];

    switch (role) {
    case Label:
        return resource.label();
    case Description:
        return resource.description();
    case Types: {
        QStringList types;
        foreach (const QUrl &u, resource.types()) {
            types << u.toString();
        }
        return types;
    }
    case ClassName:
        return resource.className();
    case GenericClassName: {
        //FIXME: a more elegant way is needed
        QString genericClassName = resource.className();
        Nepomuk::Types::Class resClass(resource.resourceType());
        foreach (Nepomuk::Types::Class parentClass, resClass.parentClasses()) {
            if (parentClass.label() == "Document" ||
                parentClass.label() == "Audio" ||
                parentClass.label() == "Video" ||
                parentClass.label() == "Image" ||
                parentClass.label() == "Contact") {
                genericClassName = parentClass.label();
                break;
            //two cases where the class is 2 levels behind the level of generalization we want
            } else if (parentClass.label() == "RasterImage") {
                genericClassName = "Image";
            } else if (parentClass.label() == "TextDocument") {
                genericClassName = "Document";
            }
        }
        return genericClassName;
    }
    case HasSymbol:
    case Icon: {
        QString icon = resource.genericIcon();
        if (icon.isEmpty() && resource.isFile()) {
            KUrl url = resource.toFile().url();
            if (!url.isEmpty()) {
                icon = KMimeType::iconNameForUrl(url);
            }
        }
        if (icon.isEmpty()) {
            // use resource types to find a suitable icon.
            //TODO
            icon = retrieveIconName(QStringList(resource.className()));
            //kDebug() << "symbol" << icon;
        }
        if (icon.split(",").count() > 1) {
            kDebug() << "More than one icon!" << icon;
            icon = icon.split(",").last();
        }
        return icon;
    }
    case IsFile:
        return resource.isFile();
    case Exists:
        return resource.exists();
    case Rating:
        return resource.rating();
    case NumericRating:
        return resource.property(QUrl("http://www.semanticdesktop.org/ontologies/2007/08/15/nao#numericRating")).toString();
    case Symbols:
        return resource.symbols();
    case ResourceUri:
        return resource.resourceUri();
    case ResourceType:
        return resource.resourceType();
    case Url: {
        if (resource.isFile() && resource.toFile().url().isLocalFile()) {
            return resource.toFile().url().prettyUrl();
        } else {
            return resource.property(QUrl("http://www.semanticdesktop.org/ontologies/2007/01/19/nie#url")).toString();
        }
    }
    case Topics: {
        QStringList topics;
        foreach (const Nepomuk::Resource &u, resource.topics()) {
            topics << u.resourceUri().toString();
        }
        return topics;
    }
    case TopicsNames: {
        QStringList topicNames;
        foreach (const Nepomuk::Resource &u, resource.topics()) {
            topicNames << u.genericLabel();
        }
        return topicNames;
    }
    case Tags: {
        QStringList tags;
        foreach (const Nepomuk::Tag &tag, resource.tags()) {
            tags << tag.resourceUri().toString();
        }
        return tags;
    }
    case TagsNanes: {
        QStringList tagNames;
        foreach (const Nepomuk::Tag &tag, resource.tags()) {
            tagNames << tag.genericLabel();
        }
        return tagNames;
    }
    default:
        return QVariant();
    }
}

QVariant MetadataModel::headerData(int section, Qt::Orientation orientation,
                                   int role) const
{
    Q_UNUSED(section)
    Q_UNUSED(orientation)
    Q_UNUSED(role)

    return QVariant();
}

QModelIndex MetadataModel::index(int row, int column,
                                 const QModelIndex &parent) const
{
    if (parent.isValid() || column > 0 || row < 0 || row >= rowCount()) {
        return QModelIndex();
    }

    return createIndex(row, column, 0);
}

QModelIndex MetadataModel::parent(const QModelIndex &child) const
{
    Q_UNUSED(child)

    return QModelIndex();
}

int MetadataModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_resources.count();
}

int MetadataModel::columnCount(const QModelIndex &parent) const
{
    //no trees
    if (parent.isValid()) {
        return 0;
    }

    return 1;
}


QString MetadataModel::retrieveIconName(const QStringList &types) const
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

#include "metadatamodel.moc"
