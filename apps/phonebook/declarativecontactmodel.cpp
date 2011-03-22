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

#include "declarativecontactmodel.h"

DeclarativeContactModel::DeclarativeContactModel( Akonadi::ChangeRecorder* monitor, QObject* parent )
  : EntityTreeModel(monitor, parent)
{
  QHash<int, QByteArray> rns = roleNames();
  rns.insert(RealName, "realName");
  rns.insert(ContactData, "contactData");
  setRoleNames(rns);
}

QVariant DeclarativeContactModel::data( const QModelIndex& index, int role ) const
{
    Akonadi::Item AkItem = Akonadi::EntityTreeModel::data(index, ItemRole).value<Akonadi::Item>();
    
    KABC::Addressee addressee;
    if (AkItem.isValid() && AkItem.hasPayload<KABC::Addressee>()){
        addressee = AkItem.payload<KABC::Addressee>();
    }
    
    switch (role){
        case RealName:
            return QVariant::fromValue(addressee.realName());
        
        case ContactData:
            return QVariant::fromValue(addressee);

        default:
            return Akonadi::EntityTreeModel::data(index, role);
    }
}

#include "declarativecontactmodel.moc"
