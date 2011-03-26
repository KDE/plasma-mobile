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
    id: phonePad
    property bool displaySpecialKeys: true
    property string typedNumber: ""
    signal okClicked()
    
    Column {
        Row {
            PhoneButton {
                text: "1"
            }

            PhoneButton {
                text: "2"
            }

            PhoneButton {
                text: "3"
            }
        }

        Row {
            PhoneButton {
                text: "4"
            }

            PhoneButton {
                text: "5"
            }

            PhoneButton {
                text: "6"
            }
        }

        Row {
            PhoneButton {
                text: "7"
            }
            
            PhoneButton {
                text: "8"
            }

            PhoneButton {
                text: "9"
            }
        }

        Row {
            
            PhoneButton {
                text: "K"
                defaultAction: false
                visible: !displaySpecialKeys
                onClicked: okClicked()
            }
            
            PhoneButton {
                text: "#"
                visible: displaySpecialKeys
            }

            PhoneButton {
                text: "0"
            }
            
            PhoneButton {
                text: "*"
                visible: displaySpecialKeys
            }
            
            PhoneButton {
                text: "<"
                defaultAction: false
                visible: !displaySpecialKeys
                onClicked: {
                    typedNumber = typedNumber.slice(0, -1)
                }
            }
        }
    }
}
