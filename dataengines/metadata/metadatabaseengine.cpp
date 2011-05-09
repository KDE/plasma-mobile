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
//#include <Nepomuk/Query/QueryParser>
#include <nepomuk/queryparser.h>
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

#include "metadatabaseengine.h"
#include <stdio.h>

#include <kactivityconsumer.h>

#define RESULT_LIMIT 24

class MetadataBaseEnginePrivate
{
public:
    Nepomuk::Query::QueryServiceClient *queryClient;
    QString query;
    QSize previewSize;
    KActivityConsumer *activityConsumer;
    QHash<QString, QString> icons;
};


MetadataBaseEngine::MetadataBaseEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent, args)
{
    Q_UNUSED(args);
    d = new MetadataBaseEnginePrivate;
    d->queryClient = 0;
    d->activityConsumer = new KActivityConsumer(this);
    setMaxSourceCount(RESULT_LIMIT); // Guard against loading too many connections
    //init();
}

void MetadataBaseEngine::setQuery(const QString& q)
{
    d->query = q;
}

QString MetadataBaseEngine::icon(const QStringList &types)
{
    if (!d->icons.size()) {
        // Add fallback icons here from generic to specific
        // The list of types is also sorted in this way, so
        // we're returning the most specific icon, even with
        // the hardcoded mapping.

        // Files
        //d->icons["FileDataObject"] = QString("audio-x-generic");

        // Audio
        d->icons["Audio"] = QString("audio-x-generic");
        d->icons["MusicPiece"] = QString("audio-x-generic");

        // Images
        d->icons["Image"] = QString("image-x-generic");
        d->icons["RasterImage"] = QString("image-x-generic");

        d->icons["Email"] = QString("internet-mail");
        d->icons["Document"] = QString("kword");
        d->icons["PersonContact"] = QString("x-office-contact");

        // Filesystem
        d->icons["Folder"] = QString("folder");
        d->icons["Website"] = QString("text-html");

        // ... add some more
        // Filesystem
        d->icons["Bookmark"] = QString("bookmarks");
        d->icons["BookmarksFolder"] = QString("bookmarks-organize");
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

void MetadataBaseEngine::init()
{
    kDebug() << "init.";
    d->queryClient = new Nepomuk::Query::QueryServiceClient(this);
    connect(d->queryClient, SIGNAL(newEntries(const QList<Nepomuk::Query::Result> &)),
            this, SLOT(newEntries(const QList<Nepomuk::Query::Result> &)));
}

MetadataBaseEngine::~MetadataBaseEngine()
{
    delete d;
}

bool MetadataBaseEngine::query(Nepomuk::Query::Query &searchQuery)
{
  searchQuery.setLimit(RESULT_LIMIT);
  return d->queryClient->query(searchQuery);
}

QStringList MetadataBaseEngine::sources() const
{
    return QStringList();
}

bool MetadataBaseEngine::sourceRequestEvent(const QString &name)
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
    } else if (name == "CurrentActivityResources:") {
         const QString currentActivityId = d->activityConsumer->currentActivity();
         Nepomuk::Resource acRes("activities://" + currentActivityId);
         Nepomuk::Query::ComparisonTerm term(Soprano::Vocabulary::NAO::isRelated(), Nepomuk::Query::ResourceTerm(acRes));
         term.setInverted(true);
         Nepomuk::Query::Query activityQuery = Nepomuk::Query::Query(term);
         return query(activityQuery);
    } else {
        // Let's try a literal query ...
        kDebug() << "async search for query:" << name;
        Nepomuk::Query::Query _query = Nepomuk::Query::QueryParser::parseQuery(name);
        //Nepomuk::Query::LiteralTerm nepomukTerm(name);
        //_query.setTerm(nepomukTerm);
        //fileQuery.addIncludeFolder(KUrl("/"), true);
        //return query(fileQuery);
        if (_query.isValid()) {
            return query(_query);
        } else {
            kWarning() << "Query is invalid:" << _query;
            return false;
        }
    }
}

void MetadataBaseEngine::newEntries(const QList< Nepomuk::Query::Result >& entries)
{
    foreach (Nepomuk::Query::Result res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //kDebug() << "Result label:" << res.genericLabel();
        Nepomuk::Resource resource = res.resource();
        addResource(resource);
    }
    scheduleSourcesUpdated();
}

void MetadataBaseEngine::addResource(Nepomuk::Resource resource)
{
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
        _icon = icon(QStringList(resource.className()));
        kDebug() << "symbol" << _icon;
    }
    if (_icon.split(",").count() > 1) {
        kDebug() << "More than one icon!" << _icon;
        _icon = _icon.split(",").last();
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
                setData(source, key, resource.property(propertyUrl).variant());
            // More properties


        } else {
            kWarning() << "Could not parse ontology URL, missing '#':" << propertyUrl.toString();
        }
    }
    setData(source, "properties", _properties);
}

#include "metadatabaseengine.moc"
