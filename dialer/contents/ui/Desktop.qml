/*
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2012 Marco Martin <notmart@gmail.com>
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
import QtGraphicalEffects 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.shell 2.0 as Shell
import org.kde.satellite.components 0.1 as SatelliteComponents
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.workspace.components 2.0 as PlasmaWorkspace
import org.nemomobile.voicecall 1.0
import org.kde.kquickcontrolsaddons 2.0
import MeeGo.QOfono 0.2
import "../components"

Item {
    id: homescreen
    width: 1080
    height: 1920

    property Item containment;
    property Item wallpaper;
    property var pendingRemovals: [];
    property int notificationId: 0;
    property int buttonHeight: width/4

    /*
        Notificadtion data object has the following properties:
        appIcon
        image
        appName
        summary
        body
        isPersistent
        expireTimeout
        urgency
        appRealName
        configurable
    */
    function addNotification(source, data, actions) {
        // Do not show duplicated notifications
        // Remove notifications that are sent again (odd, but true)
        for (var i = 0; i < notificationsModel.count; ++i) {
            var tmp = notificationsModel.get(i);
            var matches = (tmp.appName == data.appName &&
                           tmp.summary == data.summary &&
                           tmp.body == data.body);
            var sameSource = tmp.source == source;

            if (sameSource && matches) {
                return;
            }

            if (sameSource || matches) {
                notificationsModel.remove(i)
                break;
            }
        }

        data["id"] = ++notificationId;
        data["source"] = source;
        if (data["summary"].length < 1) {
            data["summary"] = data["body"];
            data["body"] = '';
        }
        data["actions"] = actions;

        notificationsModel.insert(0, data);
        if (!data["isPersistent"]) {
            pendingRemovals.push(notificationId);
            pendingTimer.start();
        }
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

    property OfonoSimManager simManager: ofonoSimManager
    OfonoSimManager {
        id: ofonoSimManager
        modemPath: ofonoManager.modems.length > 0 ? ofonoManager.modems[0] : ""
    }

    OfonoNetworkRegistration {
        id: netreg
        Component.onCompleted: {
            netreg.scan()
            updateStrengthIcon()
        }

        onNetworkOperatorsChanged : {
            console.log("operators :"+netreg.currentOperator["Name"].toString())
        }
        modemPath: ofonoManager.modems.length ? ofonoManager.modems[0] : ""
        function updateStrengthIcon() {
            if (netreg.strength >= 100) {
                strengthIcon.source = "network-mobile-100";
            } else if (netreg.strength >= 80) {
                strengthIcon.source = "network-mobile-80";
            } else if (netreg.strength >= 60) {
                strengthIcon.source = "network-mobile-60";
            } else if (netreg.strength >= 40) {
                strengthIcon.source = "network-mobile-40";
            } else if (netreg.strength >= 20) {
                strengthIcon.source = "network-mobile-20";
            } else {
                strengthIcon.source = "network-mobile-0";
            }
        }

        onStrengthChanged: {
            console.log("Strength changed to " + netreg.strength)
            updateStrengthIcon()
        }
    }

    OfonoNetworkOperator {
        id: netop
    }

    property VoiceCallManager manager: VoiceCallManager {
        id: manager

        onActiveVoiceCallChanged: {
            if (activeVoiceCall) {
                dialerOverlay.open();
                //main.activeVoiceCallPerson = people.personByPhoneNumber(activeVoiceCall.lineId);
                dialerOverlay.item.numberEntryText = activeVoiceCall.lineId;

            } else {
                dialerOverlay.close();
                dialerOverlay.item.numberEntryText = '';

                //main.activeVoiceCallPerson = null;
            }
        }

        onError: {
            console.log('*** QML *** VCM ERROR: ' + message);
        }
    }

    Timer {
        id: pendingTimer
        interval: 5000
        repeat: false
        onTriggered: {
            for (var i = 0; i < pendingRemovals.length; ++i) {
                var id = pendingRemovals[i];
                for (var j = 0; j < notificationsModel.count; ++j) {
                    if (notificationsModel.get(j).id == id) {
                        notificationsModel.remove(j);
                    }
                }
            }
            pendingRemovals = [];
        }
    }

    Rectangle {
        z: 1
        color: Qt.rgba(0, 0, 0, 0.9 * (Math.min(applications.contentY + homescreen.height, homescreen.height) / homescreen.height))
        anchors.fill: parent
    }

    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
    }
    PlasmaCore.DataSource {
        id: notificationsSource

        engine: "notifications"
        interval: 0

        onSourceAdded: {
            connectSource(source);
        }

        onSourceRemoved: {
            for (var i = 0; i < notificationsModel.count; ++i) {
                if (notificationsModel.get(i) == source) {
                    notificationsModel.remove(i);
                    break;
                }
            }
        }

        onNewData: {
            var actions = new Array()
            if (data["actions"] && data["actions"].length % 2 == 0) {
                for (var i = 0; i < data["actions"].length; i += 2) {
                    var action = new Object();
                    action["id"] = data["actions"][i];
                    action["text"] = data["actions"][i+1];
                    actions.push(action);
                }
            }

            homescreen.addNotification(
                    sourceName,
                    data,
                    actions);
        }

    }

    ListModel {
        id: notificationsModel

        ListElement {
            appIcon: "call-start"
            summary: "Missed call from Joe"
            body: "Called at 8:42 from +41 56 373 37 31"
        }
        ListElement {
            appIcon: "im-google"
            summary: "July: Hey! Are you around?"
        }
        ListElement {
            appIcon: "im-google"
            summary: "July: Hello?"
        }
    }

    Loader {
        id: dialerOverlay
        function open() {
            source = Qt.resolvedUrl("Dialer.qml")
            dialerOverlay.item.open();
        }
        function close() {
            dialerOverlay.item.close();
        }
        anchors {
            left: parent.left
            top: statusPanel.bottom
            right: parent.right
            bottom: parent.bottom
        }
        z: 20
    }
    Loader {
        id: pinOverlay
        anchors {
            left: parent.left
            top: statusPanel.bottom
            right: parent.right
            bottom: parent.bottom
        }
        z: 21
        source: simManager.pinRequired != OfonoSimManager.NoPin ? Qt.resolvedUrl("Pin.qml") : ""
    }

    PlasmaCore.ColorScope {
        id: statusPanel
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: units.iconSizes.small
        z: 2
        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.9)

            PlasmaCore.IconItem {
                id: strengthIcon
                colorGroup: PlasmaCore.ColorScope.colorGroup
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                width: units.iconSizes.small
                height: width
            }
            PlasmaComponents.Label {
                anchors {
                    left: strengthIcon.right
                    verticalCenter: parent.verticalCenter
                }
                text: netreg.strength + "% " + netreg.name
                color: PlasmaCore.ColorScope.textColor
                font.pixelSize: parent.height / 2
            }
            PlasmaComponents.Label {
                id: clock
                anchors.fill: parent
                text: Qt.formatTime(timeSource.data.Local.DateTime, "hh:mm")
                color: PlasmaCore.ColorScope.textColor
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                font.pixelSize: height / 2
            }
            MouseArea {
                property int oldMouseY: 0

                anchors.fill: parent
                enabled: !dialerOverlay.item.visible
                onPressed: {
                    oldMouseY = mouse.y;
                    slidingPanel.visible = true;
                }
                onPositionChanged: {
                    slidingPanel.offset = slidingPanel.offset + (mouse.y - oldMouseY);
                    oldMouseY = mouse.y;
                }
                onReleased: slidingPanel.updateState();
            }


            PlasmaWorkspace.BatteryIcon {
                id: batteryIcon
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                width: units.iconSizes.small
                height: width
                hasBattery: pmSource.data["Battery"]["Has Battery"]
                batteryType: "Phone"
                percent: pmSource.data["Battery0"] ? pmSource.data["Battery0"]["Percent"] : 0

                PlasmaCore.DataSource {
                    id: pmSource
                    engine: "powermanagement"
                    connectedSources: sources
                    onSourceAdded: {
                        disconnectSource(source);
                        connectSource(source);
                    }
                    onSourceRemoved: {
                        disconnectSource(source);
                    }
                }
            }
        }
    }

    SlidingPanel {
        id: slidingPanel
        width: homescreen.width
        height: homescreen.height
    }


    PlasmaCore.ColorScope {
        z: 1
        anchors {
            fill: parent
        }

        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

        SatelliteComponents.ApplicationListModel {
            id: appListModel
        }

        GridView {
            id: applications
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            z: 1
            cellWidth: homescreen.buttonHeight
            cellHeight: cellWidth
            model: appListModel
            snapMode: GridView.SnapToRow
            clip: true
            header: MouseArea {
                z: 999
                width: homescreen.width
                height: homescreen.height - units.iconSizes.medium

                onPressAndHold: {
                    containment.action("configure").trigger();
                }

                PlasmaComponents.Label {
                    id: bigClock
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        bottom: notificationView.top
                    }
                    text: Qt.formatTime(timeSource.data.Local.DateTime, "hh:mm")
                    color: PlasmaCore.ColorScope.textColor
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    font.pointSize: 40
                    style: Text.Raised
                    styleColor: "black"
                }

                ListView {
                    id: notificationView
                    spacing: units.smallSpacing
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        bottomMargin: stripe.height * 2
                    }
                    height: parent.height / 3
                    interactive: false

                    z: 1
                    verticalLayoutDirection: ListView.BottomToTop
                    model: notificationsModel

                    add: Transition {
                            NumberAnimation {
                                properties: "x"
                                from: notificationView.width
                                duration: 100
                            }
                        }

                    remove: Transition {
                        NumberAnimation {
                            properties: "x"
                            to: notificationView.width
                            duration: 500
                        }
                        NumberAnimation {
                            properties: "opacity"
                            to: 0
                            duration: 500
                        }
                    }

                    removeDisplaced: Transition {
                        SequentialAnimation {
                            PauseAnimation { duration: 600 }
                            NumberAnimation { properties: "x,y"; duration: 100 }
                        }
                    }

                    delegate: NotificationStripe {}

                }
                SatelliteStripe {
                    id: stripe
                    z: 99
                    y: Math.max(applications.contentY + parent.height, parent.height - height)

                    PlasmaCore.Svg {
                        id: stripeIcons
                        imagePath: Qt.resolvedUrl("../images/homescreenicons.svg")
                    }

                    Row {
                        anchors.fill: parent
                        property int columns: 4
                        property alias buttonHeight: stripe.height

                        HomeLauncherSvg {
                            id: phoneIcon
                            svg: stripeIcons
                            elementId: "phone"
                            callback: function() {
                                dialerOverlay.open()
                            }
                        }

                        HomeLauncherSvg {
                            id: messagingIcon
                            svg: stripeIcons
                            elementId: "messaging"
                            callback: function() { console.log("Start messaging") }
                        }


                        HomeLauncherSvg {
                            id: emailIcon
                            svg: stripeIcons
                            elementId: "email"
                            callback: function() { console.log("Start email") }
                        }


                        HomeLauncherSvg {
                            id: webIcon
                            svg: stripeIcons
                            elementId: "web"
                            callback: function() { console.log("Start web") }
                        }
                    }
                }
            }
            delegate: HomeLauncher {}
            Component.onCompleted : { console.log("WTF " + width) }

            
        }
    }

    Component.onCompleted: {
        //configure the view behavior
        if (desktop) {
            desktop.width = width;
            desktop.height = height;
        }
    }
}
