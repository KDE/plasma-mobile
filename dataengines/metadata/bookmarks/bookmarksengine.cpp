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
#include <Nepomuk/Resource>
#include <Nepomuk/Variant>
#include <Nepomuk/Query/ResourceTerm>
#include <Nepomuk/Query/Query>
#include <Nepomuk/Tag>

// Query API
#include <nepomuk/andterm.h>
#include <nepomuk/orterm.h>
#include <nepomuk/comparisonterm.h>
#include <nepomuk/literalterm.h>
#include <nepomuk/resourcetypeterm.h>

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
    if (name.startsWith("add:")) {
        //QString massagedName = name;
        QUrl url = QUrl(massagedName.remove("add:"));
        Nepomuk::Bookmark b(url);
        b.setLabel(url.toString());
        b.setDescription(url.toString());
        b.setBookmarks( url.toString() );
        //kDebug() << "Added Bookmark:" << massagedName;
    } else if (name.startsWith("remove:")) {
        //QString massagedName = name;
        QUrl url = QUrl(massagedName.remove("remove:"));
        Nepomuk::Resource b(url);
        //kDebug() << "TYPE: " << b.resourceType();
        b.remove();
        //kDebug() << "Removed Bookmark:" << massagedName;
    } else {
        Nepomuk::Types::Class bookmarkClass(Nepomuk::Bookmark::resourceTypeUri());
        //Nepomuk::Types::Class bookmarkClass(Nepomuk::PersonContact::resourceTypeUri()); // for testing
        Nepomuk::Query::ResourceTypeTerm rtt(bookmarkClass);

        Nepomuk::Query::Query bookmarkQuery;
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
