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

#include "querythread_p.h"

#include <KDebug>

#include <Nepomuk2/Resource>
#include <Nepomuk2/Variant>
#include <Nepomuk2/Query/ResourceTypeTerm>

#include <Soprano/Vocabulary/NAO>
#include <Nepomuk2/Vocabulary/NIE>
#include <Nepomuk2/Vocabulary/NFO>



using namespace Nepomuk2::Vocabulary;
using namespace Soprano::Vocabulary;

QueryThread::QueryThread( QObject* parent)
    : QThread(parent),
      m_runningClients(0),
      m_countQueryClient(0),
      m_limit(0),
      m_pageSize(30),
      m_timeoutTimer(new QTimer(this)),
      m_running(false)
{
    m_timeoutTimer->setInterval(5000);
    m_timeoutTimer->setSingleShot(true);
    connect(m_timeoutTimer, SIGNAL(timeout()), this, SLOT(finishedListing()));
}

QueryThread::~QueryThread()
{
}

void QueryThread::run()
{
    exec();
    // need to wait until we're out of the event loop otherwise
    // the thread "waits on itself"
    QTimer::singleShot(0, this, SLOT(deleteLater()));
}

void QueryThread::setQuery(const Nepomuk2::Query::Query &query, int limit, int pageSize)
{
    QMutexLocker locker(&m_queryMutex);
    //QMutexLocker locker2(&m_queryMutex);

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
    connect(m_countQueryClient, SIGNAL(error(QString)), SIGNAL(error(QString)));

    if (limit > 0) {
        m_query.setLimit(limit);
    }

    m_running = true;
    emit runningChanged(true);

    m_countQueryClient->sparqlQuery(m_query.toSparqlQuery(Nepomuk2::Query::Query::CreateCountQuery));

    //if page size is invalid, fetch all
    if (pageSize < 1) {
        fetchResultsPage(0);
    }

    m_timeoutTimer->start();
}

bool QueryThread::isQueryRunning() const
{
    return m_running;
}

void QueryThread::setSparqlQuery(const QString &query)
{
    QMutexLocker locker(&m_queryMutex);
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

    if (query.isEmpty()) {
        return;
    }

    m_running = true;
    emit runningChanged(true);

    fetchResultsPage(0);
    m_timeoutTimer->start();
}


bool QueryThread::hasQueryOnPage(int page) const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_fetchPageMutex));
    return m_queryClients.contains(page);
}

void QueryThread::fetchResultsPage(int page)
{
    QMutexLocker locker(&m_fetchPageMutex);
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
    connect(client, SIGNAL(error(QString)), SIGNAL(error(QString)));

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
    const int page = m_pagesForClient.value(qobject_cast<Nepomuk2::Query::QueryServiceClient *>(sender()));

    QVariant dummyValue;
    foreach (const Nepomuk2::Query::Result &res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //kDebug() << "Result label:" << res.genericLabel();

        Nepomuk2::Resource resource = res.resource();
        // this trick is used to prefetch some properties
        // after being accessed the datamanager will cache them
        if (resource.isValid()) {
            dummyValue = resource.genericLabel();
            dummyValue = resource.description();
            dummyValue = resource.property(NIE::url()).variant();
            dummyValue = resource.type();
            dummyValue = resource.property(NIE::mimeType()).variant();
            dummyValue = resource.isFile();
            dummyValue = resource.exists();
            dummyValue = resource.rating();
            dummyValue = resource.property(NAO::numericRating()).variant();
            dummyValue = resource.uri();
            //resource.tags();
            resource.types();
        }
    }

    emit newResults(entries, page);

    //even tough not 100% correct, running here means it's still busy and nothing whatsoever has been shown to the user yet.
    //We don't have any way to know exactly when a query is really over, since the connection stays open.

    m_running = false;
    emit runningChanged(false);
}

void QueryThread::finishedListing()
{
    m_runningClients = qMax(m_runningClients - 1, 0);

    if (m_runningClients <= 0) {
        m_running = false;
        emit runningChanged(false);

        if (m_queryClientsHistory.count() > 10) {
            for (int i = 0; i < m_queryClientsHistory.count() - 10; ++i) {
                Nepomuk2::Query::QueryServiceClient *client = m_queryClientsHistory.first();
                m_queryClientsHistory.pop_front();

                int page = m_pagesForClient.value(client);
                m_queryClients.remove(page);
                m_pagesForClient.remove(client);
                delete client;
            }
        }
    }
}

#include "querythread_p.moc"
