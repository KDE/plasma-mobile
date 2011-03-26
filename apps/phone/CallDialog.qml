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

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaWidgetsCore
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import "widgets"

MainWindow {
        signal hangup()
        signal answer()
        
        property int callRunningSeconds: 0
        
        Timer {
            id: callTimer;
            interval: 1000
            running: callState == "active"
            repeat: true
            onTriggered: callRunningSeconds += 1
        }
        
        states: [
            State {
                name: "incomingCall"
                when: callState == "incoming"
                PropertyChanges {
                    target: hangupButton
                    text: i18n("Decline")
                }
            },
            State {
                name: "activeCall"
                when: callState == "active"
            }
        ]
        
        Row {
            x: 50
            y: 160
            spacing: 20
            PlasmaWidgets.IconWidget {
                height: 128
                width: 128
                icon: new QIcon("im-user")
            }
            
            Column {
                Label {
                    text: caller
                }
                
                Label {
                    visible: (caller != "") && (callState == "incoming")
                    text: callerDettails;
                }
                
                Label {
                    text: Math.floor((callRunningSeconds / 60)) + ":" + (callRunningSeconds % 60)
                    visible: callState == "active"
                }
            }
        }
        
        Row {
            id: blahRow
            x: 10
            y: 400
            spacing: 10

            Button {
                id: hangupButton
                text: i18n("End Call")
                onClicked: {
                    hangup();
                }
            }
            
            Button {
                id: answerButton
                text: i18n("Answer")
                visible: callState == "incoming"
                onClicked: {
                    answer();
                }
            }
        }
}
