/*
    Copyright (C) 2015  Martin Klapetek <mklapetek@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include "kpeoplehelper.h"

#include <KPeople/PersonsModel>
#include <KPeopleBackend/AbstractContact>

#include <QAbstractItemModel>
#include <QDebug>

KPeopleHelper::KPeopleHelper(QObject *parent)
    : QIdentityProxyModel(parent)
{
    m_model = new KPeople::PersonsModel(this);
    setSourceModel(m_model);
}

KPeopleHelper::~KPeopleHelper()
{
    delete m_model;
}

QVariant KPeopleHelper::data(const QModelIndex &index, int role) const
{
    if (!m_model) {
        return QVariant();
    }

    if (role == KPeopleHelper::PhoneNumberRole) {
        return m_model->contactCustomProperty(index, KPeople::AbstractContact::PhoneNumberProperty);
    }

    return m_model->data(index, role);
}

QHash<int, QByteArray> KPeopleHelper::roleNames() const
{
    QHash<int, QByteArray> roles = QAbstractItemModel::roleNames();
    roles.insert(PersonUriRole, "personUri");
    roles.insert(PersonVCardRole, "personVCard");
    roles.insert(ContactsVCardRole, "contactsVCard");
    roles.insert(PhoneNumberRole, "phoneNumber");
    return roles;
}
