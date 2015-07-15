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

#ifndef KPEOPLEHELPER_H
#define KPEOPLEHELPER_H

#include <QObject>
#include <QIdentityProxyModel>

namespace KPeople {
    class PersonsModel;
}

class QAbstractItemModel;

class KPeopleHelper : public QIdentityProxyModel
{
    Q_OBJECT

public:
    enum Role {
        FormattedNameRole = Qt::DisplayRole,//QString best name for this person
        PhotoRole = Qt::DecorationRole, //QPixmap best photo for this person
        PersonUriRole = Qt::UserRole, //QString ID of this person
        PersonVCardRole, //AbstractContact::Ptr
        ContactsVCardRole, //AbstractContact::List (FIXME or map?)

        GroupsRole, ///groups QStringList
        PhoneNumberRole, //QString

        UserRole = Qt::UserRole + 0x1000 ///< in case it's needed to extend, use this one to start from
    };
    Q_ENUMS(Role)

    KPeopleHelper(QObject *parent = 0);
    ~KPeopleHelper();

    virtual QVariant data(const QModelIndex &index, int role) const Q_DECL_OVERRIDE;
    virtual QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;

private:
    KPeople::PersonsModel *m_model;
};

#endif // KPEOPLEHELPER_H
