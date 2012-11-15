/*
    Copyright 2012 Marco Martin <notmart@gmail.com>

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

#ifndef ABSTRACTQUERYPROVIDER_H
#define ABSTRACTQUERYPROVIDER_H

#include <QObject>
#include <QPersistentModelIndex>

#include <Nepomuk2/Query/Query>
#include <Nepomuk2/Query/Result>

namespace Nepomuk2 {
    class ResourceWatcher;
}

class QDBusServiceWatcher;
class QTimer;

class AbstractQueryProviderPrivate;

/**
 * This is the base class for the query providers of the Nepomuk metadata model: a query provider does three things:
 *
 * * Provide custom role Ids for the model and the mapping to strings the QML view will use.
 *
 * * Provide either a Nepomuk2::Query::Query or a Sparql Query to the model to execute
 *
 * * When is time to fetch the actual data, format the data corresponding to the needed role based on a Nepomuk2::Query::Result
 *
 * @author Marco Martin <mart@kde.org>
 */
class AbstractQueryProvider : public QObject
{
    Q_OBJECT

public:
    AbstractQueryProvider(QObject *parent = 0);
    ~AbstractQueryProvider();


    /**
     * mapping role id -> role name
     */
    QHash<int, QByteArray> roleNames() const;
    /**
     * mapping role id-> role name
     */
    QHash<QString, int> roleIds() const;

    /**
     * Default implementation does nothing
     */
    virtual QVariant formatData(const Nepomuk2::Query::Result &rowData, const QPersistentModelIndex &index, int role) const;

    /**
     * Nepomuk query that will be used for the model.
     * Is mutually exclusive with sparqlQuery().
     * Use this one when possible.
     */
    Nepomuk2::Query::Query query() const;

    /**
     * Sparql query that will be used for the model.
     * Is mutually exclusive with query().
     * Use the Nepomuk query instead when possible.
     */
    QString sparqlQuery() const;

protected:
    /**
     * Set a query that will be used for popuplating the model.
     * It is mutually exclusive with setSparqlQuery and is preferred to it.
     * If there was a sparqlQuery set, it will be removed.
     */
    void setQuery(const Nepomuk2::Query::Query &query);

    /**
     * Sets a Sparql query that will be used for popuplating the model.
     * It is mutually exclusive with setQuery. Use setQuery when possible.
     * If there is a query set, it will be removed
     */
    void setSparqlQuery(const QString &query);

    /**
     * Sets a map between role names and role ids. This is required for models to work in QML
     */
    void setRoleNames(const QHash<int, QByteArray> &names);

Q_SIGNALS:
    /**
     * Emitted when you want to request the model to refresh the data in index.
     * (ie formatData would retrieve a different result, such as a thumbnail finished loading)
     * @param index index of the model row we want to change
     */
    void dataFormatChanged(const QPersistentModelIndex &index);

    /**
     * Emitted when the provided Nepomuk2::Query::Query has changed
     */
    void queryChanged();

    /**
     * Emitted when the provided sparql query has changed
     */
    void sparqlQueryChanged();

private:
    AbstractQueryProviderPrivate *const d;
};

#endif
