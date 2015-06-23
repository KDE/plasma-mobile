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
import org.kde.plasma.components 2.0 as PlasmaComponents
import MeeGo.QOfono 0.2
import "../components"

PlasmaCore.ColorScope {
    id: root

    anchors.fill: parent
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    visible: simManager.pinRequired != OfonoSimManager.NoPin
    property OfonoSimManager simManager: ofonoSimManager

    function addNumber(number) {
        pinLabel.text = pinLabel.text + number
    }

    Rectangle {
        id: pinScreen
        anchors.fill: parent
        
        color: PlasmaCore.ColorScope.backgroundColor

        OfonoManager {
            id: ofonoManager
            onAvailableChanged: {
            console.log("Ofono is " + available)
            }
            onModemAdded: {
                console.log("modem added " + modem)
            }
            onModemRemoved: console.log("modem removed")
        }

        OfonoConnMan {
            id: ofono1
            Component.onCompleted: {
                console.log(ofonoManager.modems)
            }
            modemPath: ofonoManager.modems.length > 0 ? ofonoManager.modems[0] : ""
        }

        OfonoModem {
            id: modem1
            modemPath: ofonoManager.modems.length > 0 ? ofonoManager.modems[0] : ""

        }

        OfonoContextConnection {
            id: context1
            contextPath : ofono1.contexts.length > 0 ? ofono1.contexts[0] : ""
            Component.onCompleted: {
                print("Context Active: " + context1.active)
            }
            onActiveChanged: {
                print("Context Active: " + context1.active)
            }
        }

        OfonoSimManager {
            id: ofonoSimManager
            modemPath: ofonoManager.modems.length > 0 ? ofonoManager.modems[0] : ""
        }

        OfonoNetworkOperator {
            id: netop
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
            PlasmaComponents.Label {
                Layout.fillWidth: true
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
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
            PlasmaComponents.Label {
                Layout.fillWidth: true
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                text: simManager.pinRetries && simManager.pinRetries[simManager.pinRequired] ? i18n("%1 attempts left", simManager.pinRetries[simManager.pinRequired]) : "";
            }

            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents.Label {
                    id: pinLabel
                    Layout.fillWidth: true
                    horizontalAlignment: Qt.AlignRight
                    verticalAlignment: Qt.AlignVCenter
                    font.pixelSize: one.font.pixelSize
                }
                PlasmaComponents.Button {
                    visible: pinLabel.text != ""
                    iconSource: "edit-clear"
                    width: height
                    onClicked: {
                        pinLabel.text = pinLabel.text.substring(0, pinLabel.text.length - 1);
                    }
                }
            }

            Grid {
                id: pad
                columns: 3
                spacing: 0
                property int buttonHeight: height / 5

                Layout.fillWidth: true
                Layout.fillHeight: true

                DialerButton { id: one; text: "1"; color: PlasmaCore.ColorScope.textColor } 
                DialerButton { text: "2"; color: PlasmaCore.ColorScope.textColor }
                DialerButton { text: "3"; color: PlasmaCore.ColorScope.textColor }

                DialerButton { text: "4"; color: PlasmaCore.ColorScope.textColor } 
                DialerButton { text: "5"; color: PlasmaCore.ColorScope.textColor }
                DialerButton { text: "6"; color: PlasmaCore.ColorScope.textColor }

                DialerButton { text: "7"; color: PlasmaCore.ColorScope.textColor } 
                DialerButton { text: "8"; color: PlasmaCore.ColorScope.textColor }
                DialerButton { text: "9"; color: PlasmaCore.ColorScope.textColor }

                DialerButton { text: "*"; color: PlasmaCore.ColorScope.textColor } 
                DialerButton { text: "0"; sub: "+"; color: PlasmaCore.ColorScope.textColor }
                DialerButton {
                    text: "#"
                    color: PlasmaCore.ColorScope.textColor
                    callback: function () {
                        simManager.enterPin(simManager.pinRequired, pinLabel.text)
                        pinLabel.text = "";
                    }
                }
            }
            PlasmaComponents.Button {
                anchors {
                    top: pad.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                text: i18n("Ok")
                onClicked: {
                    simManager.enterPin(simManager.pinRequired, pinLabel.text)
                    pinLabel.text = "";
                }
            }
        }
    }
}
