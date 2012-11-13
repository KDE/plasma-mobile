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

#ifndef QUERYTHREAD_H
#define QUERYTHREAD_H

#include <QtCore/QThread>

#include <Nepomuk2/Query/Result>
#include <Nepomuk2/Query/QueryServiceClient>
#include <Nepomuk2/Query/Term>

#include <QtCore/QMutex>
#include <QtCore/QWaitCondition>
#include <QtCore/QAbstractItemModel>


class QueryThread : public QThread
{
    Q_OBJECT
public:
    QueryThread(QObject* parent = 0);
    ~QueryThread();

    void setQuery(const Nepomuk2::Query::Query &query, int limit = 0, int pageSize = 30);
    void setSparqlQuery(const QString &Query);

    void fetchResultsPage(int page);
    bool hasQueryOnPage(int page) const;

Q_SIGNALS:
    void newResults(const QList<Nepomuk2::Query::Result> &results);
    void resultsRemoved(const QList<QUrl>&urls);

    void finishedListing();
    void error(const QString &message);
    void countRetrieved(int);

private Q_SLOTS:
    void countQueryResult(const QList< Nepomuk2::Query::Result > &entries);
    void newEntries(const QList< Nepomuk2::Query::Result > &entries);
    //void entriesRemoved(const QList<QUrl> &urls);

private:
    //the query and the sparqlQuery are mutually exclusive
    Nepomuk2::Query::Query m_query;
    QString m_sparqlQuery;

    //mapping page->query client
    QHash<int, Nepomuk2::Query::QueryServiceClient *> m_queryClients;
    //mapping query client->page
    QHash<Nepomuk2::Query::QueryServiceClient *, int> m_pagesForClient;
    //keep always running at most 10 clients, get rid of the old ones
    //won't be possible to monitor forresources going away, but is too heavy
    QList<Nepomuk2::Query::QueryServiceClient *> m_queryClientsHistory;
    //how many service clients are running now?
    int m_runningClients;
    //client that only knows how much results there are
    Nepomuk2::Query::QueryServiceClient *m_countQueryClient;

    //pieces to limit how much stuff we fetch
    //they're locked by m_queryMutex
    int m_limit;
    int m_pageSize;

    //semaphores
    QMutex m_queryMutex;
};

#endif // QUERYTHREAD_H
