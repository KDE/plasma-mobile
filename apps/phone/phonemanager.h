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

#ifndef _PHONE_MANAGER_H
#define _PHONE_MANAGER_H

#include <QObject>

class OfonoModem;
class OfonoSimManager;

class PhoneManager : public QObject
{
    Q_OBJECT
    
    public:
        PhoneManager();
        ~PhoneManager();

    private slots:
        void setOnline();
        void enterPinComplete(bool success);
        void modemPoweredChanged(bool powered);
        void modemOnlineChanged(bool online);

    private:
        OfonoModem *m_modem;
        OfonoSimManager *m_simManager;
};

#endif
