/*
 * SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
 * SPDX-FileCopyrightText: 2021-2022 Devin Lin <espidev@gmail.com>
 * 
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.notificationmanager 1.1 as Notifications

/**
 * Lockscreen component that is loaded after the device is locked.
 * 
 * Special attention must be paid to ensuring the GUI loads as fast as possible.
 */
PlasmaCore.ColorScope {
    id: root

    property string password
    
    property bool isWidescreen: root.height < root.width * 0.75
    property bool notificationsShown: false
    
    readonly property bool drawerOpen: flickable.openFactor >= 1
    
    function askPassword() {
        flickable.goToOpenPosition();
    }
    
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    anchors.fill: parent
    
    Notifications.WatchedNotificationsModel {
        id: notifModel
    }
    
    // wallpaper blur 
    Loader {
        anchors.fill: parent
        asynchronous: true
        sourceComponent: WallpaperBlur {
            source: wallpaper
            blur: root.notificationsShown || root.drawerOpen // only blur once animation finished for performance
        }
    }
    
    // header bar and action drawer
    HeaderComponent {
        id: headerBar
        z: 1 // on top of flick area
        anchors.fill: parent
        
        openFactor: flickable.openFactor
        notificationsModel: notifModel
        onPasswordRequested: root.askPassword()
    }

    FlickContainer {
        id: flickable
        anchors.fill: parent
        
        property real openFactor: position / keypadHeight
        
        keypadHeight: PlasmaCore.Units.gridUnit * 20
        
        Component.onCompleted: {
            flickable.position = 0;
            flickable.goToClosePosition();
        }
        
        onPositionChanged: {
            if (position > keypadHeight) {
                position = keypadHeight;
            } else if (position < 0) {
                position = 0;
            }
        }
        
        Item {
            width: flickable.width
            height: flickable.height
            y: flickable.contentY // effectively anchored to the screen
            
            LockScreenNarrowContent {
                id: phoneComponent
                
                visible: !isWidescreen
                active: visible
                opacity: 1 - flickable.openFactor
                
                fullHeight: root.height
                
                notificationsModel: notifModel
                onNotificationsShownChanged: root.notificationsShown = notificationsShown
                
                onPasswordRequested: root.askPassword()
                
                anchors.top: parent.top
                anchors.bottom: scrollUpIconLoader.top
                anchors.left: parent.left
                anchors.right: parent.right
                
                // move while swiping up
                transform: Translate { y: Math.round((1 - phoneComponent.opacity) * (-root.height / 6)) }
            }
            
            LockScreenWideScreenContent {
                id: tabletComponent
                visible: isWidescreen
                active: visible
                opacity: 1 - flickable.openFactor
                
                notificationsModel: notifModel
                onNotificationsShownChanged: root.notificationsShown = notificationsShown
                
                onPasswordRequested: root.askPassword()
                
                anchors.topMargin: headerBar.statusBarHeight
                anchors.top: parent.top
                anchors.bottom: scrollUpIconLoader.top
                anchors.left: parent.left
                anchors.right: parent.right
                
                // move while swiping up
                transform: Translate { y: Math.round((1 - phoneComponent.opacity) * (-root.height / 6)) }
            }
            
            // scroll up icon
            Loader {
                id: scrollUpIconLoader
                asynchronous: true
                
                anchors.bottom: parent.bottom
                anchors.bottomMargin: PlasmaCore.Units.gridUnit + flickable.position * 0.5
                anchors.horizontalCenter: parent.horizontalCenter
                
                sourceComponent: PlasmaCore.IconItem {
                    id: scrollUpIcon
                    implicitWidth: PlasmaCore.Units.iconSizes.smallMedium
                    implicitHeight: PlasmaCore.Units.iconSizes.smallMedium 
                    opacity: 1 - flickable.openFactor
                    
                    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                    source: "arrow-up"
                }
            }
            
            // password keypad
            Loader {
                width: parent.width
                asynchronous: true
                
                anchors.bottom: parent.bottom
                
                sourceComponent: ColumnLayout {
                    transform: Translate { y: flickable.keypadHeight - flickable.position }
                    
                    spacing: PlasmaCore.Units.gridUnit
                    
                    // scroll down icon
                    PlasmaCore.IconItem {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: PlasmaCore.Units.iconSizes.smallMedium
                        implicitHeight: PlasmaCore.Units.iconSizes.smallMedium
                        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                        source: "arrow-down"
                        opacity: Math.sin((Math.PI / 2) * flickable.openFactor + 1.5 * Math.PI) + 1
                    }

                    Keypad {
                        id: keypad
                        Layout.fillWidth: true
                        
                        focus: true
                        swipeProgress: flickable.openFactor
                        onPasswordChanged: flickable.goToOpenPosition()
                    }
                }
            }
        }
    }
}
