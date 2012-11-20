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



class MetadataModelPrivate
{
public:
    MetadataModelPrivate(MetadataModel *model)
       : q(model),
         limit(0),
         pageSize(30)
    {
    }


    MetadataModel *q;

    //query construction is completely delegated to this
    QWeakPointer<AbstractQueryProvider> queryProvider;

    //To be sure that nepomuk is up, and watch when it goes up/down
    QDBusServiceWatcher *queryServiceWatcher;

    //perform all the queries in this thread
    QueryThread *queryThread;

    //actual query performed
    Nepomuk2::Query::Query query;
    //sparql version: they are mutually exclusive
    QString sparqlQuery;

    //pieces to limit how much stuff we fetch
    int limit;
    int pageSize;

    //where is the last valid (already populated) index for a given page
    QHash<int, int> validIndexForPage;


    int totalCount;

    //actual main data
    QVector<Nepomuk2::Query::Result> data;
    //some properties may change dynamically
    Nepomuk2::ResourceWatcher* watcher;
    //used to event compress new results arriving
    QTimer *newEntriesTimer;
    //a queue by page of the data that will be inserted in the model with event compression
    QHash<int, QList<Nepomuk2::Query::Result> > dataToInsert;
    //maps uris ro row numbers, so when entriesRemoved arrived, we know what rows to remove
    QHash<QUrl, int> uriToRow;

    //used to event compressreset of the query for instance when limit or cacheresults change
    QTimer *queryTimer;

    //used purely for benchmark
    QTime elapsedTime;
};


MetadataModel::MetadataModel(QObject *parent)
    : QAbstractListModel(parent),
      d(new MetadataModelPrivate(this))
{
    d->queryThread = new QueryThread(this);
    connect(d->queryThread, SIGNAL(newResults(QList<Nepomuk2::Query::Result>, int)),
            this, SLOT(newEntries(QList<Nepomuk2::Query::Result>, int)));
    connect(d->queryThread, SIGNAL(resultsRemoved(QList<QUrl>)),
            this, SLOT(entriesRemoved(QList<QUrl>)));
    connect(d->queryThread, SIGNAL(countRetrieved(int)),
            this, SLOT(countRetrieved(int)));
    connect(d->queryThread, SIGNAL(runningChanged(bool)),
            this, SIGNAL(runningChanged(bool)));

    //TODO: error(QString);

    connect(this, SIGNAL(rowsInserted(QModelIndex,int,int)),
            this, SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsRemoved(QModelIndex,int,int)),
            this, SIGNAL(countChanged()));
    connect(this, SIGNAL(modelReset()),
            this, SIGNAL(countChanged()));


    d->queryTimer = new QTimer(this);
    d->queryTimer->setInterval(0);
    d->queryTimer->setSingleShot(true);


    d->newEntriesTimer = new QTimer(this);
    d->newEntriesTimer->setSingleShot(true);
    connect(d->newEntriesTimer, SIGNAL(timeout()),
            this, SLOT(newEntriesDelayed()));

    d->watcher = new Nepomuk2::ResourceWatcher(this);

    d->watcher->addProperty(NAO::numericRating());
    connect(d->watcher, SIGNAL(propertyAdded(Nepomuk2::Resource,Nepomuk2::Types::Property, QVariant)),
            this, SLOT(propertyChanged(Nepomuk2::Resource,Nepomuk2::Types::Property, QVariant)));


    d->queryServiceWatcher = new QDBusServiceWatcher(QLatin1String("org.kde.nepomuk.services.nepomukqueryservice"),
                        QDBusConnection::sessionBus(),
                        QDBusServiceWatcher::WatchForRegistration,
                        this);
    connect(d->queryServiceWatcher, SIGNAL(serviceRegistered(QString)), this, SLOT(serviceRegistered(QString)));

    QDBusConnectionInterface* interface = d->queryServiceWatcher->connection().interface();

    if (interface->isServiceRegistered("org.kde.nepomuk.services.nepomukqueryservice")) {
        connect(d->queryTimer, SIGNAL(timeout()), this, SLOT(doQuery()));
    }
}

MetadataModel::~MetadataModel()
{
}

bool MetadataModel::isRunning() const
{
    return d->queryThread->isQueryRunning();
}

void MetadataModel::setQueryProvider(AbstractQueryProvider *provider)
{
    if (d->queryProvider.data() == provider) {
        return;
    }

    setRoleNames(provider->roleNames());

    if (d->queryProvider) {
        disconnect(d->queryProvider.data(), 0, this, 0);
    }

    connect(provider, SIGNAL(queryChanged()),
            this, SLOT(doQuery()));
    connect(provider, SIGNAL(sparqlQueryChanged()),
            this, SLOT(doQuery()));
    connect(provider, SIGNAL(dataFormatChanged(QPersistentModelIndex)),
            this, SLOT(dataFormatChanged(QPersistentModelIndex)));

    d->queryProvider = provider;
    doQuery();
    emit queryProviderChanged();
}

