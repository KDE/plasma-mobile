/*
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

#ifndef COMMONMODEL_H
#define COMMONMODEL_H

#include <Qt>

namespace CommonModel
{
    enum ActionType {
        NoAction = 0,
        AddAction = 1,
        RemoveAction = 2
    };

    enum Roles {
        Description = Qt::UserRole+1,
        Url = Qt::UserRole+2,
        Weight = Qt::UserRole+3,
        ActionTypeRole = Qt::UserRole+4
    };
}

#endif
