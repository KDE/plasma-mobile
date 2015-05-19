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
import Ubuntu.Telephony 0.1

Item {
    id: root

//BEGIN PROPERTIES
    property string status: "idle"

    //support a single provider for now
    property string providerId: callManager.providers.id(0)

    //was the last call an incoming one?
    property bool isIncoming: callManager.foregroundCall ? callManager.foregroundCall.incoming : false

    //is there a call in progress?
    property bool hasActiveCall: callManager.foregroundCall ? true : false

    //if there is an active call, to what number?
    property string lineId: callManager.foregroundCall ? callManager.foregroundCall.phoneNumber : ""

    //if there is a call, for how long?
    property int duration: callManager.foregroundCall ? callManager.foregroundCall.elapsedTime : 0

    //microphone muted?
    property bool isMicrophoneMuted: callManager.muted
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
        if (!callManager.foregroundCall) {
            var account = null;
            if (telepathyHelper.activeAccounts.length > 0) {
                account = telepathyHelper.activeAccounts[0];
            } else {
                // if no account is active, use any account that can make emergency calls
                for (var i in telepathyHelper.accounts) {
                    if (telepathyHelper.accounts[i].emergencyCallsAvailable) {
                        account = telepathyHelper.accounts[i];
                        break;
                    }
                }
            }
            console.log("Calling: " + number + " " + account.accountId);
            callManager.startCall(number, account.accountId);

        } else {
            console.log("Hanging up: " + callManager.foregroundCall.phoneNumber);
            status.text = '';
            var call = callManager.foregroundCall;
            if (call) {
                call.hangup();
            }
        }
    }

    function answer() {
        if (callManager.foregroundCall) {
            //TODO: we'll need an own binding in order to accept calls
            callManager.foregroundCall.answer();
        }
    }

    function hangup() {
        if (callManager.foregroundCall) {
            callManager.foregroundCall.endCall();
        }
    }

    function sendToneToCall(key) {
        if (callManager.foregroundCall) {
            callManager.foregroundCall.sendDTMF(key);
        }
    }

    function startTone(string) {
        callManager.playTone(string);
    }

    function stopTone() {
        //ubuntu call manager can't
    }
//END FUNCTIONS

//BEGIN MODELS

    Connections {
        target: callManager

        //keep track of the status we were in
        property int previousStatus

        onCallsChanged: {
            print("AAA")
            //STATUS_INCOMING
            if (callManager.foregroundCall.ringing || callManager.foregroundCall.incoming) {
                wasVisible = root.visible;
                root.visible = true;
                dialerUtils.notifyRinging();
                root.status = "incoming";

            //Was STATUS_INCOMING now is STATUS_DISCONNECTED: Missed call!
            } else if (!callManager.hasCalls && previousStatus == "incoming") {
                var prettyDate = Qt.formatTime(DateTime(), Qt.locale().timeFormat(Locale.ShortFormat));
                dialerUtils.notifyMissedCall(callManager.foregroundCall.phoneNumber, i18n("%1 called at %2", callManager.foregroundCall.phoneNumber, prettyDate));
                root.visible = wasVisible;
                insertCallInHistory(callManager.foregroundCall.phoneNumber, 0, 0);
                root.status = "idle";

            //STATUS_DISCONNECTED
            } else if (!callManager.hasCalls) {
                insertCallInHistory(callManager.foregroundCall.phoneNumber, callManager.foregroundCall.duration, callManager.foregroundCall.isIncoming ? 1 : 2);
                root.status = "idle";
            //STATUS_DIALING
            } else if (callManager.foregroundCall.dialing) {
                root.status = "dialing";
            }

            //status not STATUS_INCOMING
            if (!callManager.foregroundCall.ringing) {
                dialerUtils.stopRinging();
            }

            previousStatus = root.status;
        }
    }

//END MODELS

}
