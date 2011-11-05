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

#include <QDBusConnection>
#include <QDBusServiceWatcher>

// Nepomuk
#include <Nepomuk/Resource>
#include <Nepomuk/Variant>
//#include <Nepomuk/Query/QueryParser>
#include <nepomuk/queryparser.h>
#include <Nepomuk/Query/ResourceTerm>
#include <Nepomuk/Query/ComparisonTerm>
#include <Nepomuk/Tag>

#include <Nepomuk/Query/Query>
#include <Nepomuk/Query/FileQuery>
#include <Nepomuk/Query/QueryServiceClient>
#include <Nepomuk/Query/Result>
#include <Nepomuk/ResourceManager>

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

#include <KDE/Activities/Consumer>

//#include "activityservice/activityservice.h"
#include "metadataservice/metadataservice.h"

#include "resourcecontainer.h"
#include <nepomuk/nfo.h>
#include <nepomuk/nie.h>

#include "kext.h"

#define RESULT_LIMIT 24

class MetadataEnginePrivate
{
public:
    QSize previewSize;
    KActivities::Consumer *activityConsumer;
    QDBusServiceWatcher *queryServiceWatcher;
    QStringList connectedSources;
};


MetadataEngine::MetadataEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent, args)
{
    Q_UNUSED(args);
    d = new MetadataEnginePrivate;
    setMaxSourceCount(RESULT_LIMIT); // Guard against loading too many connections

    d->queryServiceWatcher = new QDBusServiceWatcher(QLatin1String("org.kde.nepomuk.services.nepomukqueryservice"),
                        QDBusConnection::sessionBus(),
                        QDBusServiceWatcher::WatchForRegistration,
                        this);
    connect(d->queryServiceWatcher, SIGNAL(serviceRegistered(QString)), this, SLOT(serviceRegistered(QString)));


    d->activityConsumer = new KActivities::Consumer(this);
    //init();
}

void MetadataEngine::init()
{
    //kDebug() << "init.";
}

void MetadataEngine::serviceRegistered(const QString &service)
{
    if (service == "org.kde.nepomuk.services.nepomukqueryservice") {
        foreach (const QString &source, d->connectedSources) {
            prepareSource(source);
        }
    // d->connectedSources.clear();
    }
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
    // if the strings ends with :number it's the limit for the query
    if (name.contains(QRegExp(".*:\\d+$"))) {
        QStringList tokens = name.split(":");
        massagedName = massagedName.mid(0, massagedName.lastIndexOf(":"));
    }

    if (name.startsWith('/')) {
        massagedName = "file://" + name;
    }

    foreach (const QString &s, Plasma::DataEngine::sources()) {
        if (s == name) {
            kDebug() << "!!! resource already exists." << name;
            return true;
        }
    }

    if (Nepomuk::ResourceManager::instance()->initialized()) {
        return prepareSource(name);
    } else {
        ResourceContainer *container = qobject_cast<ResourceContainer *>(containerForSource(massagedName));

        Nepomuk::Query::Query query;
        if (!container) {
            container = new ResourceContainer(this);
            container->setObjectName(name);
            addSource(container);
        }

        d->connectedSources << name;
        return true;
    }
}

bool MetadataEngine::updateSourceEvent(const QString &source)
{
    ResourceContainer *container = qobject_cast<ResourceContainer *>(containerForSource(source));
    if (container) {
        prepareSource(source);
    }

    return false;
}


bool MetadataEngine::prepareSource(const QString &name)
{
    QString massagedName = name;

    if (name.startsWith('/')) {
        massagedName = "file://" + name;
    }

    kDebug() << "Creating resource synchronously";
    Nepomuk::Resource resource(massagedName);
    kDebug() << resource.resourceUri();
    if (!resource.exists()) {
        kDebug() << "Resource " << massagedName << " does not exist.";
        return false;
    }
    //return true;

    ResourceContainer *container = qobject_cast<ResourceContainer *>(containerForSource(massagedName));
    if (container) {
        container->setResource(resource);
    } else {
        container = new ResourceContainer(this);
        container->setResource(resource);
        container->setObjectName(name);
        addSource(container);
    }

    return true;
}

Plasma::Service *MetadataEngine::serviceForSource(const QString &source)
{
    //FIXME validate the name
    MetadataService *service = new MetadataService(source);
    service->setParent(this);
    return service;
}



#include "metadataengine.moc"
