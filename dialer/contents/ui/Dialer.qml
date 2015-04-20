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
import org.nemomobile.voicecall 1.0

Item {
    id: dialer

    property alias numberEntryText: status.text

    property string providerId: voiceCallmanager.providers.id(0)

    function addNumber(number) {
        status.text = status.text + number
    }

    function call() {
        if (!voiceCallmanager.activeVoiceCall) {
            console.log("Calling: " + status.text);
            voiceCallmanager.dial(providerId, status.text);

        } else {
            console.log("Hanging up: " + status.text);
            status.text = '';
            var call = voiceCallmanager.activeVoiceCall;
            if (call) {
                call.hangup();
            }
        }
    }

    function fromContacts() {
        console.log("Should get from contacts!");
        status.text = "+41 76 555 5555"
    }

    ColumnLayout {
        id: dialPadArea

        anchors {
            fill: parent
            margins: units.largeSpacing
        }
        PlasmaComponents.Label {
            id: status
            Layout.fillWidth: true
            Layout.minimumHeight: parent.height / 6
            Layout.maximumHeight: Layout.minimumHeight
            horizontalAlignment: Qt.AlignRight
            verticalAlignment: Qt.AlignVCenter
            font.pointSize: 1024
            fontSizeMode: Text.Fit
        }

        GridLayout {
            id: pad
            columns: 3

            property int buttonHeight: parent.height / 6

            Layout.fillWidth: true
            Layout.fillHeight: true

            DialerButton { id: one; text: "1" } 
            DialerButton { text: "2" }
            DialerButton { text: "3" }

            DialerButton { text: "4" } 
            DialerButton { text: "5" }
            DialerButton { text: "6" }

            DialerButton { text: "7" } 
            DialerButton { text: "8" }
            DialerButton { text: "9" }

            DialerButton { text: "*"; } 
            DialerButton { text: "0"; sub: "+"; }
            DialerButton { text: "#" }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.minimumHeight: parent.height / 6
            Layout.maximumHeight: Layout.minimumHeight
            DialerIconButton {
                id: callButton
                Layout.minimumWidth: dialPadArea.width/3
                Layout.fillWidth: true
                Layout.fillHeight: true
                enabled: status.text.length > 0
                opacity: enabled ? 1 : 0.5
                source: "call-start"
                callback: call
            }
            DialerButton {
                Layout.minimumWidth: dialPadArea.width/3
                Layout.fillWidth: true
                Layout.fillHeight: true
                enabled: status.text.length > 0
                opacity: enabled ? 1 : 0.5
                text: i18n("Call")
                callback: call
            }
            DialerIconButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: dialPadArea.width/3
                source: "edit-clear"
                callback: function() {
                    if (status.text.length > 0) {
                        status.text = status.text.substr(0, status.text.length - 1);
                    }
                }
            }
        }
    }
}
