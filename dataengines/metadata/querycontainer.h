/*
    Copyright 2011 Marco Martin <mart@kde.org>
    Copyright 2011 Sebastian Kügler <sebas@kde.org>

    This library is free software; you can redistribute it and/or modify it
    under the terms of the GNU Library General Public License as published by
    the Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    This library is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public
    License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
    02110-1301, USA.
*/

#ifndef QUERYCONTAINER_H
#define QUERYCONTAINER_H

#include <Plasma/DataContainer>

#include <Nepomuk/Query/Query>
#include <Nepomuk/Query/Result>
#include <Nepomuk/Query/QueryServiceClient>
#include <Nepomuk/Resource>

namespace Nepomuk {
    class ResourceWatcher;
}

class QDBusServiceWatcher;

class QueryContainer : public Plasma::DataContainer
{
    Q_OBJECT

public:
    QueryContainer(const Nepomuk::Query::Query &query, QObject *parent = 0);
    ~QueryContainer();

    //FIXME: should be protected
    void addResource(Nepomuk::Resource resource);

protected Q_SLOTS:
    void newEntries(const QList< Nepomuk::Query::Result > &entries);
    void entriesRemoved(const QList<QUrl> &urls);
    void serviceRegistered(const QString &service);
    void propertyChanged(Nepomuk::Resource res, Nepomuk::Types::Property, QVariant);
    void addWatcherDelayed();
    void addResourcesDelayed();

protected:
    QString icon(const QStringList &types);
    void doQuery();

private:
    Nepomuk::Query::Query m_query;
    Nepomuk::Query::QueryServiceClient *m_queryClient;
    Nepomuk::ResourceWatcher* m_watcher;
    QList<Nepomuk::Resource> m_resourcesToWatch;
    QHash<QString, QString> m_icons;
    QDBusServiceWatcher *m_queryServiceWatcher;
    QList<Nepomuk::Resource> m_resourcesToAdd;
    QTimer *m_addWatcherTimer;
    QTimer *m_addResourcesTimer;
};

#endif
