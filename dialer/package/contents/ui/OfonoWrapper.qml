/**
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.3
import org.nemomobile.voicecall 1.0


Item {
    id: ofonoWrapper

//BEGIN PROPERTIES
    property string status: "idle"

    //support a single provider for now
    property string providerId: voiceCallmanager.providers.id(0)

    //was the last call an incoming one?
    property bool isIncoming: voiceCallmanager.activeVoiceCall ? voiceCallmanager.activeVoiceCall.isIncoming : false

    //is there a call in progress?
    property bool hasActiveCall: voiceCallmanager.activeVoiceCall ? true : false

    //if there is an active call, to what number?
    property string lineId: voiceCallmanager.activeVoiceCall ? voiceCallmanager.activeVoiceCall.lineId : ""

    //if there is a call, for how long?
    property int duration: voiceCallmanager.activeVoiceCall ? voiceCallmanager.activeVoiceCall.duration : 0

    //microphone muted?
    property alias isMicrophoneMuted: voiceCallmanager.isMicrophoneMuted
//END PROPERTIES

//BEGIN SIGNAL HANDLERS
    Connections {
        target: dialerUtils
        onMissedCallsActionTriggered: {
            root.visible = true;
        }
    }

    onVisibleChanged: {
        //reset missed calls if the status is not STATUS_INCOMING when got visible
        if (visible && status != 5) {
            dialerUtils.resetMissedCalls();
        }
    }
//END SIGNAL HANDLERS

//BEGIN FUNCTIONS
    function call(number) {
        if (!voiceCallmanager.activeVoiceCall) {
            console.log("Calling: " + providerId + " " + number);
            voiceCallmanager.dial(providerId, number);

        } else {
            console.log("Hanging up: " + voiceCallmanager.activeVoiceCall.lineId);
            status.text = '';
            var call = voiceCallmanager.activeVoiceCall;
            if (call) {
                call.hangup();
            }
        }
    }

    function answer() {
        if (voiceCallmanager.activeVoiceCall) {
            voiceCallmanager.activeVoiceCall.answer();
        }
    }

    function hangup() {
        if (voiceCallmanager.activeVoiceCall) {
            voiceCallmanager.activeVoiceCall.hangup();
        }
    }

    function sendToneToCall(key) {
        if (voiceCallmanager.activeVoiceCall) {
            voiceCallmanager.activeVoiceCall.sendDtmf(key);
        }
    }

    function startTone(string) {
        voiceCallmanager.startDtmfTone(string);
    }

    function stopTone() {
        voiceCallmanager.stopDtmfTone();
    }
//END FUNCTIONS

//BEGIN DATABASE
    Component.onCompleted: {
        //HACK: make sure activeVoiceCall is loaded if already existing
        voiceCallmanager.voiceCalls.onVoiceCallsChanged();
        voiceCallmanager.onActiveVoiceCallChanged();
    }
//END DATABASE

//BEGIN MODELS

    VoiceCallManager {
        id: voiceCallmanager

        property int status: activeVoiceCall ? activeVoiceCall.status : 0
        //keep track of the status we were in
        property int previousStatus
        onStatusChanged: {
            //STATUS_INCOMING
            if (status == 5) {
                wasVisible = root.visible;
                root.visible = true;
                dialerUtils.notifyRinging();
            //Was STATUS_INCOMING now is STATUS_DISCONNECTED: Missed call!
            } else if (status == 7 && previousStatus == 5) {
                var prettyDate = Qt.formatTime(voiceCallmanager.activeVoiceCall.startedAt, Qt.locale().timeFormat(Locale.ShortFormat));
                dialerUtils.notifyMissedCall(voiceCallmanager.activeVoiceCall.lineId, i18n("%1 called at %2", voiceCallmanager.activeVoiceCall.lineId, prettyDate));
                root.visible = wasVisible;
                insertCallInHistory(voiceCallmanager.activeVoiceCall.lineId, 0, 0);
            //STATUS_DISCONNECTED
            } else if (status == 7) {
                insertCallInHistory(voiceCallmanager.activeVoiceCall.lineId, voiceCallmanager.activeVoiceCall.duration, voiceCallmanager.activeVoiceCall.isIncoming ? 1 : 2);
            }

            //status not STATUS_INCOMING
            if (status != 5) {
                dialerUtils.stopRinging();
            }

            previousStatus = status;
            switch (status) {
            case 1:
                ofonoWrapper.status = "active";
                break;
            case 2:
                ofonoWrapper.status = "held";
                break;
            case 3:
                ofonoWrapper.status = "dialing";
                break;
            case 4:
                ofonoWrapper.status = "alerting";
                break;
            case 5:
                ofonoWrapper.status = "incoming";
                break;
            case 6:
                ofonoWrapper.status = "waiting";
                break;
            case 7:
                ofonoWrapper.status = "disconnected";
                break;
            case 0:
            default:
                ofonoWrapper.status = "idle";
                break;
            }
        }

        onActiveVoiceCallChanged: {
            if (activeVoiceCall) {
                //main.activeVoiceCallPerson = people.personByPhoneNumber(activeVoiceCall.lineId);
               // dialerOverlay.item.numberEntryText = activeVoiceCall.lineId;

            } else {
               // dialerOverlay.item.numberEntryText = '';

                //main.activeVoiceCallPerson = null;
            }
        }

        onError: {
            console.log('*** QML *** VCM ERROR: ' + message);
        }
    }

//END MODELS

}
