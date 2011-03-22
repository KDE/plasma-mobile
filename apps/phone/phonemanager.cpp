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

#include "phonemanager.h"

#include <QDeclarativeContext>
#include <QDeclarativeItem>
#include <QDeclarativeView>
#include <QInputDialog>
#include <QTimer>

#include <kdeclarative.h>
#include <KDebug>

#include <ofono-qt/ofonosimmanager.h>
#include <ofono-qt/ofonovoicecallmanager.h>
#include <ofono-qt/ofonovoicecall.h>

#include "pinrequester.h"
#include "calldialog.h"

PhoneManager::PhoneManager()
{
    m_requester = 0;
    
    m_modem = new OfonoModem(OfonoModem::AutomaticSelect, QString(), this);
    connect(m_modem, SIGNAL(onlineChanged(bool)), this, SLOT(modemOnlineChanged(bool)));

    if (!m_modem->powered()){
        kDebug() << "Modem isn't powered";
        connect(m_modem, SIGNAL(poweredChanged(bool)), this, SLOT(modemPoweredChanged(bool)));
        m_modem->setPowered(true);
    }
    
    m_simManager = new OfonoSimManager(OfonoModem::ManualSelect, m_modem->path(), this);
    if (!m_simManager->present()){
        kDebug() << "No sim detected";
    }

    if (m_simManager->pinRequired() == "pin"){
        kDebug() << "PIN is required\n";
        showPinRequester();
    }

    kDebug() << "Done.";
}

PhoneManager::~PhoneManager()
{
    
}

void PhoneManager::enterPinComplete(bool success)
{
    kDebug() << "pin: " << success << "\n";
    kDebug() << m_simManager->errorMessage() << "\n";
    if (success){
        delete m_requester;
    }
}

void PhoneManager::modemPoweredChanged(bool powered)
{
    kDebug() << "Powered: " << powered;
    setOnline();
}

void PhoneManager::setOnline()
{
    if (!m_modem->online()){
        kDebug() << "RF is not enabled";
        m_modem->setOnline(true);
        QTimer::singleShot(1000, this, SLOT(setOnline()));
    }
}

void PhoneManager::modemOnlineChanged(bool online)
{
    kDebug() << "Online: " << online;
    
    if (online){
        OfonoVoiceCallManager *callManager = new OfonoVoiceCallManager(OfonoModem::AutomaticSelect, QString(), this);
        connect(callManager, SIGNAL(callAdded(const QString &)), this, SLOT(callAdded(const QString &)));
    }
}

void PhoneManager::pinEntered()
{
    kDebug() << "Pin entered: " << m_requester->pin();
    connect(m_simManager, SIGNAL(enterPinComplete(bool)), this, SLOT(enterPinComplete(bool)));
    m_simManager->enterPin("pin", m_requester->pin());
}

void PhoneManager::showPinRequester()
{
    m_requester = new PinRequester;
    connect(m_requester, SIGNAL(pinEntered()), this, SLOT(pinEntered()));
    m_requester->setWindowModality(Qt::WindowModal);
    m_requester->show();
}

void PhoneManager::callAdded(const QString &call)
{
    kDebug() << "New call: " << call;
    OfonoVoiceCall *voiceCall = new OfonoVoiceCall(call, this);
    CallDialog *callDialog = new CallDialog(voiceCall);
    callDialog->show();
}

#include "phonemanager.moc"
