/*
SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>

SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.workspace.keyboardlayout 1.0
import org.kde.notificationmanager 1.1 as Notifications
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

PlasmaCore.ColorScope {
    id: root

    property string password
    
    property bool isWidescreen: root.height < root.width * 0.75
    property bool notificationsShown: false

    property bool is24HourTime: Qt.locale().timeFormat(Locale.ShortFormat).toLowerCase().indexOf("ap") === -1
    
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    anchors.fill: parent
    
    function isPinDrawerOpen() {
        return passwordFlickable.contentY === passwordFlickable.columnHeight;
    }

    function askPassword() {
        showPasswordAnim.restart();
    }
    NumberAnimation {
        id: showPasswordAnim
        target: passwordFlickable
        property: "contentY"
        from: 0
        to: passwordFlickable.contentHeight - passwordFlickable.height
        duration: PlasmaCore.Units.longDuration
        easing.type: Easing.InOutQuad
    }
    
    // blur background once keypad is open
    FastBlur {
        id: blur
        cached: true
        anchors.fill: parent
        source: wallpaper
        radius: 50
        opacity: 0
        
        property bool doBlur: notificationsShown || isPinDrawerOpen() // only blur once animation finished for performance
        Behavior on doBlur {
            NumberAnimation {
                target: blur
                property: "opacity"
                duration: 1000
                to: blur.doBlur ? 0 : 1
                easing.type: Easing.InOutQuad
            }
        }
    }
    
    Notifications.WatchedNotificationsModel {
        id: notifModel
    }
    
    // header bar
    Loader {
        id: headerBar
        asynchronous: true
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: PlasmaCore.Units.gridUnit * 1.25
        opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
        sourceComponent: MobileShell.StatusBar {
            id: statusBar
            colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
            backgroundColor: "transparent"
            
            showSecondRow: false
            showDropShadow: true
            showTime: false
            disableSystemTray: true // HACK: prevent SIGABRT
        }
    }

    // phone lockscreen component
    Loader {
        id: phoneComponent
        visible: !isWidescreen
        active: visible
        opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
        
        asynchronous: true
        z: passwordFlickable.contentY === 0 ? 5 : 0 // in front of password flickable when closed
        anchors {
            top: parent.top
            bottom: scrollUpIcon.top
            left: parent.left
            right: parent.right
            topMargin: item && !root.notificationsShown ? Math.round(root.height / 2 - (item.implicitHeight / 2 + PlasmaCore.Units.gridUnit * 2)) : PlasmaCore.Units.gridUnit * 5
            bottomMargin: PlasmaCore.Units.gridUnit
        }
        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: loadTimer.running ? 0 : PlasmaCore.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        // avoid topMargin animation when item is being loaded
        onLoaded: loadTimer.restart();
        Timer {
            id: loadTimer
            interval: PlasmaCore.Units.longDuration
        }
        
        // move while swiping up
        transform: Translate { y: Math.round((1 - phoneComponent.opacity) * (-root.height / 6)) }
        
        sourceComponent: ColumnLayout {
            id: phoneClockComponent
            spacing: 0
            
            Clock {
                id: phoneClock
                alignment: Qt.AlignHCenter
                Layout.bottomMargin: PlasmaCore.Units.gridUnit * 2 // keep spacing even if media controls are gone
            }
            MobileShell.MediaControlsWidget {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.maximumWidth: PlasmaCore.Units.gridUnit * 25
                Layout.leftMargin: PlasmaCore.Units.gridUnit
                Layout.rightMargin: PlasmaCore.Units.gridUnit
            }
            
            NotificationsList {
                id: phoneNotificationsList
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.topMargin: PlasmaCore.Units.gridUnit
                z: passwordFlickable.contentY === 0 ? 5 : 0 // prevent mousearea from interfering with pin drawer
                onCountChanged: root.notificationsShown = count !== 0
            }
        }
    }
    
    // tablet lockscreen component
    Loader {
        id: tabletComponent
        visible: isWidescreen
        active: visible
        opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
        
        asynchronous: true
        z: passwordFlickable.contentY === 0 ? 5 : 0 // in front of password flickable when closed
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: scrollUpIcon.top
        
        // move while swiping up
        transform: Translate { y: Math.round((1 - phoneComponent.opacity) * (-root.height / 6)) }
        
        sourceComponent: Item {
            Item {
                id: tabletClockComponent
                width: parent.width / 2   
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    leftMargin: PlasmaCore.Units.gridUnit * 3
                }
                
                ColumnLayout {
                    id: tabletLayout
                    anchors.centerIn: parent
                    spacing: PlasmaCore.Units.gridUnit
                    
                    Clock {
                        id: tabletClock
                        alignment: Qt.AlignLeft
                        Layout.fillWidth: true
                        Layout.minimumWidth: PlasmaCore.Units.gridUnit * 20
                    }
                    MobileShell.MediaControlsWidget {
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: true
                        Layout.maximumWidth: PlasmaCore.Units.gridUnit * 25
                    }
                }
            }
                
            // tablet notifications list
            ColumnLayout {
                id: tabletNotificationsList
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: tabletClockComponent.right
                    right: parent.right
                    rightMargin: PlasmaCore.Units.gridUnit
                }
                
                NotificationsList {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.maximumHeight: parent.height
                    Layout.minimumHeight: this.notificationListHeight
                    Layout.minimumWidth: PlasmaCore.Units.gridUnit * 15
                    Layout.maximumWidth: PlasmaCore.Units.gridUnit * 25
                    onCountChanged: root.notificationsShown = count !== 0
                }
            }
        }
    }
    
    // scroll up icon
    PlasmaCore.IconItem {
        id: scrollUpIcon
        anchors.bottom: parent.bottom
        anchors.bottomMargin: PlasmaCore.Units.gridUnit + passwordFlickable.contentY * 0.5
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 1 - (passwordFlickable.contentY / passwordFlickable.columnHeight)
        
        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        source: "arrow-up"
    }

    Flickable {
        id: passwordFlickable
        
        anchors.fill: parent
        
        property int columnHeight: PlasmaCore.Units.gridUnit * 20
        property int oldContentY: contentY
        
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
            if (contentY < columnHeight / 2 && oldContentY >= columnHeight / 2) {
                keypad.reset();
            }
            oldContentY = contentY;
        }
        
        ColumnLayout {
            id: passwordLayout
            anchors.bottom: parent.bottom
            
            width: parent.width
            spacing: PlasmaCore.Units.gridUnit
            
            // scroll down icon
            PlasmaCore.IconItem {
                Layout.alignment: Qt.AlignHCenter
                colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                source: "arrow-down"
                opacity: Math.sin((Math.PI / 2) * (passwordFlickable.contentY / passwordFlickable.columnHeight) + 1.5 * Math.PI) + 1
            }

            Keypad {
                id: keypad
                focus: true
                swipeProgress: passwordFlickable.contentY / passwordFlickable.columnHeight
                Layout.fillWidth: true
                onPasswordChanged: {
                    passwordFlickable.contentY = passwordFlickable.contentHeight - passwordFlickable.height
                }
            }
        }
    }
    
    LockOsd {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: PlasmaCore.Units.largeSpacing
    }
}
