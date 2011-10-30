/*
 *   Copyright 2010 by Marco Martin <mart@kde.org>
 *   Copyright 2011 by Sebastian Kügler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "configmodel.h"

#include <QTimer>

#include <KConfig>
#include <KConfigGroup>
#include <KDebug>

namespace Plasma
{

class ConfigModelPrivate {

public:
    ConfigModelPrivate(ConfigModel *q):
                  q(q) {}
    ConfigModel* q;
    int maxRoleId;
    KConfig* config;
};


ConfigModel::ConfigModel(QObject* parent)
    : QAbstractItemModel(parent),
      d(0)
{
    d = new ConfigModelPrivate(this);
    d->config = 0;
    d->maxRoleId = Qt::UserRole+1;
//     //There is one reserved role name: DataEngineSource
//     m_roleNames[d->maxRoleId] = "DataEngineSource";
//     m_roleIds["DataEngineSource"] = d->maxRoleId;
//     ++d->maxRoleId;
// 
//     setObjectName("ConfigModel");
//     connect(this, SIGNAL(rowsInserted(const QModelIndex &, int, int)),
//             this, SIGNAL(countChanged()));
//     connect(this, SIGNAL(rowsRemoved(const QModelIndex &, int, int)),
//             this, SIGNAL(countChanged()));
//     connect(this, SIGNAL(modelReset()),
//             this, SIGNAL(countChanged()));
}

ConfigModel::~ConfigModel()
{
    delete d->config;
    delete d;
}


// void ConfigModel::setSourceFilter(const QString& key)
// {
//     if (m_sourceFilter == key) {
//         return;
//     }
// 
//     m_sourceFilter = key;
//     m_sourceFilterRE = QRegExp(key);
//     /*
//      FIXME: if the user changes the source filter, it won't immediately be reflected in the
//      available data
//     if (m_sourceFilterRE.isValid()) {
//         .. iterate through all items and weed out the ones that don't match ..
//     }
//     */
// }

// QString ConfigModel::sourceFilter() const
// {
// //     return m_sourceFilter;
// }


QVariant ConfigModel::data(const QModelIndex &index, int role) const
{
//     if (!index.isValid() || index.column() > 0 ||
//         index.row() < 0 || index.row() >= countItems()){
//         return QVariant();
//     }
// 
//     int count = 0;
//     int actualRow = 0;
//     QString source;
//     QMap<QString, QVector<QVariant> >::const_iterator i;
//     for (i = m_items.constBegin(); i != m_items.constEnd(); ++i) {
//         const int oldCount = count;
//         count += i.value().count();
// 
//         if (index.row() < count) {
//             source = i.key();
//             actualRow = index.row() - oldCount;
//             break;
//         }
//     }
// 
//     //is it the reserved role: DataEngineSource ?
//     //also, if each source is an item DataEngineSource is a role between all the others, otherwise we know it from the role variable
//     //finally, sub items are some times QVariantHash some times QVariantMaps
//     if (!m_keyRoleFilter.isEmpty() && m_roleNames.value(role) == "DataEngineSource") {
//         return source;
//     } else if (m_items.value(source).value(actualRow).canConvert<QVariantHash>()) {
//         return m_items.value(source).value(actualRow).value<QVariantHash>().value(m_roleNames.value(role));
//     } else {
//         return m_items.value(source).value(actualRow).value<QVariantMap>().value(m_roleNames.value(role));
//     }
    return QVariant();
}

QModelIndex ConfigModel::index(int row, int column, const QModelIndex &parent) const
{
//     if (parent.isValid() || column > 0 || row < 0 || row >= countItems()) {
         return QModelIndex();
//     }
// 
//     return createIndex(row, column, 0);
}

QModelIndex ConfigModel::parent(const QModelIndex &child) const
{
    Q_UNUSED(child)

    return QModelIndex();
}

int ConfigModel::rowCount(const QModelIndex &parent) const
{
    //this is not a tree
    //TODO: make it possible some day?
    if (parent.isValid()) {
        return 0;
    }
    return 0;
    //return countItems();
}

int ConfigModel::columnCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return 1;
}

int ConfigModel::roleNameToId(const QString &name)
{
    //if (!m_roleIds.contains(name)) {
        return -1;
    //}
    //return 0;
    //return m_roleIds.value(name);
}

}

#include "configmodel.moc"
