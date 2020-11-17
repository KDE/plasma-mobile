/*
Copyright (C) 2019 Nicolas Fella <nicolas.fella@gmx.de>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.12
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.12
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.workspace.keyboardlayout 1.0
import org.kde.notificationmanager 1.1 as Notifications
import "../components"

PlasmaCore.ColorScope {
    id: root

    property string password
    
    property bool isWidescreen: root.height < root.width * 0.75
    property bool notificationsShown: phoneNotificationsList.count !== 0

    property bool is24HourTime: Qt.locale().timeFormat(Locale.ShortFormat).toLowerCase().indexOf("ap") === -1
    
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    anchors.fill: parent
    
    function isPinDrawerOpen() {
        return passwordFlickable.contentY === passwordFlickable.columnHeight;
    }
    
    // blur background once keypad is open
    FastBlur {
        id: blur
        cached: true
        anchors.fill: parent
        source: wallpaper
        visible: true
        
        property bool doBlur: notificationsShown || isPinDrawerOpen() // only blur once animation finished for performance
        
        Behavior on doBlur {
            NumberAnimation {
                target: blur
                property: "radius"
                duration: 1000
                to: blur.doBlur ? 0 : 50
                easing.type: Easing.InOutQuad
            }
            PropertyAction {
                target: blur
                property: "visible"
                value: blur.doBlur
            }
        }
    }
    
    Notifications.WatchedNotificationsModel {
        id: notifModel
    }
    
    // header bar
    SimpleHeaderBar {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: units.gridUnit
        opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
    }
    
    // phone clock component
    ColumnLayout {
        id: phoneClockComponent
        visible: !isWidescreen
        
        anchors {
            top: parent.top
            topMargin: root.height / 2 - (height / 2 + units.gridUnit * 2)
            left: parent.left
            right: parent.right
        }
        spacing: 0
        opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
        
        states: State {
            name: "notification"; when: notificationsShown
            PropertyChanges { target: phoneClockComponent; anchors.topMargin: units.gridUnit * 5 }
        }
        
        transitions: Transition {
            NumberAnimation {
                properties: "anchors.topMargin"
                easing.type: Easing.InOutQuad
            }
        }
        
        Clock {
            id: phoneClock
            alignment: Qt.AlignHCenter
            Layout.bottomMargin: units.gridUnit * 2 // keep spacing even if media controls are gone
        }
        MediaControls {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.maximumWidth: units.gridUnit * 25
            Layout.minimumWidth: units.gridUnit * 15
            Layout.leftMargin: units.gridUnit
            Layout.rightMargin: units.gridUnit
            z: 5
        }
    }
    
    // tablet clock component
    Item {
        id: tabletClockComponent
        visible: isWidescreen
        width: parent.width / 2   
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            leftMargin: units.gridUnit * 3
        }
        
        ColumnLayout {
            id: tabletLayout
            anchors.centerIn: parent
            spacing: units.gridUnit
            opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
            
            Clock {
                id: tabletClock
                alignment: Qt.AlignLeft
                Layout.fillWidth: true
                Layout.minimumWidth: units.gridUnit * 20
            }
            MediaControls {
                Layout.alignment: Qt.AlignLeft
                Layout.fillWidth: true
                Layout.maximumWidth: units.gridUnit * 25
                Layout.minimumWidth: units.gridUnit * 20
                z: 5
            }
        }
    }
    
    // phone notifications list
    NotificationsList {
        id: phoneNotificationsList
        visible: !isWidescreen
        z: passwordFlickable.contentY === 0 ? 5 : 0 // prevent mousearea from interfering with pin drawer
        anchors {
            top: phoneClockComponent.bottom
            topMargin: units.gridUnit
            bottom: scrollUpIcon.top
            bottomMargin: units.gridUnit
            left: parent.left
            right: parent.right
        }
    }
    
    // tablet notifications list
    ColumnLayout {
        visible: isWidescreen
        z: passwordFlickable.contentY === 0 ? 5 : 0 // prevent mousearea from interfering with pin drawer
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: tabletClockComponent.right
            right: parent.right
            rightMargin: units.gridUnit
        }
        
        NotificationsList {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.minimumHeight: this.notificationListHeight
            Layout.minimumWidth: units.gridUnit * 15
            Layout.maximumWidth: units.gridUnit * 25
        }
    }
    
    // scroll up icon
    PlasmaCore.IconItem {
        id: scrollUpIcon
        anchors.bottom: parent.bottom
        anchors.bottomMargin: units.gridUnit + passwordFlickable.contentY * 0.5
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
        
        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        source: "arrow-up"
    }

    Flickable {
        id: passwordFlickable
        
        anchors.fill: parent
        
        property int columnHeight: units.gridUnit * 20
        
        height: columnHeight + root.height
        contentHeight: columnHeight + root.height
        boundsBehavior: Flickable.StopAtBounds
        
        // always snap to end (either hidden or shown)
        onMovementEnded: {
            if (!atYBeginning && !atYEnd) {
                if (contentY > columnHeight - contentY) {
                    flick(0, -1000);
                } else {
                    flick(0, 1000);
                }
            }
        }

        // wipe password if it is more than half way down the screen
        onContentYChanged: {
            if (contentY < columnHeight / 2) {
                keypad.reset();
            }
        }
        
        ColumnLayout {
            id: passwordLayout
            anchors.bottom: parent.bottom
            
            width: parent.width
            spacing: units.gridUnit
            opacity: Math.sin((Math.PI / 2) * (passwordFlickable.contentY / passwordFlickable.columnHeight) + 1.5 * Math.PI) + 1
            
            // scroll down icon
            PlasmaCore.IconItem {
                Layout.alignment: Qt.AlignHCenter
                colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                source: "arrow-down"
            }

            Keypad {
                id: keypad
                focus: passwordFlickable.contentY === passwordFlickable.columnHeight
                Layout.fillWidth: true
                Layout.minimumHeight: units.gridUnit * 17
                Layout.maximumWidth: root.width
            }
        }
    }
}
