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
import "../Dialpad"

Item {
    id: dialer

    property alias numberEntryText: status.text

    property string providerId: voiceCallmanager.providers.id(0)

    function addNumber(number) {
        status.text = status.text + number
    }

    //TODO: move in root item
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

        Dialpad {
            callback: function (string) {
                addNumber(string);
            }
            pressedCallback: function (string) {
                voiceCallmanager.startDtmfTone(string);
            }
            releasedCallback: function (string) {
                voiceCallmanager.stopDtmfTone();
            }
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
            Item {
                Layout.minimumWidth: dialPadArea.width/3
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            DialerIconButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: dialPadArea.width/3
                enabled: status.text.length > 0
                opacity: enabled ? 1 : 0.5
                source: "edit-clear"
                callback: function(text) {
                    if (status.text.length > 0) {
                        status.text = status.text.substr(0, status.text.length - 1);
                    }
                }
            }
        }
    }
}
