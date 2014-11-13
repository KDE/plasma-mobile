/*
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2014 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import MeeGo.QOfono 0.2
import "../components"

Rectangle {
    id: pinScreen
    color: "black"
    opacity: 0.8
    visible: simManager.pinRequired != OfonoSimManager.NoPin

    property color textColor: "white"
    property OfonoSimManager simManager: homescreen.simManager

    function addNumber(number) {
        pinLabel.text = pinLabel.text + number
    }

    MouseArea {
        anchors.fill: parent
    }

    Connections {
        target: simManager
        onEnterPinComplete: {
            print("Enter Pin complete: " + error + " " + errorString)
        }
    }

    ColumnLayout {
        id: dialPadArea

        anchors {
            fill: parent
            margins: 20
        }
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: theme.defaultFont.pixelSize
            color: textColor
            text: {
                switch (simManager.pinRequired) {
                case OfonoSimManager.NoPin: return i18n("No pin (error)");
                case OfonoSimManager.SimPin: return i18n("Enter Sim PIN");
                case OfonoSimManager.SimPin2: return i18n("Enter Sim PIN 2");
                case OfonoSimManager.SimPuk: return i18n("Enter Sim PUK");
                case OfonoSimManager.SimPuk2: return i18n("Enter Sim PUK 2");
                default: return i18n("Unknown PIN type: %1", simManager.pinRequired);
                }
            }
        }
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: theme.defaultFont.pixelSize
            color: textColor
            text: i18n("%1 attempts left", (simManager.pinRetries ? simManager.pinRetries[simManager.pinRequired] : 0));
        }

        Text {
            id: pinLabel
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignRight
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: one.font.pixelSize
            color: textColor
        }

        Grid {
            id: pad
            columns: 3
            spacing: 0
            property int buttonHeight: height / 5

            Layout.fillWidth: true
            Layout.fillHeight: true

            DialerButton { id: one; text: "1"; color: "white"; } 
            DialerButton { text: "2"; color: "white"; }
            DialerButton { text: "3"; color: "white"; }

            DialerButton { text: "4"; color: "white"; } 
            DialerButton { text: "5"; color: "white"; }
            DialerButton { text: "6"; color: "white"; }

            DialerButton { text: "7"; color: "white"; } 
            DialerButton { text: "8"; color: "white"; }
            DialerButton { text: "9"; color: "white"; }

            DialerButton { text: "*"; color: "white"; } 
            DialerButton { text: "0"; sub: "+"; color: "white"; }
            DialerButton {
                text: "#"
                 color: "white"
                callback: function () {
                    simManager.enterPin(simManager.pinRequired, pinLabel.text)
                    pinLabel.text = "";
                }
            }
        }
    }
}
