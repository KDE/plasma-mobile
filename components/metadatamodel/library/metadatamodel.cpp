/*
    Copyright 2011 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#include "metadatamodel.h"
#include "queryproviders/abstractqueryprovider.h"
#include "querythread_p.h"

#include <cmath>

#include <QDBusConnection>
#include <QDBusServiceWatcher>
#include <QDBusConnectionInterface>
#include <QTimer>

#include <KDebug>
#include <KMimeType>

#include <soprano/vocabulary.h>

#include <Nepomuk2/File>
#include <Nepomuk2/Tag>
#include <Nepomuk2/Variant>

#include <Nepomuk2/Query/AndTerm>
#include <Nepomuk2/Query/OrTerm>
#include <Nepomuk2/Query/NegationTerm>
#include <Nepomuk2/Query/ResourceTerm>
#include <Nepomuk2/Query/ComparisonTerm>
#include <Nepomuk2/Query/LiteralTerm>
#include <Nepomuk2/Query/QueryParser>
#include <Nepomuk2/Query/ResourceTypeTerm>
#include <Nepomuk2/Query/StandardQuery>
#include <Nepomuk2/ResourceWatcher>

#include "kao.h"

using namespace Nepomuk2::Vocabulary;
using namespace Soprano::Vocabulary;

MetadataModel::MetadataModel(QObject *parent)
    : QAbstractListModel(parent),
      m_limit(0),
      m_pageSize(30)
{
    m_queryThread = new QueryThread(this);
    connect(m_queryThread, SIGNAL(newResults(QList<Nepomuk2::Query::Result>, int)),
            this, SLOT(newEntries(QList<Nepomuk2::Query::Result>, int)));
    connect(m_queryThread, SIGNAL(resultsRemoved(QList<QUrl>)),
            this, SLOT(entriesRemoved(QList<QUrl>)));
    connect(m_queryThread, SIGNAL(countRetrieved(int)),
            this, SLOT(countRetrieved(int)));
    connect(m_queryThread, SIGNAL(runningChanged(bool)),
            this, SIGNAL(runningChanged(bool)));

    //TODO: error(QString);

    connect(this, SIGNAL(rowsInserted(QModelIndex,int,int)),
            this, SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsRemoved(QModelIndex,int,int)),
            this, SIGNAL(countChanged()));
    connect(this, SIGNAL(modelReset()),
            this, SIGNAL(countChanged()));


    m_queryTimer = new QTimer(this);
    m_queryTimer->setInterval(0);
    m_queryTimer->setSingleShot(true);


    m_newEntriesTimer = new QTimer(this);
    m_newEntriesTimer->setSingleShot(true);
    connect(m_newEntriesTimer, SIGNAL(timeout()),
            this, SLOT(newEntriesDelayed()));

    m_watcher = new Nepomuk2::ResourceWatcher(this);

    m_watcher->addProperty(NAO::numericRating());
    connect(m_watcher, SIGNAL(propertyAdded(Nepomuk2::Resource,Nepomuk2::Types::Property, QVariant)),
            this, SLOT(propertyChanged(Nepomuk2::Resource,Nepomuk2::Types::Property, QVariant)));


    m_queryServiceWatcher = new QDBusServiceWatcher(QLatin1String("org.kde.nepomuk.services.nepomukqueryservice"),
                        QDBusConnection::sessionBus(),
                        QDBusServiceWatcher::WatchForRegistration,
                        this);
    connect(m_queryServiceWatcher, SIGNAL(serviceRegistered(QString)), this, SLOT(serviceRegistered(QString)));

    QDBusConnectionInterface* interface = m_queryServiceWatcher->connection().interface();

    if (interface->isServiceRegistered("org.kde.nepomuk.services.nepomukqueryservice")) {
        connect(m_queryTimer, SIGNAL(timeout()), this, SLOT(doQuery()));
    }
}

MetadataModel::~MetadataModel()
{
}

bool MetadataModel::isRunning() const
{
    return m_queryThread->isQueryRunning();
}

void MetadataModel::setQuery(const Nepomuk2::Query::Query &query)
{
    m_query = query;

    if (Nepomuk2::Query::QueryServiceClient::serviceAvailable()) {
        requestRefresh();
    }
}

Nepomuk2::Query::Query MetadataModel::query() const
{
    return m_query;
}

void MetadataModel::setQueryProvider(AbstractQueryProvider *provider)
{
    if (m_queryProvider.data() == provider) {
        return;
    }

    setRoleNames(provider->roleNames());

    if (m_queryProvider) {
        disconnect(m_queryProvider.data(), 0, this, 0);
    }

    connect(provider, SIGNAL(queryChanged()),
            this, SLOT(doQuery()));
    connect(provider, SIGNAL(sparqlQueryChanged()),
            this, SLOT(doQuery()));
    connect(provider, SIGNAL(dataFormatChanged(QPersistentModelIndex)),
            this, SLOT(dataFormatChanged(QPersistentModelIndex)));

    m_queryProvider = provider;
    doQuery();
    emit queryProviderChanged();
}

AbstractQueryProvider *MetadataModel::queryProvider() const
{
    return m_queryProvider.data();
}


void MetadataModel::setLimit(int limit)
{
    if (limit == m_limit) {
        return;
    }

    m_limit = limit;
    requestRefresh();
    emit limitChanged();
}

int MetadataModel::limit() const
{
    return m_limit;
}

void MetadataModel::setLazyLoading(bool lazy)
{
    //lazy loading depends from the page zise, that is not directly user controllable
    if (lazy == (m_pageSize > 0)) {
        return;
    }

    //TODO: a way to control this? maybe from the available memory?
    m_pageSize = lazy ? 30 : -1;
    requestRefresh();
    emit lazyLoadingChanged();
}

bool MetadataModel::lazyLoading() const
{
    return (m_pageSize > 0);
}

void MetadataModel::requestRefresh()
{
    m_queryTimer->start();
}

void MetadataModel::doQuery()
{
    if (!queryProvider()) {
        return;
    }

    m_totalCount = 0;

    m_query = queryProvider()->query();
    if (m_query.isValid()) {
        m_sparqlQuery = QString();
        if (m_limit > 0) {
            m_query.setLimit(m_limit);
        }
        kWarning() << "Sparql query:" << m_query.toSparqlQuery();
    } else {
        m_sparqlQuery = queryProvider()->sparqlQuery();
        kWarning() << "Sparql query:" << m_sparqlQuery;
    }

    beginResetModel();
    m_data = QVector<Nepomuk2::Query::Result>(0);
    m_uriToRow.clear();
    m_dataToInsert.clear();
    m_validIndexForPage.clear();
    endResetModel();
    emit countChanged();
    emit totalCountChanged();


    if (m_query.isValid()) {
        m_queryThread->setQuery(m_query, m_limit, m_pageSize);
    } else {
        m_queryThread->setSparqlQuery(m_sparqlQuery);
    }

    //if page size is invalid, fetch all
    if (m_pageSize < 1) {
        fetchResultsPage(0);
    }

    //FIXME
    // Nepomuk2::Query::QueryServiceClient does not emit finishedListing signal when there is no new entries (no matches).
    QTimer::singleShot(5000, this, SLOT(finishedListing()));
}

void MetadataModel::fetchResultsPage(int page)
{
    m_validIndexForPage[page] = 0;

    m_queryThread->fetchResultsPage(page);
}

void MetadataModel::countRetrieved(int count)
{
    if (count < m_data.size()) {
        beginRemoveRows(QModelIndex(), count-1, m_data.size()-1);
        m_data.resize(count);
        endRemoveRows();
    } else if (count > m_data.size()) {
        beginInsertRows(QModelIndex(), m_data.size(), count-1);
        m_data.resize(count);
        endInsertRows();
    }
}

void MetadataModel::newEntries(const QList< Nepomuk2::Query::Result > &entries, int page)
{
    foreach (const Nepomuk2::Query::Result &res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //kDebug() << "Result label:" << res.genericLabel();

        m_totalCount += res.additionalBinding(QLatin1String("count")).variant().toInt();
    }

    m_dataToInsert[page] << entries;

    if (!m_newEntriesTimer->isActive() && !m_dataToInsert[page].isEmpty()) {
        m_newEntriesTimer->start(200);
    }
    if (m_totalCount > 0) {
        emit totalCountChanged();
    }
}

void MetadataModel::newEntriesDelayed()
{
    if (m_dataToInsert.isEmpty()) {
        return;
    }

    m_elapsedTime.start();
    QHash<int, QList<Nepomuk2::Query::Result> >::const_iterator i;
    for (i = m_dataToInsert.constBegin(); i != m_dataToInsert.constEnd(); ++i) {
        const QList<Nepomuk2::Query::Result> dataToInsert = i.value();

        m_watcher->stop();

        int pageStart = 0;
        if (m_pageSize > 0) {
            pageStart = i.key() * m_pageSize;
        }
        int startOffset = m_validIndexForPage.value(i.key());
        int offset = startOffset;

        //if new result arrive on an already running query, they may arrive before countQueryResult
        if (m_data.size() < pageStart + startOffset + 1) {
            beginInsertRows(QModelIndex(), m_data.size(), pageStart + startOffset);
            m_data.resize(pageStart + startOffset + 1);
            endInsertRows();
        }
        //this happens only when m_validIndexForPage has been invalidate by row removal
        if (!m_validIndexForPage.contains(i.key()) && (m_data[pageStart + startOffset].resource().isValid() || m_data[pageStart + startOffset].additionalBindings().count() > 0)) {
            while (pageStart + startOffset < m_data.size() && (m_data[pageStart + startOffset].resource().isValid() || m_data[pageStart + startOffset].additionalBindings().count() > 0)) {
                ++startOffset;
                ++offset;
            }
        }

        foreach (const Nepomuk2::Query::Result &res, dataToInsert) {
            //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
            //kDebug() << "Page:" << i.key() << "Index:"<< pageStart + offset;

            if (res.resource().isValid()) {
                m_uriToRow[res.resource().uri()] = pageStart + offset;
            }

            //there can be new results before the count query gets updated
            if (pageStart + offset < m_data.size()) {
                m_data[pageStart + offset] = res;
                if (res.resource().isValid()) {
                    m_watcher->addResource(res.resource());
                }
                ++offset;
            } else {
                beginInsertRows(QModelIndex(), m_data.size(), pageStart + offset);
                m_data.resize(pageStart + offset + 1);
                m_data[pageStart + offset] = res;
                if (res.resource().isValid()) {
                    m_watcher->addResource(res.resource());
                }
                ++offset;
                endInsertRows();
            }
        }

        m_validIndexForPage[i.key()] = offset;

        m_watcher->start();
        emit dataChanged(createIndex(pageStart + startOffset, 0),
                         createIndex(pageStart + startOffset + dataToInsert.count()-1, 0));
    }
    kDebug() << "Elapsed time populating the model" << m_elapsedTime.elapsed();
    m_dataToInsert.clear();
}

void MetadataModel::propertyChanged(Nepomuk2::Resource res, Nepomuk2::Types::Property prop, QVariant val)
{
    Q_UNUSED(prop)
    Q_UNUSED(val)

    const int index = m_uriToRow.value(res.uri());
    if (index >= 0) {
        emit dataChanged(createIndex(index, 0, 0), createIndex(index, 0, 0));
    }
}

void MetadataModel::dataFormatChanged(const QPersistentModelIndex &index)
{
    emit dataChanged(index, index);
}

void MetadataModel::entriesRemoved(const QList<QUrl> &urls)
{
    int prevIndex = -100;
    //pack all the stuff to remove in groups, to emit the least possible signals
    //this assumes urls are in the same order they arrived ion the results
    //it's a map because we want to remove values from the vector in inverted order to keep indexes valid trough the remove loop
    int oldTotalCount = m_totalCount;
    QMap<int, int> toRemove;
    foreach (const QUrl &url, urls) {
        const int index = m_uriToRow.value(url);
        const int count = m_data[index].additionalBinding("count").variant().toInt();
        if (count) {
            m_totalCount -= count;
        }
        if (index == prevIndex + 1) {
            toRemove[prevIndex]++;
        } else {
            toRemove[index] = 1;
        }
        prevIndex = index;
    }

    if (oldTotalCount != m_totalCount) {
        emit totalCountChanged();
    }

    //all the page indexes may be invalid now
    m_validIndexForPage.clear();

    QMap<int, int>::const_iterator i = toRemove.constEnd();

    while (i != toRemove.constBegin()) {
        --i;
        beginRemoveRows(QModelIndex(), i.key(), i.key()+i.value()-1);
        m_data.remove(i.key(), i.value());
        endRemoveRows();
    }

    //another loop, we don't depend to m_uriToRow in data(), but we take this doublesafety
    foreach (const QUrl &url, urls) {
        m_uriToRow.remove(url);
    }

    //FIXME: this loop makes all the optimizations useless, get rid either of it or the optimizations
    for (int i = 0; i < m_data.count(); ++i) {
        m_uriToRow[m_data[i].resource().uri()] = i;
    }

    emit countChanged();
}

QVariant MetadataModel::data(const QModelIndex &index, int role) const
{
    if (!m_queryProvider || !index.isValid() || index.column() != 0 ||
        index.row() < 0 || index.row() >= m_data.count()){
        return QVariant();
    }

    //if the resource is not valid *and* there are no additional bindings means no data in these rows was fetched in nepomuk yet
    if (!m_data[index.row()].resource().isValid() &&
        m_data[index.row()].additionalBindings().count() == 0) {
        if (m_pageSize > 0 && !m_queryThread->hasQueryOnPage(floor(index.row()/m_pageSize))) {
            m_queryThread->fetchResultsPage(floor(index.row()/m_pageSize));
            return QVariant();
        //m_pageSize <= 0, means fetch all
        } else if (!m_queryThread->hasQueryOnPage(0)) {
            m_queryThread->fetchResultsPage(0);
            return QVariant();
        } else {
            return QVariant();
        }
    }


    switch (role) {
    case AbstractQueryProvider::ResultRow:
        return index.row();
    default:
        return m_queryProvider.data()->formatData(m_data[index.row()], QPersistentModelIndex(index), role);
    }
}

QVariantHash MetadataModel::get(int row) const
{
    QModelIndex idx = index(row, 0);
    QVariantHash hash;

    QHash<int, QByteArray>::const_iterator i;
    for (i = roleNames().constBegin(); i != roleNames().constEnd(); ++i) {
        hash[i.value()] = data(idx, i.key());
    }

    return hash;
}

// Just signal QSortFilterProxyModel to do the real sorting.
void MetadataModel::sort(int column, Qt::SortOrder order)
{
    Q_UNUSED(column);
    Q_UNUSED(order);

    beginResetModel();
    endResetModel();
}

int MetadataModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return count();
}

void MetadataModel::serviceRegistered(const QString &service)
{
    if (service == QLatin1String("org.kde.nepomuk.services.nepomukqueryservice")) {
        disconnect(m_queryTimer, SIGNAL(timeout()), this, SLOT(doQuery()));
        connect(m_queryTimer, SIGNAL(timeout()), this, SLOT(doQuery()));
        doQuery();
    }
}

#include "metadatamodel.moc"
