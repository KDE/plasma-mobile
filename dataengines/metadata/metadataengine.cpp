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

//#include <KFileMetaInfo>
//#include <KIcon>

//#include <KIO/PreviewJob>
//#include <KFileItem>
//#include <KTemporaryFile>
//#include <KRun>
//#include <QWidget>

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

//using namespace KIO;

class MetadataEngineprivate
{
public:
    Nepomuk::Query::QueryServiceClient *queryClient;
    QString query;
    QSize previewSize;
    //QHash<QString, KIO::PreviewJob*> workers;
};


MetadataEngine::MetadataEngine(QObject* parent, const QVariantList& args)
    : Plasma::DataEngine(parent)
{
    Q_UNUSED(args);
    d = new MetadataEngineprivate;
    //d->previewSize = QSize(180, 120);
    d->queryClient = 0;
    //setMaxSourceCount(64); // Guard against loading too many connections
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
    //return QStringList();
    return QStringList() << "Cactus";
}

bool MetadataEngine::sourceRequestEvent(const QString &name)
{
    Nepomuk::Query::FileQuery fileQuery;
    Nepomuk::Query::LiteralTerm nepomukTerm(name);
    fileQuery.setTerm(nepomukTerm);
    fileQuery.addIncludeFolder(KUrl("/"), true);
    fileQuery.setLimit( 20 );

    kDebug() << "file search for query:" << name;
    d->queryClient->query(fileQuery);
    setData(name, Plasma::DataEngine::Data());
    d->query = name;
    return true;
}

void MetadataEngine::newEntries(const QList< Nepomuk::Query::Result >& entries)
{
    foreach (Nepomuk::Query::Result res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //addWidget(res.resource());
        kDebug() << "Result Excerpt:" << res.excerpt();
        Nepomuk::Resource resource = res.resource();
        QHash<QUrl, Nepomuk::Variant> props = resource.properties();
        foreach(const QUrl &propertyUrl, props.keys()) {
            //QUrl propertyUrl
            kDebug() << "" << propertyUrl << resource.property(propertyUrl).variant();
            setData(d->query, propertyUrl.toString(), resource.property(propertyUrl).variant());
        }
    }
    scheduleSourcesUpdated();
    //emit matchFound();
}

#include "metadataengine.moc"
