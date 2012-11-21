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

    void fetchResultsPage(int page);

    //Slots
    void countRetrieved(int count);
    void newEntries(const QList< Nepomuk2::Query::Result > &entries, int page);
    void entriesRemoved(const QList<QUrl> &urls);
    void doQuery();
    void queryError(const QString &error);
    void newEntriesDelayed();
    void propertyChanged(Nepomuk2::Resource res, Nepomuk2::Types::Property prop, QVariant val);
    void dataFormatChanged(const QPersistentModelIndex &index);
    void serviceRegistered(const QString &service);

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
    d->doQuery();
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

////Private
void MetadataModelPrivate::doQuery()
{
    if (!queryProvider) {
        return;
    }

    totalCount = 0;

    query = queryProvider.data()->query();
    if (query.isValid()) {
        sparqlQuery.clear();
        if (limit > 0) {
            query.setLimit(limit);
        }
        kWarning() << "Sparql query:" << query.toSparqlQuery();
    } else {
        sparqlQuery = queryProvider.data()->sparqlQuery();
        kWarning() << "Sparql query:" << sparqlQuery;
    }

    q->beginResetModel();
    data = QVector<Nepomuk2::Query::Result>(0);
    uriToRow.clear();
    dataToInsert.clear();
    validIndexForPage.clear();
    q->endResetModel();
    emit q->countChanged();
    emit q->totalCountChanged();


    if (query.isValid()) {
        queryThread->setQuery(query, limit, pageSize);
    } else {
        queryThread->setSparqlQuery(sparqlQuery);
    }

    //if page size is invalid, fetch all
    if (pageSize < 1) {
        fetchResultsPage(0);
    }
}

void MetadataModelPrivate::queryError(const QString &error)
{
    kDebug() << error;
}

void MetadataModelPrivate::fetchResultsPage(int page)
{
    validIndexForPage[page] = 0;

    queryThread->fetchResultsPage(page);
}

void MetadataModelPrivate::countRetrieved(int count)
{
    if (count < data.size()) {
        q->beginRemoveRows(QModelIndex(), count-1, data.size()-1);
        data.resize(count);
        q->endRemoveRows();
    } else if (count > data.size()) {
        q->beginInsertRows(QModelIndex(), data.size(), count-1);
        data.resize(count);
        q->endInsertRows();
    }
}

void MetadataModelPrivate::newEntries(const QList< Nepomuk2::Query::Result > &entries, int page)
{
    foreach (const Nepomuk2::Query::Result &res, entries) {
        //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
        //kDebug() << "Result label:" << res.genericLabel();

        totalCount += res.additionalBinding(QLatin1String("count")).variant().toInt();
    }

    dataToInsert[page] << entries;

    if (!newEntriesTimer->isActive() && !dataToInsert[page].isEmpty()) {
        newEntriesTimer->start(200);
    }
    if (totalCount > 0) {
        emit q->totalCountChanged();
    }
}

