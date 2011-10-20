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

#ifndef METADATACLOUDMODEL_H
#define METADATACLOUDMODEL_H

#include "abstractmetadatamodel.h"

#include <QDate>

#include <Nepomuk/Query/Query>
#include <Nepomuk/Query/Result>
#include <Nepomuk/Query/QueryServiceClient>
#include <Nepomuk/Resource>


namespace Nepomuk {
    class ResourceWatcher;
}

class QDBusServiceWatcher;
class QTimer;

class MetadataCloudModel : public AbstractMetadataModel
{
    Q_OBJECT

    Q_PROPERTY(CloudCategory cloudCategory READ cloudCategory WRITE setCloudCategory NOTIFY cloudCategoryChanged)

    Q_ENUMS(CloudCategory)

public:
    enum Roles {
        Label = Qt::UserRole+1,
        Count
    };

    enum CloudCategory {
        NoCategory = 0,
        TypeCategory,
        RatingCategory
    };

    MetadataCloudModel(QObject *parent = 0);
    ~MetadataCloudModel();

    virtual int count() const {return m_results.count();}

    void setCloudCategory(CloudCategory category);
    CloudCategory cloudCategory() const;

    //Reimplemented
    QVariant data(const QModelIndex &index, int role) const;

Q_SIGNALS:
   void cloudCategoryChanged();

protected Q_SLOTS:
    void newEntries(const QList< Nepomuk::Query::Result > &entries);
    void entriesRemoved(const QList<QUrl> &urls);
    virtual void doQuery();

private:
    Nepomuk::Query::QueryServiceClient *m_queryClient;
    QVector<QPair<QString, int> > m_results;
    QTimer *m_queryTimer;

    //pieces to build m_query
    CloudCategory m_cloudCategory;
};

#endif
