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

#include <Nepomuk/Resource>

#include "nco.h"
#include "nao.h"

#include <KDebug>

#include "dummycontacts.h"

using namespace QtMobility;

namespace Contour {

class QtMobilityFeederPrivate {
public:

    QContactId uriToId(const QString & uri)
    {
        QContactId result;
        int position = uri.lastIndexOf('/');

        if (position != -1) {
            kDebug() << uri.left(position);
            kDebug() << uri.mid(position + 1);
        }

        return result;
    }

    QString idToUri(const QContactId & id)
    {
        kDebug() << id.managerUri() + '/' + QString::number(id.localId());
        return id.managerUri() + '/' + QString::number(id.localId());
    }

};

QtMobilityFeeder::QtMobilityFeeder(QObject * parent)
    : QObject(parent), d(new QtMobilityFeederPrivate())
{
    kDebug() << "availableManagers" << QContactManager::availableManagers();
    kDebug() << QContactManager::buildUri(
            "memory", QMap < QString, QString > ());

    // TODO: Remove this and change to real address book model
    QContactManager manager("memory");
    ::addDummyContacts(manager);

    foreach (const QContact & contact, manager.contacts()) {
        kDebug() << contact.id();

        QString uri = d->idToUri(contact.id());
        d->uriToId(uri);
    }

    kDebug() << "List ended";
}

QtMobilityFeeder::~QtMobilityFeeder()
{
    delete d;
}

} // namespace Contour
