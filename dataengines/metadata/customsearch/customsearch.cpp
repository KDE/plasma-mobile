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

#include <KServiceTypeTrader>
#include <KPluginInfo>

// Nepomuk
#include <Nepomuk/Resource>
#include <Nepomuk/Variant>
#include <Nepomuk/Query/ResourceTerm>
#include <Nepomuk/Query/Query>
#include <Nepomuk/Query/QueryParser>
#include <Nepomuk/Tag>

// Ontologies

// Query API
#include <nepomuk/andterm.h>
#include <nepomuk/orterm.h>
#include <nepomuk/comparisonterm.h>
#include <nepomuk/literalterm.h>
#include <nepomuk/resourcetypeterm.h>

#include "customsearch.h"


CustomSearch::CustomSearch(QObject* parent, const QVariantList& args)
    : MetadataBaseEngine(parent, args)
{
    kDebug() << " = = = = = = = = = = = = = = = = = = = = = = = = = = ";
    Q_UNUSED(args);
    setObjectName("CustomSearch");
}

CustomSearch::~CustomSearch()
{
}

void CustomSearch::init()
{
    MetadataBaseEngine::init();
    //QString _id = "plasma_engine_customsearch";
    QString _id = "active_persons";
    _id = pluginName();
    kDebug() << "ID is: " << _id;
    const QString constraint = QString("[X-KDE-PluginInfo-Name] == '%1'").arg(_id);
    const KService::List offers = KServiceTypeTrader::self()->query("Plasma/DataEngine", constraint);

    foreach (const KPluginInfo &info, KPluginInfo::fromServices(offers)) {

        QString _q = info.property("X-Plasma-Args").toString();
        kDebug() << constraint << info.name() << info.property("X-Plasma-Args").toString() << _q;
        if (!_q.isEmpty()) {
            kDebug() << "SEARCH QUERY:" << _q;
            Nepomuk::Query::Query _query = Nepomuk::Query::QueryParser::parseQuery(_q);

            if (_query.isValid()) {
                query(_query);
            } else {
                kWarning() << "Query is invalid:" << _query;
            }
        } else {
            kWarning() << "No X-Plasma-Args found in .desktop file, no search query. :(";
        }
    }
}

#include "customsearch.moc"
