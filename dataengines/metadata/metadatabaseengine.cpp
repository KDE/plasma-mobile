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

#include "activityservice/activityservice.h"
#include "querycontainer.h"

#define RESULT_LIMIT 24

class MetadataBaseEnginePrivate
{
public:
    QSize previewSize;
    KActivityConsumer *activityConsumer;
    QHash<QString, QString> icons;
};


MetadataBaseEngine::MetadataBaseEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent, args)
{
    Q_UNUSED(args);
    d = new MetadataBaseEnginePrivate;
    d->activityConsumer = new KActivityConsumer(this);
    setMaxSourceCount(RESULT_LIMIT); // Guard against loading too many connections
    //init();
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
    //kDebug() << "init.";
}

MetadataBaseEngine::~MetadataBaseEngine()
{
    delete d;
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
            //return false;
            removeSource(s);
        }
    }

    if (name.startsWith('/')) {
        massagedName = "file://" + name;
    }
    //Simple case.. a single resource, don't need a DataContainer
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
        return true;

        QueryContainer *container = qobject_cast<QueryContainer *>(containerForSource(name));
         if (!container) {
             container = new QueryContainer(Nepomuk::Query::Query(), this);
         }
         container->setObjectName(name);
         addSource(container);
         //FIXME: this isn't really pretty
         //TODO: create another type of DataContainer with a common superclass to visualize single resources
         container->addResource(r);
         return true;

    //we want to list all resources liked to the current activity
    } else if (name.startsWith("CurrentActivityResources:")) {

         Nepomuk::Resource acRes("activities://" + name.split(":").last());
         Nepomuk::Query::ComparisonTerm term(Soprano::Vocabulary::NAO::isRelated(), Nepomuk::Query::ResourceTerm(acRes));
         term.setInverted(true);
         Nepomuk::Query::Query query = Nepomuk::Query::Query(term);
         //return query(activityQuery);

         QueryContainer *container = qobject_cast<QueryContainer *>(containerForSource(name));
         if (!container) {
             container = new QueryContainer(query, this);
         }
         container->setObjectName(name);
         addSource(container);
         return true;

    // Let's try a literal query ...
    } else {
        kDebug() << "async search for query:" << name;
        Nepomuk::Query::Query _query = Nepomuk::Query::QueryParser::parseQuery(name);
        //Nepomuk::Query::LiteralTerm nepomukTerm(name);
        //_query.setTerm(nepomukTerm);
        //fileQuery.addIncludeFolder(KUrl("/"), true);
        //return query(fileQuery);
        if (_query.isValid()) {
            QueryContainer *container = qobject_cast<QueryContainer *>(containerForSource(name));
            if (!container) {
                container = new QueryContainer(_query, this);
            }
            container->setObjectName(name);
            addSource(container);
            return true;
        } else {
            kWarning() << "Query is invalid:" << _query;
            return false;
        }
    }
}

Plasma::Service *MetadataBaseEngine::serviceForSource(const QString &source)
{
    //FIXME validate the name
    ActivityService *service = new ActivityService(d->activityConsumer, source);
    service->setParent(this);
    return service;
}



#include "metadatabaseengine.moc"
