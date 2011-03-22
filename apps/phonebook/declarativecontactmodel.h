/*
* Copyright 2010 Stephen Kelly <steveire@gmail.com>
* Copyright 2011 Davide Bettio <davide.bettio@kdemail.net>
*
* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the Free Software
* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
* 02110-1301  USA
*/

#ifndef DECLARATIVE_CONTACT_MODEL
#define DECLARATIVE_CONTACT_MODEL

#include <akonadi/entitytreemodel.h>
#include <kselectionproxymodel.h>
#include <QStandardItemModel>

#include <KABC/Addressee>
#include <akonadi/entity.h>

class DeclarativeContactModel : public Akonadi::EntityTreeModel
{
    Q_OBJECT
  
    public:
        enum Roles
        {
            ContactData = Akonadi::EntityTreeModel::UserRole,
            RealName = Akonadi::EntityTreeModel::UserRole + 1
        };

        DeclarativeContactModel(Akonadi::ChangeRecorder* monitor, QObject* parent = 0);
        virtual QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;
};

#endif
