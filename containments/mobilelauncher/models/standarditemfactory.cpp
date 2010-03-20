/*
    Copyright 2009 Ivan Cukic <ivan.cukic+kde@gmail.com>
    Copyright 2010 Marco Martin <notmart@gmail.com>

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

#include "standarditemfactory.h"
#include "commonmodel.h"

QStandardItem *StandardItemFactory::createItem(const QIcon & icon, const QString & title,
        const QString & description, const QString & url, qreal weight, int actionType)
{
    QStandardItem *appItem = new QStandardItem;

    appItem->setText(title);
    appItem->setIcon(icon);
    appItem->setData(description, CommonModel::Description);
    appItem->setData(url, CommonModel::Url);
    appItem->setData(weight, CommonModel::Weight);
    appItem->setData(actionType, CommonModel::ActionTypeRole);

    return appItem;
}
