/*
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

// Nepomuk
#include <Nepomuk/Resource>
#include <Nepomuk/Variant>
#include <Nepomuk/Query/ResourceTerm>
#include <Nepomuk/Tag>

#include <Nepomuk/Query/Query>
#include <Nepomuk/Query/FileQuery>
#include <Nepomuk/Query/QueryServiceClient>
#include <Nepomuk/Query/Result>

#include <soprano/queryresultiterator.h>
#include <soprano/model.h>
#include <soprano/vocabulary.h>

#include <nepomuk/andterm.h>
#include <nepomuk/orterm.h>
#include <nepomuk/comparisonterm.h>
#include <nepomuk/literalterm.h>
#include <nepomuk/resourcetypeterm.h>

#include "metadataengine.h"
#include <stdio.h>

#define RESULT_LIMIT 10

class MetadataEngineprivate
{
public:
    Nepomuk::Query::QueryServiceClient *queryClient;
    QString query;
    QSize previewSize;
    QHash<QString, QString> icons;
};


MetadataEngine::MetadataEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent)
{
    Q_UNUSED(args);
    d = new MetadataEngineprivate;
    d->queryClient = 0;
    setMaxSourceCount(RESULT_LIMIT); // Guard against loading too many connections
    init();
}

QString MetadataEngine::icon(const QStringList &types)
{
    if (!d->icons.size()) {
        // Add fallback icons here from generic to specific
        // The list of types is also sorted in this way, so
        // we're returning the most specific icon, even with
        // the hardcoded mapping.

        // Files
        d->icons["FileDataObject"] = QString("audio-x-generic");

        // Audio
        d->icons["Audio"] = QString("audio-x-generic");
        d->icons["MusicPiece"] = QString("audio-x-generic");

        // Images
        d->icons["Image"] = QString("image-x-generic");
        d->icons["RasterImage"] = QString("image-x-generic");

        d->icons["Email"] = QString("internet-mail");

        // ... add some more
    }

    // keep searching until the most specific icon is found
    QString _icon = "nepomuk";
    foreach(const QString &t, types) {
        QString shortType = t.split('#').last();
        if (d->icons.keys().contains(shortType)) {
            _icon = d->icons[shortType];
            kDebug() << "found icon for type" << shortType << _icon;
        }
    }
    return _icon;
}

void MetadataEngine::init()
{
    kDebug() << "init.";
    d->queryClient = new Nepomuk::Query::QueryServiceClient(this);
    connect(d->queryClient, SIGNAL(newEntries(const QList<Nepomuk::Query::Result> &)),
            this, SLOT(newEntries(const QList<Nepomuk::Query::Result> &)));
}

MetadataEngine::~MetadataEngine()
{
    delete d;
}

QStringList MetadataEngine::sources() const
{
    return QStringList();
}

bool MetadataEngine::sourceRequestEvent(const QString &name)
{
    QString massagedName = name;
    foreach (const QString &s, Plasma::DataEngine::sources()) {
        if (s.startsWith(name) || s.endsWith(name)) {
            kDebug() << "!!! resource already exists." << name;
            return false;
        }
    }
    d->query = name;
    if (name.startsWith('/')) {
        massagedName = "file://" + name;
    }
    if (massagedName.split("://").count() > 1) {
        // We have a URL here, so we can create the results directly
        kDebug() << "Valid url ... creating resource synchronously";
        KUrl u = KUrl(massagedName);
        Nepomuk::Resource r(u);
        kDebug() << r.resourceUri();
        if (!r.exists()) {
            kDebug() << "Resource " << u << " does not exist.";
            return false;
        }
        addResource(r);
        return true;
    } else {
        // Let's try a literal query ...
        kDebug() << "async search for query:" << name;
        Nepomuk::Query::Query fileQuery;
        Nepomuk::Query::LiteralTerm nepomukTerm(name);
        fileQuery.setTerm(nepomukTerm);
        //fileQuery.addIncludeFolder(KUrl("/"), true);
        fileQuery.setLimit(RESULT_LIMIT);

        d->queryClient->query(fileQuery);
        return true;
    }
}

void MetadataEngine::newEntries(const QList< Nepomuk::Query::Result >& entries)
{
    foreach (Nepomuk::Query::Result res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //kDebug() << "Result label:" << res.genericLabel();
        Nepomuk::Resource resource = res.resource();
        addResource(resource);
    }
    scheduleSourcesUpdated();
}

void MetadataEngine::addResource(Nepomuk::Resource resource)
{
    kDebug() << "ADDD " << resource.resourceUri().toString();
    QString uri = resource.resourceUri().toString();
    // If we didn't explicitely search for a nepomuk:// url, let's add the query
    // to the parameters
    QString source  = uri;
    if (uri != d->query) {
        source  = uri + "&query=" + d->query;
    }

    QString desc = resource.genericDescription();
    if (desc.isEmpty()) {
        desc = resource.className();
    }
    QString label = resource.genericLabel();
    if (label.isEmpty()) {
        label = "Empty label.";
    }

    setData(source, "label", label);
    setData(source, "description", desc);

    // Types
    QStringList _types;
    foreach (const QUrl &u, resource.types()) {
        _types << u.toString();
    }
    setData(source, "types", _types);

    QString _icon = resource.genericIcon();
    if (_icon.isEmpty()) {
        // use resource types to find a suitable icon.
        _icon = icon(_types);
        kDebug() << "symbol" << _icon;
    }
    setData(source, "icon", _icon);
    setData(source, "hasSymbol", _icon);
    setData(source, "isFile", resource.isFile());
    setData(source, "exists", resource.exists());
    setData(source, "rating", resource.rating());
    setData(source, "symbols", resource.rating());

    setData(source, "className", resource.className());
    setData(source, "resourceUri", resource.resourceUri());
    setData(source, "resourceType", resource.resourceType());
    setData(source, "query", d->query);


    // Topics
    QStringList _topics, _topicNames;
    foreach (const Nepomuk::Resource &u, resource.topics()) {
        _topics << u.resourceUri().toString();
        _topicNames << u.genericLabel();
    }
    setData(source, "topics", _topics);
    setData(source, "topicNames", _topicNames);

    // Tags
    QStringList _tags, _tagNames;
    foreach (const Nepomuk::Tag &tag, resource.tags()) {
        _tags << tag.resourceUri().toString();
        _tagNames << tag.genericLabel();
    }
    setData(source, "tags", _tags);
    setData(source, "tagNames", _tagNames);

    // Related
    QStringList _relateds;
    foreach (const Nepomuk::Resource &res, resource.isRelateds()) {
        _relateds << res.resourceUri().toString();
    }
    setData(source, "relateds", _relateds);

    // Dynamic properties
    QStringList _properties;
    QHash<QUrl, Nepomuk::Variant> props = resource.properties();
    foreach(const QUrl &propertyUrl, props.keys()) {
        QStringList _l = propertyUrl.toString().split('#');
        if (_l.count() > 1) {
            QString key = _l[1];
            _properties << key;
            //kDebug() << " ... " << key << propertyUrl << resource.property(propertyUrl).variant();
            setData(source, key, resource.property(propertyUrl).variant());
            // More properties


        } else {
            kWarning() << "Could not parse ontology URL, missing '#':" << propertyUrl.toString();
        }
    }
    setData(source, "aproperties", _properties);
}

#include "metadataengine.moc"
