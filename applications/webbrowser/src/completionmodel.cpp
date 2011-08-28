/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

//#define KDE_DEPRECATED 1

#include "completionmodel.h"
#include "completionitem.h"
#include "history.h"

// Nepomuk
#include <Nepomuk/Resource>
#include <Nepomuk/Variant>
//#include <nepomuk/queryparser.h>
#include <Nepomuk/Query/ResourceTerm>
#include "bookmark.h"

#include <Nepomuk/Query/Query>
//#include <Nepomuk/Query/FileQuery>
#include <Nepomuk/Query/QueryServiceClient>
#include <Nepomuk/Query/Result>

//#include <soprano/vocabulary.h>

#include <nepomuk/andterm.h>
#include <nepomuk/orterm.h>
#include <nepomuk/comparisonterm.h>
#include <nepomuk/literalterm.h>
#include <nepomuk/resourcetypeterm.h>

#include "kdebug.h"

class CompletionModelPrivate {

public:
    QList<QObject*> items;
    Nepomuk::Query::Query query;
    Nepomuk::Query::QueryServiceClient* queryClient;
    History* history;
};


CompletionModel::CompletionModel(QObject *parent)
    : QObject(parent)
{
    d = new CompletionModelPrivate;
    populate();
}

CompletionModel::~CompletionModel()
{
    delete d;
}

QList<QObject*> CompletionModel::items()
{
    QList<QObject*> l;
    l.append(d->history->items());
    l.append(d->items);

    return l;
}


void CompletionModel::populate()
{
    kDebug() << "populating model...";
    d->history = new History(this);
    //d->history->loadHistory();
    /*
    d->items.append(new CompletionItem("Planet KDE", "http://planetkde.org", QImage(), this));
    d->items.append(new CompletionItem("Cookie Test", "http://vizZzion.org", QImage(), this));
    d->items.append(new CompletionItem("G..gle", "http://google.com", QImage(), this));
    */
    
    loadBookmarks();
}

void CompletionModel::loadBookmarks()
{
    if (!Nepomuk::Query::QueryServiceClient::serviceAvailable()) {
        return;
    }

    kDebug() << "Loading bookmarks...";
    Nepomuk::Types::Class bookmarkClass(Nepomuk::Bookmark::resourceTypeUri());
    Nepomuk::Query::ResourceTypeTerm rtt(bookmarkClass);

    d->query.setTerm(rtt);

    d->queryClient = new Nepomuk::Query::QueryServiceClient(this);

    connect(d->queryClient, SIGNAL(finishedListing()),
            this, SLOT(finishedListing()));
    connect(d->queryClient, SIGNAL(newEntries(const QList<Nepomuk::Query::Result> &)),
            this, SLOT(newEntries(const QList<Nepomuk::Query::Result> &)));
    connect(d->queryClient, SIGNAL(entriesRemoved(const QList<QUrl> &)),
            this, SLOT(entriesRemoved(const QList<QUrl> &)));

    d->query.setLimit(64);
    d->queryClient->query(d->query);
}

void CompletionModel::finishedListing()
{
    kDebug() << "Done listing.";
}

void CompletionModel::newEntries(const QList< Nepomuk::Query::Result >& entries)
{
    foreach (Nepomuk::Query::Result res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        CompletionItem* item = new CompletionItem(this);
        item->setResource(res.resource());
        d->items.append(item);
    }

    emit dataChanged();
}

void CompletionModel::entriesRemoved(const QList< QUrl >& urls)
{
    Q_UNUSED( urls );
    // TODO: implement me
}

#include "completionmodel.moc"
