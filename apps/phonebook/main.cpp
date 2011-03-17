/***************************************************************************
 *   Copyright 2011 by Davide Bettio <davide.bettio@kdemail.net>           *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include <QApplication>

#include <QDeclarativeItem>
#include <QDeclarativeContext>
#include <kdeclarative.h>

#include <kdescendantsproxymodel.h>
#include <akonadi/session.h>
#include <akonadi/itemfetchscope.h>
#include <akonadi/changerecorder.h>
#include <akonadi/entitydisplayattribute.h>
#include <kabc/addressee.h>
#include <kabc/contactgroup.h>

#include "declarativecontactmodel.h"
#include "phonebook.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    PhoneBook view;

    KDeclarative kdeclarative;
    kdeclarative.setDeclarativeEngine(view.engine());
    kdeclarative.initialize();
    kdeclarative.setupBindings();

    Akonadi::Session *session = new Akonadi::Session("PhoneBookSession");

    Akonadi::ItemFetchScope scope;
    scope.fetchFullPayload(true);
    scope.fetchAttribute<Akonadi::EntityDisplayAttribute>();

    Akonadi::ChangeRecorder *changeRecorder = new Akonadi::ChangeRecorder;
    changeRecorder->setSession(session);
    changeRecorder->fetchCollection(true);
    changeRecorder->setItemFetchScope(scope);
    changeRecorder->setCollectionMonitored(Akonadi::Collection::root());
    changeRecorder->setMimeTypeMonitored(KABC::Addressee::mimeType(), true);
    changeRecorder->setMimeTypeMonitored(KABC::ContactGroup::mimeType(), true);

    DeclarativeContactModel *model = new DeclarativeContactModel(changeRecorder);

    KDescendantsProxyModel *proxyModel = new KDescendantsProxyModel;
    proxyModel->setSourceModel(model);

    view.rootContext()->setContextProperty("myModel", proxyModel);
    view.setSource(QUrl::fromLocalFile("phonebook.qml"));

    view.show();

    return app.exec();
}
