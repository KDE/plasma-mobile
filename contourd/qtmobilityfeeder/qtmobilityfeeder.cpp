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

#include "qtmobilityfeeder.h"

#include <QtContacts/QContactManager>
#include <QtContacts/QContact>

#include <QtContacts/QContactName>
#include <QtContacts/QContactEmailAddress>
#include <QtContacts/QContactTimestamp>

#include <Nepomuk/Resource>
#include <Nepomuk/Variant>

#include "nco.h"
#include "nao.h"
#include "nie.h"

#include <KDebug>

#include "dummycontacts.h"

using namespace QtMobility;
using namespace Nepomuk::Vocabulary;

namespace Contour {

class QtMobilityFeederPrivate {
public:

    static QContactId uriToId(const QString & uri)
    {
        QContactId result;
        int position = uri.lastIndexOf('/');

        if (position != -1) {
            kDebug() << uri.left(position);
            kDebug() << uri.mid(position + 1);
        }

        return result;
    }

    static QString idToUri(const QContactId & id)
    {
        kDebug() << id.managerUri() + '/' + QString::number(id.localId());
        return id.managerUri() + '/' + QString::number(id.localId());
    }

    QContactManager * manager;
    QString managerName;
};

QtMobilityFeeder::QtMobilityFeeder(const QString & managerName)
    : d(new QtMobilityFeederPrivate())
{
    d->managerName = managerName;
}

void QtMobilityFeeder::run()
{
    d->manager = new QContactManager(d->managerName);

    if (d->managerName == "memory") {
        ::addDummyContacts(d->manager);
    }

    connect(d->manager, SIGNAL(contactsAdded(QList < QContactLocalId >)),
            this,     SLOT(contactsAdded(QList < QContactLocalId >)));
    connect(d->manager, SIGNAL(contactsChanged(QList < QContactLocalId >)),
            this,     SLOT(contactsChanged(QList < QContactLocalId >)));
    connect(d->manager, SIGNAL(contactsRemoved(QList < QContactLocalId >)),
            this,     SLOT(contactsRemoved(QList < QContactLocalId >)));
    connect(d->manager, SIGNAL(dataChanged()),
            this,     SLOT(dataChanged()));

    foreach (const QContact & contact, d->manager->contacts()) {
        // TODO: Support contact groups later?
        if (contact.type() != QContactType::TypeContact) continue;

        updateContact(contact);
    }

    kDebug() << "List ended";
}

QtMobilityFeeder::~QtMobilityFeeder()
{
    delete d->manager;
    delete d;
}

void QtMobilityFeeder::updateContact(const QContact & contact)
{
    // To list all QtMobility contacts in Nepomuk, do:
    // select ?contact, ?url where {
    //     ?contact a nco:Contact .
    //     ?contact nie:url ?url .
    //     FILTER (regex(?url, '^qtcontacts') )
    // }

    const QString & contactResId = d->idToUri(contact.id());
    Nepomuk::Resource contactRes(contactResId, NCO::Contact());
    contactRes.removeProperty(NCO::hasEmailAddress());

    foreach(const QContactDetail & detail, contact.details()) {
        kDebug() << detail;
        const QString type = detail.definitionName();

        #define SET_PROPERTY_VARIANT(Property, Value, Cast) \
            if (detail.hasValue(Value)) contactRes.setProperty(Property(), detail.variantValue(Value).Cast());
        #define SET_PROPERTY(Property, Value) \
            if (detail.hasValue(Value)) contactRes.setProperty(Property(), detail.value(Value));

        // TODO: Feed other fields
        if (type == QContactDisplayLabel::DefinitionName) {
            contactRes.setLabel(detail.value("Label"));

        } else if (type == QContactName::DefinitionName) {
            SET_PROPERTY(NCO::nameGiven,            QContactName::FieldFirstName);
            SET_PROPERTY(NCO::nameGiven,            QContactName::FieldFirstName);
            SET_PROPERTY(NCO::nameFamily,           QContactName::FieldLastName);
            SET_PROPERTY(NCO::nameAdditional,       QContactName::FieldMiddleName);
            SET_PROPERTY(NCO::nameHonorificPrefix,  QContactName::FieldPrefix);
            SET_PROPERTY(NCO::nameHonorificSuffix,  QContactName::FieldSuffix);

        } else if (type == QContactEmailAddress::DefinitionName) {
            // TODO: Multiple e-mail addresses
            Nepomuk::Resource emailRes("mailto:" + detail.value(QContactEmailAddress::FieldEmailAddress), NCO::EmailAddress());
            emailRes.setProperty(NCO::emailAddress(), detail.value(QContactEmailAddress::FieldEmailAddress));

            contactRes.addProperty(NCO::hasEmailAddress(), emailRes);

        } else if (type == QContactTimestamp::DefinitionName) {
            SET_PROPERTY_VARIANT(NIE::lastModified, QContactTimestamp::FieldModificationTimestamp, toDateTime);
            SET_PROPERTY_VARIANT(NIE::lastModified, QContactTimestamp::FieldCreationTimestamp, toDateTime);

        }

        #undef SET_PROPERTY_VARIANT
        #undef SET_PROPERTY
    }
}

void QtMobilityFeeder::contactsAdded(const QList < QContactLocalId > & contactIds)
{
    foreach (const QContactLocalId & id, contactIds) {
        updateContact(d->manager->contact(id));
    }
}

void QtMobilityFeeder::contactsChanged(const QList < QContactLocalId > & contactIds)
{
    foreach (const QContactLocalId & id, contactIds) {
        updateContact(d->manager->contact(id));
    }
}

void QtMobilityFeeder::contactsRemoved(const QList < QContactLocalId > & contactIds)
{
}

void QtMobilityFeeder::dataChanged()
{
}

} // namespace Contour
