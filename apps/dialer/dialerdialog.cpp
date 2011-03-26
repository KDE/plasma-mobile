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

#include "dialerdialog.h"

#include <QDeclarativeContext>
#include <QDeclarativeComponent>
#include <QDeclarativeItem>
#include <kdeclarative.h>

#include <ofono-qt/ofonovoicecallmanager.h>
#include <kdebug.h>

DialerDialog::DialerDialog()
{
    KDeclarative kdeclarative;
    kdeclarative.setDeclarativeEngine(engine());
    kdeclarative.initialize();
    kdeclarative.setupBindings();

    setSource(QUrl::fromLocalFile("Dialer.qml"));
    connect(rootObject(), SIGNAL(okClicked()), this, SLOT(call()));
}

DialerDialog::~DialerDialog()
{
}

void DialerDialog::call()
{
    OfonoVoiceCallManager *callManager = new OfonoVoiceCallManager(OfonoModem::AutomaticSelect, QString(), this);
    callManager->dial(rootObject()->property("typedNumber").toString(), false);
    delete callManager;
    close();
}

#include "dialerdialog.moc"
