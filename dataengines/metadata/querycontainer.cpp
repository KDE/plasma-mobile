/*
    Copyright 2011 Marco Martin <mart@kde.org>
    Copyright 2011 Sebastian Kügler <sebas@kde.org>

    This library is free software; you can redistribute it and/or modify it
    under the terms of the GNU Library General Public License as published by
    the Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    This library is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public
    License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
    02110-1301, USA.
*/

#include "querycontainer.h"

#include <Nepomuk/Tag>
#include <Nepomuk/Variant>

#define RESULT_LIMIT 24

QueryContainer::QueryContainer(const Nepomuk::Query::Query &query, QObject *parent)
    : Plasma::DataContainer(parent),
      m_query(query)
{
    m_queryClient = new Nepomuk::Query::QueryServiceClient(this);

    connect(m_queryClient, SIGNAL(newEntries(const QList<Nepomuk::Query::Result> &)),
            this, SLOT(newEntries(const QList<Nepomuk::Query::Result> &)));
    connect(m_queryClient, SIGNAL(entriesRemoved(const QList<QUrl> &)),
            this, SLOT(entriesRemoved(const QList<QUrl> &)));

    m_query.setLimit(RESULT_LIMIT);
    m_queryClient->query(m_query);
}

void QueryContainer::newEntries(const QList< Nepomuk::Query::Result >& entries)
{
    foreach (Nepomuk::Query::Result res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //kDebug() << "Result label:" << res.genericLabel();
        Nepomuk::Resource resource = res.resource();
        addResource(resource);
    }
    checkForUpdate();
}

void QueryContainer::entriesRemoved(const QList<QUrl> &urls)
{
    foreach (const QUrl &url, urls) {
        setData(url.toString(), QVariant());
    }
    checkForUpdate();
}

void QueryContainer::addResource(Nepomuk::Resource resource)
{
    QString uri = resource.resourceUri().toString();
    // If we didn't explicitely search for a nepomuk:// url, let's add the query
    // to the parameters
    QString source  = uri;
    /*if (uri != m_query) {
        source  = uri + "&query=" + m_query;
    }*/

    QString desc = resource.genericDescription();
    if (desc.isEmpty()) {
        desc = resource.className();
    }
    QString label = resource.genericLabel();
    if (label.isEmpty()) {
        label = "Empty label.";
    }

    Plasma::DataEngine::Data data;
    data["label"] = label;
    data["description"] = desc;

    // Types
    QStringList _types;
    foreach (const QUrl &u, resource.types()) {
        _types << u.toString();
    }

    data["types"] = _types;

    QString _icon = resource.genericIcon();
    if (_icon.isEmpty()) {
        // use resource types to find a suitable icon.
        //TODO
        _icon = icon(QStringList(resource.className()));
        kDebug() << "symbol" << _icon;
    }
    if (_icon.split(",").count() > 1) {
        kDebug() << "More than one icon!" << _icon;
        _icon = _icon.split(",").last();
    }

    data["icon"] = _icon;
    data["hasSymbol"] = _icon;
    data["isFile"] = resource.isFile();
    data["exists"] = resource.exists();
    data["rating"] = resource.rating();
    data["symbols"] = resource.rating();

    data["className"] = resource.className();
    data["resourceUri"] = resource.resourceUri();
    data["resourceType"] = resource.resourceType();
    data["query"] = objectName();


    // Topics
    QStringList _topics, _topicNames;
    foreach (const Nepomuk::Resource &u, resource.topics()) {
        _topics << u.resourceUri().toString();
        _topicNames << u.genericLabel();
    }
    data["topics"] = _topics;
    data["topicNames"] = _topicNames;

    // Tags
    QStringList _tags, _tagNames;
    foreach (const Nepomuk::Tag &tag, resource.tags()) {
        _tags << tag.resourceUri().toString();
        _tagNames << tag.genericLabel();
    }
    data["tags"] = _tags;
    data["tagNames"] = _tagNames;

    // Related
    QStringList _relateds;
    foreach (const Nepomuk::Resource &res, resource.isRelateds()) {
        _relateds << res.resourceUri().toString();
    }
    data["relateds"] = _relateds;

    // Dynamic properties
    QStringList _properties;
    QHash<QUrl, Nepomuk::Variant> props = resource.properties();
    foreach(const QUrl &propertyUrl, props.keys()) {
        QStringList _l = propertyUrl.toString().split('#');
        if (_l.count() > 1) {
            QString key = _l[1];
            _properties << key;
            //QString from = dynamic_cast<QList<QUrl>();
            if (resource.property(propertyUrl).variant().canConvert(QVariant::List)) {
                QVariantList tl = resource.property(propertyUrl).variant().toList();
                foreach (QVariant vu, tl) {
                    kDebug() << vu.toString().startsWith("nepomuk:") << vu.toString().startsWith("akonadi:") << vu.toString();
                    if (vu.canConvert(QVariant::Url) &&
                        (vu.toString().startsWith("nepomuk:") || vu.toString().startsWith("akonadi:"))) {
                        kDebug() <<  "HHH This is a list.!!!" << key << vu.toString();
                    }
                }
            }
            //kDebug() << " ... " << key << propertyUrl << resource.property(propertyUrl).variant();
            if (key != "plainTextMessageContent")
                data[key] = resource.property(propertyUrl).variant();
            // More properties


        } else {
            kWarning() << "Could not parse ontology URL, missing '#':" << propertyUrl.toString();
        }
    }
    data["properties"] = _properties;
    setData(source, data);
}

QString QueryContainer::icon(const QStringList &types)
{
    if (!m_icons.size()) {
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
        m_icons["Folder"] = QString("folder");
        m_icons["Website"] = QString("text-html");

        // ... add some more
        // Filesystem
        m_icons["Bookmark"] = QString("bookmarks");
        m_icons["BookmarksFolder"] = QString("bookmarks-organize");

        m_icons["FileDataObject"] = QString("unknown");
        m_icons["PaginatedTextDocument"] = QString("application-pdf");
        m_icons["Presentation"] = QString("application-vnd.oasis.opendocument.presentation");
        m_icons["TextDocument"] = QString("text-enriched");
    }

    // keep searching until the most specific icon is found
    QString _icon = "nepomuk";
    foreach(const QString &t, types) {
        QString shortType = t.split('#').last();
        if (shortType.isEmpty()) {
            shortType = t;
        }
        if (m_icons.keys().contains(shortType)) {
            _icon = m_icons[shortType];
            kDebug() << "found icon for type" << shortType << _icon;
        }
    }
    return _icon;
}

#include "querycontainer.moc"

