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

#include "mobilenetworksource.h"

#include <ofono-qt/ofononetworkregistration.h>
#include <ofono-qt/ofonomodem.h>
#include <ofono-qt/ofonosimmanager.h>

MobileNetworkSource::MobileNetworkSource(QString modem, QObject* parent)
    : Plasma::DataContainer(parent)
{
    if (modem != "default"){
        m_netRegistration = new OfonoNetworkRegistration(OfonoModem::ManualSelect, modem, this);
        m_modem = new OfonoModem(OfonoModem::ManualSelect, modem, this);
        m_simManager = new OfonoSimManager(OfonoModem::ManualSelect, modem, this);
    }else{
        m_netRegistration = new OfonoNetworkRegistration(OfonoModem::AutomaticSelect, QString(), this);
        m_modem = new OfonoModem(OfonoModem::AutomaticSelect, QString(), this);
        m_simManager = new OfonoSimManager(OfonoModem::AutomaticSelect, QString(), this);        
    }
    connect(m_netRegistration, SIGNAL(poweredChanged(bool)), this, SLOT(updateAll()));
    connect(m_netRegistration, SIGNAL(onlineChanged(bool)), this, SLOT(updateAll()));
    connect(m_netRegistration, SIGNAL(presenceChanged(bool)), this, SLOT(updateAll()));
    connect(m_netRegistration, SIGNAL(strengthChanged(uint)), this, SLOT(updateAll()));
    connect(m_netRegistration, SIGNAL(technologyChanged(const QString &)), this, SLOT(updateAll()));
    connect(m_netRegistration, SIGNAL(modeChanged(const QString &)), this, SLOT(updateAll()));
    connect(m_netRegistration, SIGNAL(statusChanged(const QString &)), this, SLOT(updateAll()));
    connect(m_netRegistration, SIGNAL(cellIdChanged(uint)), this, SLOT(updateAll()));
    connect(m_netRegistration, SIGNAL(locationAreaCodeChanged(uint)), this, SLOT(updateAll()));
    connect(m_netRegistration, SIGNAL(mccChanged(const QString &)), this, SLOT(updateAll()));
    connect(m_netRegistration, SIGNAL(mncChanged(const QString &)), this, SLOT(updateAll()));
    connect(m_netRegistration, SIGNAL(baseStationChanged(const QString &)), this, SLOT(updateAll()));
    connect(m_netRegistration, SIGNAL(nameChanged(const QString &)), this, SLOT(updateAll()));
}

MobileNetworkSource::~MobileNetworkSource()
{
}

void MobileNetworkSource::updateAll()
{
    update(true);
}

void MobileNetworkSource::update(bool forcedUpdate)
{
    Q_UNUSED(forcedUpdate)
    
    //Modem API
    setData("isModemPowered", m_modem->powered());
    setData("isRFEnabled", m_modem->online());
    
    //SIM API
    setData("isSIMPresent", m_simManager->present());
    
    //Network API
    setData("signalStrength", m_netRegistration->strength());
//ofono-qt: missing CDMA binding
#if 0
    //Some fake data
    setData("cdmaDataStrength", 100); //CDMA Only
    setData("cdmaSystemIdentifier", "678");  //CDMA Only
    setData("cdmaNetworkIdentifier", "678");  //CDMA Only
    setData("cdmaRoamingPreference", "any");  //CDMA Only
#endif
    setData("technology", m_netRegistration->technology());
    setData("registrationMode", m_netRegistration->mode());
    setData("registrationStatus", m_netRegistration->status());
    setData("cellId", m_netRegistration->cellId());
    setData("locationAreaCode", m_netRegistration->locationAreaCode());
    setData("mobileCountryCode", m_netRegistration->mcc());
    setData("mobileNetworkCode", m_netRegistration->mnc());
    setData("baseStation", m_netRegistration->baseStation());
    setData("operatorName", m_netRegistration->name());
}

#include "mobilenetworksource.moc"
