/* Copyright (C) 2012 basysKom GmbH <info@basyskom.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 */

#include "languagesmodel.h"

LanguagesModel::LanguagesModel(QObject *parent)
    : QStandardItemModel(parent)
{
    QHash<int, QByteArray> roleNames;
    roleNames[Qt::DisplayRole] = "display";
    roleNames[Qt::UserRole+1] = "langCode";
    setRoleNames(roleNames);
    connect(this, SIGNAL(modelReset()), this, SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsInserted(QModelIndex,int,int)), this, SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsRemoved(QModelIndex,int,int)), this, SIGNAL(countChanged()));
}


QVariantHash LanguagesModel::get(int i) const
{
    QModelIndex idx = index(i, 0);
    QVariantHash hash;
    hash["display"] = data(idx, Qt::DisplayRole);
    hash["langCode"] = data(idx, Qt::UserRole+1);
    return hash;
}

#include "languagesmodel.moc"
