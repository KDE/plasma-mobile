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

#include <QtContacts/QContactAddress>
#include <QtContacts/QContactBirthday>
#include <QtContacts/QContactEmailAddress>
#include <QtContacts/QContactGender>
#include <QtContacts/QContactName>
#include <QtContacts/QContactNickname>
#include <QtContacts/QContactNote>
#include <QtContacts/QContactOnlineAccount>
#include <QtContacts/QContactPhoneNumber>
#include <QtContacts/QContactTag>
#include <QtContacts/QContactTimestamp>
#include <QtContacts/QContactUrl>

#include <Nepomuk/Resource>
#include <Nepomuk/Variant>
#include <Nepomuk/Tag>

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

        #define SET_PROPERTY_VARIANT(Resource, Property, Value, Cast) \
            if (detail.hasValue(Value)) Resource.setProperty(Property(), detail.variantValue(Value).Cast());
        #define SET_PROPERTY(Resource, Property, Value) \
            if (detail.hasValue(Value)) Resource.setProperty(Property(), detail.value(Value));

        // TODO: Feed other fields
        if (type == QContactDisplayLabel::DefinitionName) {
            contactRes.setLabel(detail.value(QContactDisplayLabel::FieldLabel));

        } else if (type == QContactName::DefinitionName) {
            SET_PROPERTY(contactRes, NCO::nameGiven,            QContactName::FieldFirstName);
            SET_PROPERTY(contactRes, NCO::nameFamily,           QContactName::FieldLastName);
            SET_PROPERTY(contactRes, NCO::nameAdditional,       QContactName::FieldMiddleName);
            SET_PROPERTY(contactRes, NCO::nameHonorificPrefix,  QContactName::FieldPrefix);
            SET_PROPERTY(contactRes, NCO::nameHonorificSuffix,  QContactName::FieldSuffix);

        } else if (type == QContactEmailAddress::DefinitionName) {
            Nepomuk::Resource emailRes("mailto:" + detail.value(QContactEmailAddress::FieldEmailAddress), NCO::EmailAddress());
            emailRes.setProperty(NCO::emailAddress(), detail.value(QContactEmailAddress::FieldEmailAddress));

            contactRes.addProperty(NCO::hasEmailAddress(), emailRes);

        } else if (type == QContactTimestamp::DefinitionName) {
            SET_PROPERTY_VARIANT(contactRes, NIE::lastModified, QContactTimestamp::FieldModificationTimestamp, toDateTime);
            SET_PROPERTY_VARIANT(contactRes, NIE::lastModified, QContactTimestamp::FieldCreationTimestamp, toDateTime);

        } else if (type == QContactAddress::DefinitionName) {
            Nepomuk::Resource addressRes("mailto:" + detail.value(QContactEmailAddress::FieldEmailAddress), NCO::PostalAddress());

            SET_PROPERTY(addressRes,  NCO::country,        QContactAddress::FieldCountry);
            SET_PROPERTY(addressRes,  NCO::locality,       QContactAddress::FieldLocality);
            SET_PROPERTY(addressRes,  NCO::pobox,          QContactAddress::FieldPostOfficeBox);
            SET_PROPERTY(addressRes,  NCO::postalcode,     QContactAddress::FieldPostcode);
            SET_PROPERTY(addressRes,  NCO::region,         QContactAddress::FieldRegion);
            SET_PROPERTY(addressRes,  NCO::streetAddress,  QContactAddress::FieldStreet);

        } else if (type == QContactBirthday::DefinitionName) {
            SET_PROPERTY_VARIANT(contactRes, NCO::birthDate, QContactBirthday::FieldBirthday, toDateTime);

        } else if (type == QContactGender::DefinitionName) {
            SET_PROPERTY(contactRes, NCO::gender, QContactGender::FieldGender);

        } else if (type == QContactNickname::DefinitionName) {
            SET_PROPERTY(contactRes, NCO::nickname, QContactNickname::FieldNickname);

        } else if (type == QContactNote::DefinitionName) {
            SET_PROPERTY(contactRes, NCO::note, QContactNote::FieldNote);

        } else if (type == QContactPhoneNumber::DefinitionName) {
            Nepomuk::Resource phoneResource(detail.value(QContactPhoneNumber::FieldNumber), NCO::PhoneNumber());

            SET_PROPERTY(phoneResource, NCO::hasPhoneNumber, QContactPhoneNumber::FieldNumber);

            foreach (const QString & subType, ((QContactPhoneNumber)detail).subTypes()) {
                if (subType == QContactPhoneNumber::SubTypeCar)
                    phoneResource.addType(NCO::CarPhoneNumber());
                else if (subType == QContactPhoneNumber::SubTypeFax)
                    phoneResource.addType(NCO::FaxNumber());
                else if (subType == QContactPhoneNumber::SubTypeLandline)
                    phoneResource.addType(NCO::PhoneNumber());
                else if (subType == QContactPhoneNumber::SubTypeMessagingCapable)
                    phoneResource.addType(NCO::MessagingNumber());
                else if (subType == QContactPhoneNumber::SubTypeMobile)
                    phoneResource.addType(NCO::CellPhoneNumber());
                else if (subType == QContactPhoneNumber::SubTypeModem)
                    phoneResource.addType(NCO::ModemNumber());
                else if (subType == QContactPhoneNumber::SubTypePager)
                    phoneResource.addType(NCO::PagerNumber());
                else if (subType == QContactPhoneNumber::SubTypeVideo)
                    phoneResource.addType(NCO::VideoTelephoneNumber());
                else if (subType == QContactPhoneNumber::SubTypeVoice)
                    phoneResource.addType(NCO::VoicePhoneNumber());
            }

        } else if (type == QContactOnlineAccount::DefinitionName) {

        } else if (type == QContactTag::DefinitionName) {
            contactRes.addTag(Nepomuk::Tag(detail.value(QContactTag::FieldTag)));

        } else if (type == QContactUrl::DefinitionName) {
            if (detail.value(QContactUrl::FieldSubType) == QContactUrl::SubTypeBlog) {
                SET_PROPERTY(contactRes, NCO::blogUrl, QContactUrl::FieldUrl);
            } else if (detail.value(QContactUrl::FieldSubType) == QContactUrl::SubTypeHomePage) {
                SET_PROPERTY(contactRes, NCO::websiteUrl, QContactUrl::FieldUrl);
            }
            // Not handling QContactUrl::SubTypeFavourite

        }

        // Not handling QContactAnniversary since it is not covered by NCO
        // Not handling QContactAvatar, QContactFamily, QContactRingtone, QContactSyncTarget,
        //     QContactThumbnail not really important here
        // Not handling QContactGlobalPresence since it is volatile data
        // TODO: QContactFavorite - needs support for fav resources in KAMD
        // TODO: QContactOnlineAccount
        // TODO: QContactType handling - we can support groups as well as normal contacts
        // TODO: Should we handle QContactGeoLocation, QContactOrganization

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
