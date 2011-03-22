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

#include "phonebook.h"

#include <QDeclarativeContext>
#include <QDeclarativeComponent>
#include <QDeclarativeItem>
#include <kdeclarative.h>

#include <kdirmodel.h>
#include <kdirlister.h>
#include <kdebug.h>
#include <kabc/addressee.h>
#include <kabc/contactgroup.h>
#include <kabc/phonenumber.h>

#include <QApplication>
#include <KStandardAction>
#include <QAction>
#include <KAction>

#ifndef DISABLE_OFONO_QT
#include <ofono-qt/ofonovoicecallmanager.h>
#endif

PhoneBook::PhoneBook()
{

}

void PhoneBook::callContact(QVariant contact)
{
    KABC::PhoneNumber::List numbersList = contact.value<KABC::Addressee>().phoneNumbers(KABC::PhoneNumber::Home);
    if (numbersList.count() > 0){
        kDebug() << "Calling " << numbersList.at(0).number();

#ifndef DISABLE_OFONO_QT
        OfonoVoiceCallManager *callManager = new OfonoVoiceCallManager(OfonoModem::AutomaticSelect, QString(), this);
        callManager->dial(numbersList.at(0).number(), false);
        delete callManager;
#endif
        close();
    }
}

#include "phonebook.moc"
