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

#include "metadatacloudmodel.h"
#include "queryproviders/basicqueryprovider.h"
#include "queryproviders/cloudqueryprovider.h"

#include <QDBusConnection>
#include <QDBusServiceWatcher>

#include <KDebug>
#include <KMimeType>

#include <soprano/vocabulary.h>

#include <Nepomuk2/File>
#include <Nepomuk2/Query/AndTerm>
#include <Nepomuk2/Query/ResourceTerm>
#include <Nepomuk2/Tag>
#include <Nepomuk2/Variant>
#include <nepomuk2/comparisonterm.h>
#include <nepomuk2/literalterm.h>
#include <nepomuk2/queryparser.h>
#include <nepomuk2/resourcetypeterm.h>
#include <nepomuk2/standardqueries.h>

#include <nepomuk2/nfo.h>
#include <nepomuk2/nie.h>

#include <kao.h>


MetadataCloudModel::MetadataCloudModel(QObject *parent)
    : AbstractMetadataModel(parent),
      m_queryClient(0)
{
}

MetadataCloudModel::~MetadataCloudModel()
{
}

void MetadataCloudModel::setQueryProvider(BasicQueryProvider *provider)
{
    if (m_queryProvider.data() == provider) {
        return;
    }

    setRoleNames(provider->roleNames());
    if (m_queryProvider) {
        disconnect(m_queryProvider.data(), 0, this, 0);
    }

    connect(provider, SIGNAL(queryChanged()), this, SLOT(doQuery()));
    connect(provider, SIGNAL(sparqlQueryChanged()), this, SLOT(doQuery()));

    m_queryProvider = provider;
    doQuery();
    emit queryProviderChanged();
}

BasicQueryProvider *MetadataCloudModel::queryProvider() const
{
    return m_queryProvider.data();
}

QVariantList MetadataCloudModel::categories() const
{
    return m_categories;
}

void MetadataCloudModel::doQuery()
{
    QString query = queryProvider()->sparqlQuery();

    m_totalCount = 0;
    setRunning(true);
    kWarning() << "Performing the Sparql query" << query;

    beginResetModel();
    m_results.clear();
    endResetModel();
    emit countChanged();
    emit totalCountChanged();

    delete m_queryClient;
    m_queryClient = new Nepomuk2::Query::QueryServiceClient(this);

    connect(m_queryClient, SIGNAL(newEntries(QList<Nepomuk2::Query::Result>)),
            this, SLOT(newEntries(QList<Nepomuk2::Query::Result>)));
    connect(m_queryClient, SIGNAL(entriesRemoved(QList<QUrl>)),
            this, SLOT(entriesRemoved(QList<QUrl>)));
    connect(m_queryClient, SIGNAL(finishedListing()), this, SLOT(finishedListing()));

    m_queryClient->sparqlQuery(query);
}

void MetadataCloudModel::newEntries(const QList< Nepomuk2::Query::Result > &entries)
{
    QVector<QHash<int, QVariant> > results;
    QVariantList categories;

    foreach (const Nepomuk2::Query::Result &res, entries) {
        QHash<int, QVariant> result;
        int count = res.additionalBinding(QLatin1String("count")).variant().toInt();
        foreach(const QString &name, res.additionalBindings().bindingNames()) {
            if (!m_queryProvider.data()->roleIds().contains(name)) {
                continue;
            }

            const QVariant val = res.additionalBinding(name.toLatin1()).variant();
            QString label;
            if (val.canConvert<QUrl>()) {
                const QUrl url = val.value<QUrl>();
                if (url.scheme() == "nepomuk") {
                    label = Nepomuk2::Resource(url).genericLabel();
                //TODO: it should convert from ontology url to short form nfo:Document
                } else {
                    label = propertyShortName(url);
                }
            } else {
                result[m_queryProvider.data()->roleIds().value(name)] = val;
                label = val.value<QString>();
            }
            result[m_queryProvider.data()->roleIds().value(name)] = label;
            if (label == "label") {
                m_categories << label;
            }
        }

        m_totalCount += count;
        results << result;
    }

    if (results.count() > 0) {
        beginInsertRows(QModelIndex(), m_results.count(), m_results.count()+results.count()-1);
        m_results << results;
        m_categories << categories;
        endInsertRows();
        emit countChanged();
        emit categoriesChanged();
        if (m_totalCount > 0) {
            emit totalCountChanged();
        }
    }
}

void MetadataCloudModel::entriesRemoved(const QList<QUrl> &urls)
{
    //FIXME: optimize
    kDebug()<<urls;
    foreach (const QUrl &url, urls) {
        const QString propName = propertyShortName(url);
        int i = 0;
        int index = -1;
        foreach (const QVariant &v, m_categories) {
            QString cat = v.toString();
            if (cat == propName) {
                index = i;
                break;
            }
            ++i;
        }
        if (index >= 0 && index < m_results.size()) {
            beginRemoveRows(QModelIndex(), index, index);
            m_results.remove(index);
            endRemoveRows();
        }
    }
    emit countChanged();
}

void MetadataCloudModel::finishedListing()
{
    setRunning(false);
}



QVariant MetadataCloudModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.column() != 0 ||
        index.row() < 0 || index.row() >= m_results.count()){
        return QVariant();
    }

    return m_queryProvider.data()->formatData(m_results[index.row()], role);
}

#include "metadatacloudmodel.moc"