void MetadataModelPrivate::newEntriesDelayed()
{
    if (dataToInsert.isEmpty()) {
        return;
    }

    elapsedTime.start();
    QHash<int, QList<Nepomuk2::Query::Result> >::const_iterator i;
    for (i = dataToInsert.constBegin(); i != dataToInsert.constEnd(); ++i) {
        const QList<Nepomuk2::Query::Result> dataToInsert = i.value();

        watcher->stop();

        int pageStart = 0;
        if (pageSize > 0) {
            pageStart = i.key() * pageSize;
        }
        int startOffset = validIndexForPage.value(i.key());
        int offset = startOffset;

        //if new result arrive on an already running query, they may arrive before countQueryResult
        if (data.size() < pageStart + startOffset + 1) {
            q->beginInsertRows(QModelIndex(), data.size(), pageStart + startOffset);
            data.resize(pageStart + startOffset + 1);
            q->endInsertRows();
        }
        //this happens only when validIndexForPage has been invalidate by row removal
        if (!validIndexForPage.contains(i.key()) && (data[pageStart + startOffset].resource().isValid() || data[pageStart + startOffset].additionalBindings().count() > 0)) {
            while (pageStart + startOffset < data.size() && (data[pageStart + startOffset].resource().isValid() || data[pageStart + startOffset].additionalBindings().count() > 0)) {
                ++startOffset;
                ++offset;
            }
        }

        foreach (const Nepomuk2::Query::Result &res, dataToInsert) {
            //kDebug() << "Result!!!" << res.resource().genericLabel() << res.resource().type();
            //kDebug() << "Page:" << i.key() << "Index:"<< pageStart + offset;

            if (res.resource().isValid()) {
                uriToRow[res.resource().uri()] = pageStart + offset;
            }

            //there can be new results before the count query gets updated
            if (pageStart + offset < data.size()) {
                data[pageStart + offset] = res;
                if (res.resource().isValid()) {
                    watcher->addResource(res.resource());
                }
                ++offset;
            } else {
                q->beginInsertRows(QModelIndex(), data.size(), pageStart + offset);
                data.resize(pageStart + offset + 1);
                data[pageStart + offset] = res;
                if (res.resource().isValid()) {
                    watcher->addResource(res.resource());
                }
                ++offset;
                q->endInsertRows();
            }
        }

        validIndexForPage[i.key()] = offset;

        watcher->start();
        emit q->dataChanged(q->createIndex(pageStart + startOffset, 0),
                            q->createIndex(pageStart + startOffset + dataToInsert.count()-1, 0));
    }
    kDebug() << "Elapsed time populating the model" << elapsedTime.elapsed();
    dataToInsert.clear();
}

void MetadataModelPrivate::propertyChanged(Nepomuk2::Resource res, Nepomuk2::Types::Property prop, QVariant val)
{
    Q_UNUSED(prop)
    Q_UNUSED(val)

    const int index = uriToRow.value(res.uri());
    if (index >= 0) {
        emit q->dataChanged(q->createIndex(index, 0, 0), q->createIndex(index, 0, 0));
    }
}

void MetadataModelPrivate::dataFormatChanged(const QPersistentModelIndex &index)
{
    emit q->dataChanged(index, index);
}

void MetadataModelPrivate::entriesRemoved(const QList<QUrl> &urls)
{
    int prevIndex = -100;
    //pack all the stuff to remove in groups, to emit the least possible signals
    //this assumes urls are in the same order they arrived ion the results
    //it's a map because we want to remove values from the vector in inverted order to keep indexes valid trough the remove loop
    int oldTotalCount = totalCount;
    QMap<int, int> toRemove;
    foreach (const QUrl &url, urls) {
        const int index = uriToRow.value(url);
        const int count = data[index].additionalBinding("count").variant().toInt();
        if (count) {
            totalCount -= count;
        }
        if (index == prevIndex + 1) {
            toRemove[prevIndex]++;
        } else {
            toRemove[index] = 1;
        }
        prevIndex = index;
    }

    if (oldTotalCount != totalCount) {
        emit q->totalCountChanged();
    }

    //all the page indexes may be invalid now
    validIndexForPage.clear();

    QMap<int, int>::const_iterator i = toRemove.constEnd();

    while (i != toRemove.constBegin()) {
        --i;
        q->beginRemoveRows(QModelIndex(), i.key(), i.key()+i.value()-1);
        data.remove(i.key(), i.value());
        q->endRemoveRows();
    }

    //another loop, we don't depend to uriToRow in data(), but we take this doublesafety
    foreach (const QUrl &url, urls) {
        uriToRow.remove(url);
    }

    //FIXME: this loop makes all the optimizations useless, get rid either of it or the optimizations
    for (int i = 0; i < data.count(); ++i) {
        uriToRow[data[i].resource().uri()] = i;
    }

    emit q->countChanged();
}

void MetadataModelPrivate::serviceRegistered(const QString &service)
{
    if (service == QLatin1String("org.kde.nepomuk.services.nepomukqueryservice")) {
        QObject::disconnect(queryTimer, SIGNAL(timeout()), q, SLOT(doQuery()));
        QObject::connect(queryTimer, SIGNAL(timeout()), q, SLOT(doQuery()));
        doQuery();
    }
}

#include "metadatamodel.moc"
