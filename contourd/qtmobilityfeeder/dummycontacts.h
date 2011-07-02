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
#include <QStringList>

using namespace QtMobility;

void addDummyContact(QContactManager * manager, const QString & name, const QString & surname, const QStringList & emails)
{
    QContact * c = new QContact();

    QContactName * nameDetail = new QContactName();
    nameDetail->setFirstName(name);
    nameDetail->setLastName(surname);
    c->saveDetail(nameDetail);

    foreach (const QString & email, emails) {
        QContactEmailAddress * emailDetail = new QContactEmailAddress();
        emailDetail->setEmailAddress(email);
        c->saveDetail(emailDetail);
    }

    manager->saveContact(c);
}

void addDummyContact(QContactManager * manager, const QString & name, const QString & surname, const QString & email)
{
    addDummyContact(manager, name, surname, QStringList() << email);
}

void addDummyContacts(QContactManager * manager)
{
    addDummyContact(manager,  "Ivan",    "Cukic",     "john.doe@doctor.com");
    addDummyContact(manager,  "Mica",    "Zivic",     "mica@gmail.com");
    addDummyContact(manager,  "Nikola",  "Jelic",     QStringList() << "cuka@gmail.com" << "mr02020@alas.rs");
    addDummyContact(manager,  "Tamara",  "Mani",      "bch@gmail.com");
    addDummyContact(manager,  "Anne",    "Hathaway",  "hath@gmail.com");

}


#endif // DUMMY_CONTACTS_H_
