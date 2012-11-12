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
    QHash<int, QByteArray> roleNames;
    roleNames[Label] = "label";
    roleNames[Count] = "count";
    roleNames[TotalCount] = "totalCount";
    setRoleNames(roleNames);
}

MetadataCloudModel::~MetadataCloudModel()
{
}

void MetadataCloudModel::setQueryProvider(BasicQueryProvider *provider)
{
    if (m_queryProvider.data() == provider) {
        return;
    }

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

    setRunning(true);
    kWarning() << "Performing the Sparql query" << query;

    beginResetModel();
    m_results.clear();
    endResetModel();
    emit countChanged();

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
        QString label;
        int count = res.additionalBinding(QLatin1String("count")).variant().toInt();
        int totalCount = res.additionalBinding(QLatin1String("totalCount")).variant().toInt();
        QVariant rawLabel = res.additionalBinding(QLatin1String("label")).variant();

        if (rawLabel.canConvert<Nepomuk2::Resource>()) {
            label = rawLabel.value<Nepomuk2::Resource>().type().toString().section( QRegExp( "[#:]" ), -1 );
        } else if (!rawLabel.value<QUrl>().scheme().isEmpty()) {
            const QUrl url = rawLabel.value<QUrl>();
            if (url.scheme() == "nepomuk") {
                label = Nepomuk2::Resource(url).genericLabel();
            //TODO: it should convert from ontology url to short form nfo:Document
            } else {
                label = propertyShortName(url);
            }
        } else if (rawLabel.canConvert<QString>()) {
            label = rawLabel.toString();
        } else if (rawLabel.canConvert<int>()) {
            label = QString::number(rawLabel.toInt());
        } else {
            continue;
        }

        /*//TODO: make allowedcategories work again somehow
        CloudQueryProvider *cp = qobject_cast<CloudQueryProvider *>(queryProvider());
        if (cp) {
            if (label.isEmpty() ||
                !(cp->allowedCategories().isEmpty() ||
                cp->allowedCategories().contains(label))) {
                continue;
            }
        }*/
        QHash<int, QVariant> result;
        result[Label] = label;
        result[Count] = count;
        result[TotalCount] = totalCount;
        results << result;
        categories << label;
    }
    if (results.count() > 0) {
        beginInsertRows(QModelIndex(), m_results.count(), m_results.count()+results.count()-1);
        m_results << results;
        m_categories << categories;
        endInsertRows();
        emit countChanged();
        emit categoriesChanged();
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

    return m_results[index.row()].value(role);

}

#include "metadatacloudmodel.moc"
