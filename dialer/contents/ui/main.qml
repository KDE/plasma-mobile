/*
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
import org.nemomobile.voicecall 1.0
import MeeGo.QOfono 0.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

ApplicationWindow {
    id: root

//BEGIN PROPERTIES
    width: 600
    height: 800
    visible: true
    //color: Qt.rgba(0, 0, 0, 0.9)

    property int status: voiceCallmanager.activeVoiceCall ? voiceCallmanager.activeVoiceCall.status : 0
//END PROPERTIES

//BEGIN MODELS
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
        source: Qt.resolvedUrl("Dialer/Dialer.qml")
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
        Behavior on opacity {
            OpacityAnimator {
                duration: units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

//END UI
    Component.onCompleted: {
        //HACK: make sure activeVoiceCall is loaded if already existing
        voiceCallmanager.voiceCalls.onVoiceCallsChanged();
        voiceCallmanager.onActiveVoiceCallChanged();
    }
}
