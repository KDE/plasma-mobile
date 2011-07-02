/*
 *   Copyright (C) 2011 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef DUMMY_CONTACTS_H_
#define DUMMY_CONTACTS_H_

#include <QtContacts/QContactManager>
#include <QtContacts/QContact>
#include <QtContacts/QContactName>
#include <QtContacts/QContactEmailAddress>

using namespace QtMobility;

void addDummyContact(QContactManager & manager, const QString & name, const QString & email)
{
    QContact * c = new QContact();

    QContactName * nameDetail = new QContactName();
    nameDetail->setFirstName(name);
    c->saveDetail(nameDetail);

    QContactEmailAddress * emailDetail = new QContactEmailAddress();
    emailDetail->setEmailAddress(email);
    c->saveDetail(emailDetail);

    manager.saveContact(c);
}

void addDummyContacts(QContactManager & manager)
{
    addDummyContact(manager,  "Ivan",    "john.doe@doctor.com");
    addDummyContact(manager,  "Mica",    "mica@gmail.com");
    addDummyContact(manager,  "Nikola",  "cuka@gmail.com");
    addDummyContact(manager,  "Tamara",  "bch@gmail.com");
    addDummyContact(manager,  "Anne",    "hath@gmail.com");

}


#endif // DUMMY_CONTACTS_H_
