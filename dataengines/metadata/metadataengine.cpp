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

class MetadataEngineprivate
{
public:
    Nepomuk::Query::QueryServiceClient *queryClient;
    QString query;
    QSize previewSize;
};


MetadataEngine::MetadataEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent)
{
    Q_UNUSED(args);
    d = new MetadataEngineprivate;
    d->queryClient = 0;
    setMaxSourceCount(24); // Guard against loading too many connections
    init();
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
    d->query = name;
    if (name.split("://").count() > 1) {
        // We have a URL here, so we can create the results directly
        kDebug() << "Valid url ... creating resource synchronously";
        KUrl u = KUrl(name);
        Nepomuk::Resource r(u);
        kDebug() << r.resourceUri();
        addResource(r);
        return true;
    } else {
        // Let's try a random query ...
        Nepomuk::Query::Query fileQuery;
        Nepomuk::Query::LiteralTerm nepomukTerm(name);
        fileQuery.setTerm(nepomukTerm);
        //fileQuery.addIncludeFolder(KUrl("/"), true);
        fileQuery.setLimit(512);

        kDebug() << "file search for query:" << name;
        d->queryClient->query(fileQuery);
        //setData(name, Plasma::DataEngine::Data());
        return true;
    }
}

void MetadataEngine::newEntries(const QList< Nepomuk::Query::Result >& entries)
{
    foreach (Nepomuk::Query::Result res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        kDebug() << "Result Excerpt:" << res.excerpt();
        Nepomuk::Resource resource = res.resource();
        addResource(resource);
    }
    scheduleSourcesUpdated();
}

void MetadataEngine::addResource(Nepomuk::Resource resource)
{
    QString uri = resource.resourceUri().toString();
    // If we didn't explicitely search for a nepomuk:// url, let's add the query
    // to the parameters
    QString source  = uri;
    if (uri != d->query) {
        source  = uri + "&query=" + d->query;
    }

    QString desc = resource.description();
    if (desc.isEmpty()) {
        desc = "Empty description.";
    }
    QString label = resource.label();
    if (label.isEmpty()) {
        label = "Empty label.";
    }

    setData(source, "label", label);
    setData(source, "description", desc);

    setData(source, "isFile", resource.isFile());
    setData(source, "rating", resource.rating());

    //setData(source, "resourceType", resource.resourceType());
    setData(source, "resourceUri", resource.resourceUri());
    setData(source, "resourceType", resource.resourceType());



    // Dynamic properties
    QHash<QUrl, Nepomuk::Variant> props = resource.properties();
    foreach(const QUrl &propertyUrl, props.keys()) {
        QStringList _l = propertyUrl.toString().split('#');
        if (_l.count() > 1) {
            QString key = _l[1];
            //kDebug() << " ... " << key << propertyUrl << resource.property(propertyUrl).variant();
            setData(source, key, resource.property(propertyUrl).variant());
            setData(source, "query", d->query);
            // More properties



        } else {
            kWarning() << "Could not parse ontology URL, missing '#':" << propertyUrl.toString();
        }
    }
}

#include "metadataengine.moc"
