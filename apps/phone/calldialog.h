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

#ifndef _CALL_DIALOG_H
#define _CALL_DIALOG_H

#include <QDeclarativeView>

class OfonoVoiceCall;

class CallDialog : public QDeclarativeView
{
    Q_OBJECT
    
    public:
        CallDialog(OfonoVoiceCall *voiceCall);
        ~CallDialog();
        
    public slots:
        void hangup();
        void stateChanged(const QString &state);
        
    private:
        OfonoVoiceCall *m_voiceCall;
};

#endif
