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

#include <QInputDialog>
#include <QTimer>

#include <KDebug>

#include <ofono-qt/ofonosimmanager.h>

PhoneManager::PhoneManager()
{
    m_modem = new OfonoModem(OfonoModem::AutomaticSelect, QString(), this);
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
        connect(m_simManager, SIGNAL(enterPinComplete(bool)), this, SLOT(enterPinComplete(bool)));
        QString pin = QInputDialog::getText(0, "PIN", "Insert PIN");
        m_simManager->enterPin("pin", pin);
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
        connect(m_modem, SIGNAL(onlineChanged(bool)), this, SLOT(modemOnlineChanged(bool)));
        m_modem->setOnline(true);
        QTimer::singleShot(1000, this, SLOT(setOnline()));
    }
}

void PhoneManager::modemOnlineChanged(bool online)
{
    kDebug() << "Online: " << online;
}

#include "phonemanager.moc"
