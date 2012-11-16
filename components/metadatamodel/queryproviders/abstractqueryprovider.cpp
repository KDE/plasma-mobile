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

#include "abstractqueryprovider.h"


#include <KDebug>


class AbstractQueryProviderPrivate
{
public:
    AbstractQueryProviderPrivate()
    {}

    QHash<int, QByteArray> roleNames;
    QHash<QString, int> roleIds;

    Nepomuk2::Query::Query query;
    QString sparqlQuery;
};

AbstractQueryProvider::AbstractQueryProvider(QObject *parent)
    : QObject(parent),
      d(new AbstractQueryProviderPrivate())
{
}

AbstractQueryProvider::~AbstractQueryProvider()
{
}


void AbstractQueryProvider::setRoleNames(const QHash<int, QByteArray> &names)
{
    d->roleNames = names;
    d->roleNames[ResultRow] = "resultRow";
    d->roleIds.clear();
    QHash<int, QByteArray>::const_iterator i;
    for (i = names.constBegin(); i != names.constEnd(); ++i) {
        d->roleIds[i.value()] = i.key();
    }
}

QHash<int, QByteArray> AbstractQueryProvider::roleNames() const
{
    return d->roleNames;
}

QHash<QString, int> AbstractQueryProvider::roleIds() const
{
    return d->roleIds;
}

QVariant AbstractQueryProvider::formatData(const Nepomuk2::Query::Result &row, const QPersistentModelIndex &index, int role) const
{
    //Abstract, implement in subclasses
    Q_UNUSED(row)
    Q_UNUSED(index)
    Q_UNUSED(role)
    return QVariant();
}

void AbstractQueryProvider::setQuery(const Nepomuk2::Query::Query &query)
{
    d->query = query;

    emit queryChanged();
}

Nepomuk2::Query::Query AbstractQueryProvider::query() const
{
    return d->query;
}

void AbstractQueryProvider::setSparqlQuery(const QString &query)
{
    if (d->sparqlQuery == query) {
        return;
    }

    d->sparqlQuery = query;
    emit sparqlQueryChanged();
}

QString AbstractQueryProvider::sparqlQuery() const
{
    return d->sparqlQuery;
}



#include "abstractqueryprovider.moc"
