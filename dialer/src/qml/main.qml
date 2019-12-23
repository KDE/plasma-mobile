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
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import QtQuick.LocalStorage 2.0

import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.0 as Kirigami

import org.kde.plasma.dialer 1.0

ApplicationWindow {
    id: root

//BEGIN PROPERTIES
    width: 1080
    height: 800

    visible: false

    //keep track if we were visible when ringing
    property bool wasVisible
    //was the last call an incoming one?
    property bool isIncoming

//END PROPERTIES

//BEGIN SIGNAL HANDLERS
    Connections {
        target: dialerUtils
        onMissedCallsActionTriggered: {
            root.visible = true;
        }
        onCallEnded: {
            var callType;
            if (isIncomingCall && callDuration == 0) {
                callType = 0;
            } else if (isIncomingCall && callDuration > 0) {
                callType = 1;
            } else {
                callType = 2;
            }
            historyModel.addCall(callContactNumber, callDuration, callType)
        }
    }

    onVisibleChanged: {
        //TODO
        //reset missed calls if the status is not STATUS_INCOMING when got visible
    }
//END SIGNAL HANDLERS

//BEGIN FUNCTIONS
    function call(number) {
        dialerUtils.dial(number);
    }
//END FUNCTIONS

//BEGIN MODELS
    CallHistoryModel {
        id: historyModel
    }

//END MODELS

//BEGIN UI
    PlasmaExtras.ConditionalLoader {
        anchors.fill: parent

        property bool shouldShow: root.visible && (dialerUtils.callState == "idle" || dialerUtils.callState == "failed")

        when: shouldShow
        source: Qt.resolvedUrl("Dialer/DialPage.qml")
        z: shouldShow ? 2 : 0
        opacity: shouldShow ? 1 : 0
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    PlasmaExtras.ConditionalLoader {
        anchors.fill: parent

        property bool shouldShow: dialerUtils.callState != "idle" && dialerUtils.callState != "failed"

        when: shouldShow
        source: Qt.resolvedUrl("Call/CallPage.qml")
        opacity: shouldShow ? 1 : 0
        z:  shouldShow ? 2 : 0
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

//END UI
}