AbstractQueryProvider *MetadataModel::queryProvider() const
{
    return d->queryProvider.data();
}

int MetadataModel::count() const
{
    return d->data.count();
}

int MetadataModel::totalCount() const
{
    return d->totalCount;
}


void MetadataModel::setLimit(int limit)
{
    if (limit == d->limit) {
        return;
    }

    d->limit = limit;
    requestRefresh();
    emit limitChanged();
}

int MetadataModel::limit() const
{
    return d->limit;
}

void MetadataModel::setLazyLoading(bool lazy)
{
    //lazy loading depends from the page zise, that is not directly user controllable
    if (lazy == (d->pageSize > 0)) {
        return;
    }

    //TODO: a way to control this? maybe from the available memory?
    d->pageSize = lazy ? 30 : -1;
    requestRefresh();
    emit lazyLoadingChanged();
}

bool MetadataModel::lazyLoading() const
{
    return (d->pageSize > 0);
}

void MetadataModel::requestRefresh()
{
    d->queryTimer->start();
}

void MetadataModel::doQuery()
{
    if (!queryProvider()) {
        return;
    }

    d->totalCount = 0;

    d->query = queryProvider()->query();
    if (d->query.isValid()) {
        d->sparqlQuery = QString();
        if (d->limit > 0) {
            d->query.setLimit(d->limit);
        }
        kWarning() << "Sparql query:" << d->query.toSparqlQuery();
    } else {
        d->sparqlQuery = queryProvider()->sparqlQuery();
        kWarning() << "Sparql query:" << d->sparqlQuery;
    }

    beginResetModel();
    d->data = QVector<Nepomuk2::Query::Result>(0);
    d->uriToRow.clear();
    d->dataToInsert.clear();
    d->validIndexForPage.clear();
    endResetModel();
    emit countChanged();
    emit totalCountChanged();


    if (d->query.isValid()) {
        d->queryThread->setQuery(d->query, d->limit, d->pageSize);
    } else {
        d->queryThread->setSparqlQuery(d->sparqlQuery);
    }

    //if page size is invalid, fetch all
    if (d->pageSize < 1) {
        fetchResultsPage(0);
    }

    //FIXME
    // Nepomuk2::Query::QueryServiceClient does not emit finishedListing signal when there is no new entries (no matches).
    QTimer::singleShot(5000, this, SLOT(finishedListing()));
}

void MetadataModel::fetchResultsPage(int page)
{
    d->validIndexForPage[page] = 0;

    d->queryThread->fetchResultsPage(page);
}

void MetadataModel::countRetrieved(int count)
{
    if (count < d->data.size()) {
        beginRemoveRows(QModelIndex(), count-1, d->data.size()-1);
        d->data.resize(count);
        endRemoveRows();
    } else if (count > d->data.size()) {
        beginInsertRows(QModelIndex(), d->data.size(), count-1);
        d->data.resize(count);
        endInsertRows();
    }
}

void MetadataModel::newEntries(const QList< Nepomuk2::Query::Result > &entries, int page)
{
    foreach (const Nepomuk2::Query::Result &res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //kDebug() << "Result label:" << res.genericLabel();

        d->totalCount += res.additionalBinding(QLatin1String("count")).variant().toInt();
    }

    d->dataToInsert[page] << entries;

    if (!d->newEntriesTimer->isActive() && !d->dataToInsert[page].isEmpty()) {
        d->newEntriesTimer->start(200);
    }
    if (d->totalCount > 0) {
        emit totalCountChanged();
    }
}

