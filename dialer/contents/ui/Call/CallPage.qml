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
    id: callPage

    state: voiceCallmanager.activeVoiceCall ? voiceCallmanager.activeVoiceCall.statusText : "disconnected"
    property int status: voiceCallmanager.activeVoiceCall ? voiceCallmanager.activeVoiceCall.status : 0

    property string providerId: voiceCallmanager.providers.id(0)

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


    ColumnLayout {
        id: activeCallUi
        spacing: 10

        anchors {
            fill: parent
            margins: 20
        }

        Flickable {
            id: topFlickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: parent.height/2

            contentWidth: topContents.width;
            contentHeight: topContents.height
            Row {
                id: topContents
                Avatar {
                    width: topFlickable.width
                    height: topFlickable.height
                }
                Dialpad {
                    width: topFlickable.width
                    height: topFlickable.height
                }
            }

            onMovingChanged: {
                var checked = contentX > topFlickable.width/2;

                if (checked) {
                    topSlideAnim.to = topFlickable.width;
                } else {
                    topSlideAnim.to = 0;
                }
                dialerButton.checked = checked;
                topSlideAnim.running = true;
            }
            PropertyAnimation {
                id: topSlideAnim
                target: topFlickable
                properties: "contentX"
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        PlasmaComponents.Label {
            Layout.fillWidth: true
            Layout.minimumHeight: implicitHeight
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pointSize: theme.defaultFont.pointSize * 2
            text: voiceCallmanager.activeVoiceCall ? voiceCallmanager.activeVoiceCall.lineId : ""
        }
        PlasmaComponents.Label {
            Layout.fillWidth: true
            Layout.minimumHeight: implicitHeight
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: {
                if (!voiceCallmanager.activeVoiceCall) {
                    return '';
                //STATUS_DIALING
                } else if (voiceCallmanager.activeVoiceCall.status == 3) {
                    return i18n("Calling...");
                } else if (voiceCallmanager.activeVoiceCall.duration > 0) {
                    return secondsToTimeString(voiceCallmanager.activeVoiceCall.duration);
                } else {
                    return '';
                }
            }
        }
        PlasmaComponents.ButtonRow {
            opacity: status == 1 ? 1 : 0
            exclusive: false
            spacing: 0
            Layout.alignment: Qt.AlignHCenter
            PlasmaComponents.ToolButton {
                id: muteButton
                flat: false
                iconSource: voiceCallmanager.isMicrophoneMuted ? "audio-volume-muted" : "audio-volume-high"
                onClicked: {
                    voiceCallmanager.isMicrophoneMuted = !voiceCallmanager.isMicrophoneMuted;
                }
            }
            PlasmaComponents.ToolButton {
                id: dialerButton
                flat: false
                iconSource: "input-keyboard"
                checkable: true
                onCheckedChanged: {
                    if (checked) {
                        topSlideAnim.to = topFlickable.width;
                    } else {
                        topSlideAnim.to = 0;
                    }
                    topSlideAnim.running = true;
                }
            }
        }


        Item {
            Layout.minimumHeight: units.gridUnit * 5
            Layout.fillWidth: true

            AnswerSwipe {
                anchors.fill: parent
                //STATUS_INCOMING
                visible: status == 5
                onAccepted: {
                    if (voiceCallmanager.activeVoiceCall) {
                        voiceCallmanager.activeVoiceCall.answer();
                    }
                }
                onRejected: {
                    if (voiceCallmanager.activeVoiceCall) {
                        voiceCallmanager.activeVoiceCall.hangup();
                    }
                }
            }

            PlasmaComponents.Button {
                anchors.fill: parent
                //STATUS_INCOMING
                visible: status != 5
                iconSource: "call-stop"
                Layout.fillWidth: true
                text: i18n("End Call")
                onClicked: {
                    if (voiceCallmanager.activeVoiceCall) {
                        voiceCallmanager.activeVoiceCall.hangup();
                    }
                }
            }
        }
    }
}
