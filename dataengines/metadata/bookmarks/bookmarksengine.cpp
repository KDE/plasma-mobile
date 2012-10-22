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

// Qt
#include <QIcon>
#include <QImage>

// KDE
#include <KIcon>

// Nepomuk
#include <Nepomuk2/Resource>
#include <Nepomuk2/Variant>
#include <Nepomuk2/Query/ResourceTerm>
#include <Nepomuk2/Query/Query>
#include <Nepomuk2/Tag>

// Query API
#include <nepomuk2/andterm.h>
#include <nepomuk2/orterm.h>
#include <nepomuk2/comparisonterm.h>
#include <nepomuk2/literalterm.h>
#include <nepomuk2/resourcetypeterm.h>

// Own stuff
#include "bookmarksengine.h"
#include "../metadatabaseengine.h"
#include "../querycontainer.h"

// Ontologies
#include "bookmark.h"


BookmarksEngine::BookmarksEngine(QObject* parent, const QVariantList& args)
    : MetadataBaseEngine(parent, args)
{
}

BookmarksEngine::~BookmarksEngine()
{
}

bool BookmarksEngine::sourceRequestEvent(const QString &name)
{
    if (!sources().contains("fallbackImage")) {
        QImage im = KIcon("nepomuk").pixmap(256, 256).toImage();
        setData("fallbackImage", "fallbackImage", im);
    }
    QString massagedName = name;
    if (name.startsWith(QLatin1String("add:"))) {
        //QString massagedName = name;
        QUrl url = QUrl(massagedName.remove("add:"));
        Nepomuk2::Bookmark b(url);
        b.setLabel(url.toString());
        b.setDescription(url.toString());
        b.setBookmarks( url.toString() );
        //kDebug() << "Added Bookmark:" << massagedName;
    } else if (name.startsWith(QLatin1String("remove:"))) {
        //QString massagedName = name;
        QUrl url = QUrl(massagedName.remove("remove:"));
        Nepomuk2::Resource b(url);
        //kDebug() << "TYPE: " << b.resourceType();
        b.remove();
        //kDebug() << "Removed Bookmark:" << massagedName;
    } else {
        Nepomuk2::Types::Class bookmarkClass(Nepomuk2::Bookmark::resourceTypeUri());
        //Nepomuk2::Types::Class bookmarkClass(Nepomuk2::PersonContact::resourceTypeUri()); // for testing
        Nepomuk2::Query::ResourceTypeTerm rtt(bookmarkClass);

        Nepomuk2::Query::Query bookmarkQuery;
        bookmarkQuery.setTerm(rtt);

        //kDebug() << "Query:" << bookmarkQuery.toSparqlQuery();

        QueryContainer *container = qobject_cast<QueryContainer *>(containerForSource(massagedName));
        if (!container) {
            container = new QueryContainer(bookmarkQuery, this);
        }
        container->setObjectName(massagedName);
        addSource(container);
    }
    return true;
}


#include "bookmarksengine.moc"
