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

MobileNetworkSource::MobileNetworkSource(QObject* parent)
    : Plasma::DataContainer(parent)
{
}

MobileNetworkSource::~MobileNetworkSource()
{
}

void MobileNetworkSource::update(bool forcedUpdate)
{
    //Some fake data
    setData("signalStrength", 100);
    setData("cdmaDataStrength", 100); //CDMA Only
    setData("cdmaSystemIdentifier", "678");  //CDMA Only
    setData("cdmaNetworkIdentifier", "678");  //CDMA Only
    setData("cdmaRoamingPreference", "any");  //CDMA Only
    setData("technology", "umts");
    setData("registrationMode", "auto");
    setData("registrationStatus", "registered");
    setData("cellId", "45678");
    setData("locationAreaCode", "12345");
    setData("mobileCountryCode", "789");
    setData("mobileNetworkCode", "678");
    setData("baseStation", "myCity");
    setData("operatorName", "myOperator");
}

#include "mobilenetworksource.moc"
