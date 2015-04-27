/**
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2014 Marco Martin <mart@kde.org>
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
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.LocalStorage 2.0
import org.nemomobile.voicecall 1.0
import MeeGo.QOfono 0.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

ApplicationWindow {
    id: root

//BEGIN PROPERTIES
    width: 600
    height: 800

    property int status: voiceCallmanager.activeVoiceCall ? voiceCallmanager.activeVoiceCall.status : 0
    //keep track of the status we were in
    property int previousStatus
    //keep track if we were visible when ringing
    property bool wasVisible
    //support a single provider for now
    property string providerId: voiceCallmanager.providers.id(0)
    //was the last call an incoming one?
    property bool isIncoming
//END PROPERTIES

//BEGIN SIGNAL HANDLERS
    onStatusChanged: {
        //STATUS_ACTIVE
        if (status == 1) {
            root.isIncoming = voiceCallmanager.activeVoiceCall.isIncoming;
        //STATUS_INCOMING
        } else if (status == 5) {
            wasVisible = root.visible;
            root.visible = true;
        //Was STATUS_INCOMING now is STATUS_DISCONNECTED: Missed call!
        } else if (status == 7 && previousStatus == 5) {
            dialerUtils.notifyMissedCall();
            root.visible = wasVisible;
            insertCallInHistory(voiceCallmanager.activeVoiceCall.lineId, 0, 0);
        } else if (status == 7) {
            insertCallInHistory(voiceCallmanager.activeVoiceCall.lineId, voiceCallmanager.activeVoiceCall.duration, isIncoming ? 1 : 2);
        }

        previousStatus = status;
    }

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
            console.log("Calling: " + status.text);
            voiceCallmanager.dial(providerId, number);

        } else {
            console.log("Hanging up: " + status.text);
            status.text = '';
            var call = voiceCallmanager.activeVoiceCall;
            if (call) {
                call.hangup();
            }
        }
    }

    function insertCallInHistory(number, duration, callType) {
        //DATABSE
        var db = LocalStorage.openDatabaseSync("PlasmaPhoneDialer", "1.0", "Call history of the Plasma Phone dialer", 1000000);

        db.transaction(
            function(tx) {
                var rs = tx.executeSql("INSERT INTO History VALUES(NULL, ?, date('now'), time('now'), ?, ? )", [number, duration, callType]);

                // Show all added greetings
                var rs = tx.executeSql('SELECT * FROM History where id=?', [rs.insertId]);

                for(var i = 0; i < rs.rows.length; i++) {
                    historyModel.append(rs.rows.item(i));
                }
            }
        )
    }

    function removeCallFromHistory(id) {
        var item = historyModel.get(id);

        if (!item) {
            return;
        }

        var db = LocalStorage.openDatabaseSync("PlasmaPhoneDialer", "1.0", "Call history of the Plasma Phone dialer", 1000000);

        db.transaction(
            function(tx) {
                tx.executeSql("DELETE from History WHERE id=?", [id]);
            }
        )

        historyModel.remove(id);
    }
//END FUNCTIONS

//BEGIN DATABASE
    Component.onCompleted: {
        //HACK: make sure activeVoiceCall is loaded if already existing
        voiceCallmanager.voiceCalls.onVoiceCallsChanged();
        voiceCallmanager.onActiveVoiceCallChanged();

        //DATABSE
        var db = LocalStorage.openDatabaseSync("PlasmaPhoneDialer", "1.0", "Call history of the Plasma Phone dialer", 1000000);

        db.transaction(
            function(tx) {
                // Create the database if it doesn't already exist
                //callType: wether is incoming, outgoing, unanswered
                tx.executeSql('CREATE TABLE IF NOT EXISTS History(id INTEGER PRIMARY KEY AUTOINCREMENT, number TEXT, date DATE, time TIME, duration INTEGER, callType INTEGER)');

                // Add (another) greeting row
               // tx.executeSql("INSERT INTO History VALUES(NULL, ?, date('now'), time('now'), ? )", ['+39000', 0]);

                // Show all added greetings
                var rs = tx.executeSql('SELECT * FROM History');

                for(var i = 0; i < rs.rows.length; i++) {
                    historyModel.append(rs.rows.item(i));
                }
            }
        )
    }
//END DATABASE

//BEGIN MODELS
    ListModel {
        id: historyModel
    }

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

    OfonoNetworkRegistration {
        id: netreg
        Component.onCompleted: {
            netreg.scan()
        }

        onNetworkOperatorsChanged : {
            console.log("operators :"+netreg.currentOperator["Name"].toString())
        }
        modemPath: ofonoManager.modems.length ? ofonoManager.modems[0] : ""
    }

    OfonoNetworkOperator {
        id: netop
    }

    VoiceCallManager {
        id: voiceCallmanager

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

//BEGIN UI
    PlasmaExtras.ConditionalLoader {
        anchors.fill: parent
        when: root.visible && root.status == 0
        source: Qt.resolvedUrl("Dialer/DialPage.qml")
        z: root.status == 0 ? 2 : 0
        opacity: root.status == 0 ? 1 : 0
        Behavior on opacity {
            OpacityAnimator {
                duration: units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    PlasmaExtras.ConditionalLoader {
        anchors.fill: parent
        when: root.status > 0
        source: Qt.resolvedUrl("Call/CallPage.qml")
        opacity: root.status > 0 ? 1 : 0
        z: root.status > 0 ? 2 : 0
        Behavior on opacity {
            OpacityAnimator {
                duration: units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

//END UI
}
