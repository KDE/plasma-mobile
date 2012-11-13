/***************************************************************************
 *   Copyright 2011 Sinny Kumari <ksinny@gmail.com>                        *
 *   Copyright 2012 Shantanu Tushar <shantanu@kde.org>                     *
 *   Copyright 2011 Marco Martin <notmart@gmail.com>                       *
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

#include "querythread.h"

#include <Nepomuk2/Resource>
#include <Nepomuk2/Variant>
#include <Nepomuk2/Vocabulary/NIE>
#include <Nepomuk2/Vocabulary/NFO>
#include <Nepomuk2/Query/ResourceTypeTerm>

#include <KDebug>

#include <QtCore/QTimer>


QueryThread::QueryThread( QObject* parent)
    : QThread(parent),
      m_runningClients(0),
      m_countQueryClient(0),
      m_limit(0),
      m_pageSize(30)
{
    moveToThread(this);
}

QueryThread::~QueryThread()
{
    deleteLater();
}

void QueryThread::setQuery(const Nepomuk2::Query::Query &query, int limit, int pageSize)
{
    QMutexLocker locker(&m_queryMutex);

    m_query = query;
    m_sparqlQuery = QString();

    delete m_countQueryClient;
    //qDeleteAll is broken in 4.8
    foreach (Nepomuk2::Query::QueryServiceClient *client, m_queryClients) {
        delete client;
    }
    m_queryClients.clear();
    m_pagesForClient.clear();
    m_queryClientsHistory.clear();
    m_runningClients = 0;
    m_countQueryClient = new Nepomuk2::Query::QueryServiceClient(this);
    m_limit = limit;
    m_pageSize = pageSize;

    connect(m_countQueryClient, SIGNAL(newEntries(QList<Nepomuk2::Query::Result>)),
            this, SLOT(countQueryResult(QList<Nepomuk2::Query::Result>)));

    if (limit > 0) {
        m_query.setLimit(limit);
    }

    m_countQueryClient->sparqlQuery(m_query.toSparqlQuery(Nepomuk2::Query::Query::CreateCountQuery));

    //if page size is invalid, fetch all
    if (pageSize < 1) {
        fetchResultsPage(0);
    }
}

void QueryThread::setSparqlQuery(const QString &query)
{
    m_query = Nepomuk2::Query::Query();
    m_sparqlQuery = query;

    delete m_countQueryClient;
    //qDeleteAll is broken in 4.8
    foreach (Nepomuk2::Query::QueryServiceClient *client, m_queryClients) {
        delete client;
    }
    m_queryClients.clear();
    m_pagesForClient.clear();
    m_queryClientsHistory.clear();
    m_runningClients = 0;
    m_countQueryClient = 0;

    fetchResultsPage(0);
}


bool QueryThread::hasQueryOnPage(int page) const
{
    return m_queryClients.contains(page);
}

void QueryThread::fetchResultsPage(int page)
{
    if (m_queryClients.contains(page)) {
        return;
    }

    Nepomuk2::Query::QueryServiceClient *client = new Nepomuk2::Query::QueryServiceClient(this);

    m_queryClients[page] = client;
    m_pagesForClient[client] = page;

    if (m_query.isValid()) {
        Nepomuk2::Query::Query pageQuery(m_query);
        if (m_pageSize > 0) {
            pageQuery.setOffset(m_pageSize*page);
            pageQuery.setLimit(m_pageSize);
        }
        client->query(pageQuery);
    } else {
        client->sparqlQuery(m_sparqlQuery);
    }

    connect(client, SIGNAL(newEntries(QList<Nepomuk2::Query::Result>)),
            this, SLOT(newEntries(QList<Nepomuk2::Query::Result>)));
    connect(client, SIGNAL(entriesRemoved(QList<QUrl>)),
            this, SIGNAL(resultsRemoved(QList<QUrl>)));
    connect(client, SIGNAL(finishedListing()),
            this, SLOT(finishedListing()));

    m_queryClientsHistory << client;
    ++m_runningClients;
}

void QueryThread::countQueryResult(const QList< Nepomuk2::Query::Result > &entries)
{
    if (entries.count() < 1) {
        return;
    }

    const int count = entries.first().additionalBinding(QLatin1String("cnt")).variant().toInt();

    emit countRetrieved(count);
}

void QueryThread::newEntries(const QList< Nepomuk2::Query::Result > &entries)
{
    foreach (const Nepomuk2::Query::Result &res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //kDebug() << "Result label:" << res.genericLabel();

        Nepomuk2::Resource resource = res.resource();
        //prefetch some properties
        if (resource.isValid()) {
            //TODO
        }
    }

    emit newResults(entries);
}
/*
//FIXME: probably this is useless
void MetadataModel::entriesRemoved(const QList<QUrl> &urls)
{
    QMutexLocker locker(&m_countMutex);
    m_count -= urls.count();

    emit countChanged(m_count);
    emit resultsRemoved(urls);
}*/

#include "querythread.moc"
