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

    state: voiceCallmanager.activeVoiceCall ? voiceCallmanager.activeVoiceCall.statusText : "disconnected"
    property color textColor: "white"
    property bool calling: false // needs to be connected to a system service
    property bool enableButtons: calling
    property alias numberEntryText: status.text

    property string providerId: voiceCallmanager.providers.id(0)

    function addNumber(number) {
        status.text = status.text + number
    }

    function call() {
        if (!calling) {
            console.log("Calling: " + status.text);
            dialer.calling = true;
            voiceCallmanager.dial(providerId, status.text);

        } else {
            console.log("Hanging up: " + status.text);
            status.text = '';
            dialer.calling = false;
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

    function secondsToTimeString(seconds) {
        seconds = Math.floor(seconds/1000)
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds - (h * 3600)) / 60);
        var s = seconds - h * 3600 - m * 60;
        if(h < 10) h = '0' + h;
        if(m < 10) m = '0' + m;
        if(s < 10) s = '0' + s;
        return '' + h + ':' + m + ':' + s;
    }

    Behavior on opacity {
        NumberAnimation { properties: "opacity"; duration: 100 }
    }

    MouseArea {
        anchors.fill: parent
    }

    ColumnLayout {
        id: dialPadArea
        visible: dialer.state == "disconnected"

        anchors {
            fill: parent
            margins: 20
        }
        PlasmaComponents.Label {
            id: status
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignRight
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: one.font.pixelSize
        }

        Grid {
            id: pad
            columns: 3
            spacing: 0
            property int buttonHeight: height / 5

            Layout.fillWidth: true
            Layout.fillHeight: true

            height: parent.height - status.height
            width: parent.width

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

            DialerIconButton {
                source: "im-user"
                callback: fromContacts
            }
            DialerIconButton {
                id: callButton
                source: dialer.calling ? "call-stop" : "call-start"
                callback: call
            }
            DialerIconButton { 
                source: "edit-clear"
                callback: function() {
                    if (status.text.length > 0) {
                        status.text = status.text.substr(0, status.text.length - 1);
                    } else {
                        dialer.calling = true;
                        dialer.calling = false;
                    }
                }
            }
        }
    }

    ColumnLayout {
        id: activeCallUi
        spacing: 10
        visible: dialer.state != "disconnected"

        anchors {
            fill: parent
            margins: 20
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: parent.height/2
            Rectangle {
                height: Math.min(parent.width, parent.height)
                width: height
                radius: 5
                anchors.centerIn: parent
                PlasmaCore.IconItem {
                    anchors {
                        fill: parent
                        centerIn: parent
                        margins: 20
                    }
                    source: "im-user"
                }
            }
        }
        Text {
            Layout.fillWidth: true
            Layout.minimumHeight: implicitHeight
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: one.font.pixelSize
            color: textColor
            text: voiceCallmanager.activeVoiceCall ? voiceCallmanager.activeVoiceCall.lineId : ""
        }
        Text {
            Layout.fillWidth: true
            Layout.minimumHeight: implicitHeight
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: theme.smallestFont.pixelSize
            color: textColor
            text: voiceCallmanager.activeVoiceCall ? secondsToTimeString(voiceCallmanager.activeVoiceCall.duration) : ''
        }
        RowLayout {
            Layout.minimumHeight: parent.height / 3

            Layout.fillWidth: true
            Layout.fillHeight: true

            DialerIconButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                source: dialer.state == "incoming" ? "call-start" : (voiceCallmanager.isMicrophoneMuted ? "audio-volume-muted" : "audio-volume-high")
                Rectangle {
                    z: -1
                    color: dialer.state == "incoming" ? "green" : "white"
                    opacity: 0.5
                    radius: 5
                    anchors {
                        fill: parent
                    }
                }

                callback: function () {
                    if (dialer.state == "incoming") {
                        if (voiceCallmanager.activeVoiceCall) {
                            voiceCallmanager.activeVoiceCall.answer();
                        }
                    } else {
                        voiceCallmanager.isMicrophoneMuted = !voiceCallmanager.isMicrophoneMuted;
                    }
                }
            }

            DialerIconButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                source: "call-stop"
                Rectangle {
                    z: -1
                    color: "red"
                    opacity: 0.5
                    radius: 5
                    anchors {
                        fill: parent
                    }
                }

                callback: function () {
                    if (voiceCallmanager.activeVoiceCall) {
                        voiceCallmanager.activeVoiceCall.hangup();
                    }
                }
            }
        }
    }
}