void MetadataModel::newEntriesDelayed()
{
    if (d->dataToInsert.isEmpty()) {
        return;
    }

    d->elapsedTime.start();
    QHash<int, QList<Nepomuk2::Query::Result> >::const_iterator i;
    for (i = d->dataToInsert.constBegin(); i != d->dataToInsert.constEnd(); ++i) {
        const QList<Nepomuk2::Query::Result> dataToInsert = i.value();

        d->watcher->stop();

        int pageStart = 0;
        if (d->pageSize > 0) {
            pageStart = i.key() * d->pageSize;
        }
        int startOffset = d->validIndexForPage.value(i.key());
        int offset = startOffset;

        //if new result arrive on an already running query, they may arrive before countQueryResult
        if (d->data.size() < pageStart + startOffset + 1) {
            beginInsertRows(QModelIndex(), d->data.size(), pageStart + startOffset);
            d->data.resize(pageStart + startOffset + 1);
            endInsertRows();
        }
        //this happens only when d->validIndexForPage has been invalidate by row removal
        if (!d->validIndexForPage.contains(i.key()) && (d->data[pageStart + startOffset].resource().isValid() || d->data[pageStart + startOffset].additionalBindings().count() > 0)) {
            while (pageStart + startOffset < d->data.size() && (d->data[pageStart + startOffset].resource().isValid() || d->data[pageStart + startOffset].additionalBindings().count() > 0)) {
                ++startOffset;
                ++offset;
            }
        }

        foreach (const Nepomuk2::Query::Result &res, dataToInsert) {
            //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
            //kDebug() << "Page:" << i.key() << "Index:"<< pageStart + offset;

            if (res.resource().isValid()) {
                d->uriToRow[res.resource().uri()] = pageStart + offset;
            }

            //there can be new results before the count query gets updated
            if (pageStart + offset < d->data.size()) {
                d->data[pageStart + offset] = res;
                if (res.resource().isValid()) {
                    d->watcher->addResource(res.resource());
                }
                ++offset;
            } else {
                beginInsertRows(QModelIndex(), d->data.size(), pageStart + offset);
                d->data.resize(pageStart + offset + 1);
                d->data[pageStart + offset] = res;
                if (res.resource().isValid()) {
                    d->watcher->addResource(res.resource());
                }
                ++offset;
                endInsertRows();
            }
        }

        d->validIndexForPage[i.key()] = offset;

        d->watcher->start();
        emit dataChanged(createIndex(pageStart + startOffset, 0),
                         createIndex(pageStart + startOffset + dataToInsert.count()-1, 0));
    }
    kDebug() << "Elapsed time populating the model" << d->elapsedTime.elapsed();
    d->dataToInsert.clear();
}

void MetadataModel::propertyChanged(Nepomuk2::Resource res, Nepomuk2::Types::Property prop, QVariant val)
{
    Q_UNUSED(prop)
    Q_UNUSED(val)

    const int index = d->uriToRow.value(res.uri());
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
    int oldTotalCount = d->totalCount;
    QMap<int, int> toRemove;
    foreach (const QUrl &url, urls) {
        const int index = d->uriToRow.value(url);
        const int count = d->data[index].additionalBinding("count").variant().toInt();
        if (count) {
            d->totalCount -= count;
        }
        if (index == prevIndex + 1) {
            toRemove[prevIndex]++;
        } else {
            toRemove[index] = 1;
        }
        prevIndex = index;
    }

    if (oldTotalCount != d->totalCount) {
        emit totalCountChanged();
    }

    //all the page indexes may be invalid now
    d->validIndexForPage.clear();

    QMap<int, int>::const_iterator i = toRemove.constEnd();

    while (i != toRemove.constBegin()) {
        --i;
        beginRemoveRows(QModelIndex(), i.key(), i.key()+i.value()-1);
        d->data.remove(i.key(), i.value());
        endRemoveRows();
    }

    //another loop, we don't depend to d->uriToRow in data(), but we take this doublesafety
    foreach (const QUrl &url, urls) {
        d->uriToRow.remove(url);
    }

    //FIXME: this loop makes all the optimizations useless, get rid either of it or the optimizations
    for (int i = 0; i < d->data.count(); ++i) {
        d->uriToRow[d->data[i].resource().uri()] = i;
    }

    emit countChanged();
}

QVariant MetadataModel::data(const QModelIndex &index, int role) const
{
    if (!d->queryProvider || !index.isValid() || index.column() != 0 ||
        index.row() < 0 || index.row() >= d->data.count()){
        return QVariant();
    }

    //if the resource is not valid *and* there are no additional bindings means no data in these rows was fetched in nepomuk yet
    if (!d->data[index.row()].resource().isValid() &&
        d->data[index.row()].additionalBindings().count() == 0) {
        if (d->pageSize > 0 && !d->queryThread->hasQueryOnPage(floor(index.row()/d->pageSize))) {
            d->queryThread->fetchResultsPage(floor(index.row()/d->pageSize));
            return QVariant();
        //d->pageSize <= 0, means fetch all
        } else if (!d->queryThread->hasQueryOnPage(0)) {
            d->queryThread->fetchResultsPage(0);
            return QVariant();
        } else {
            return QVariant();
        }
    }


    switch (role) {
    case AbstractQueryProvider::ResultRow:
        return index.row();
    default:
        return d->queryProvider.data()->formatData(d->data[index.row()], QPersistentModelIndex(index), role);
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
        disconnect(d->queryTimer, SIGNAL(timeout()), this, SLOT(doQuery()));
        connect(d->queryTimer, SIGNAL(timeout()), this, SLOT(doQuery()));
        doQuery();
    }
}

#include "metadatamodel.moc"
