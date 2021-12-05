/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtGraphicalEffects 1.12

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.phone.taskpanel 1.0 as TaskPanel

Item {
    id: root
    
    property color backgroundColor
    property var foregroundColorGroup
    
    property bool dragGestureEnabled: false
    property var taskSwitcher
    
    property NavigationPanelAction leftAction
    property NavigationPanelAction middleAction
    property NavigationPanelAction rightAction
    
    DropShadow {
        anchors.fill: mouseArea
        visible: !showingApp
        cached: true
        horizontalOffset: 0
        verticalOffset: 1
        radius: 4.0
        samples: 17
        color: Qt.rgba(0,0,0,0.8)
        source: icons
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        drag.filterChildren: true
        
        // drag gesture
        property int oldMouseY: 0
        property int startMouseY: 0
        property int oldMouseX: 0
        property int startMouseX: 0
        property bool opening: false
        
        property NavigationPanelButton activeButton

        onPressed: {
            startMouseX = oldMouseX = mouse.y;
            startMouseY = oldMouseY = mouse.y;
            activeButton = icons.childAt(mouse.x, mouse.y);
        }
        
        onPositionChanged: {
            let newButton = icons.childAt(mouse.x, mouse.y);
            if (newButton != activeButton) {
                activeButton = null;
            }
            
            if (root.dragGestureEnabled) {
                if (!taskSwitcher.currentlyDragging && Math.abs(startMouseY - oldMouseY) < root.height) {
                    oldMouseY = mouse.y;
                    return;
                } else if (mouseArea.pressed) {
                    taskSwitcher.currentlyDragging = true;
                }

                // update offsets with drags
                root.taskSwitcher.oldYOffset = root.taskSwitcher.yOffset;
                root.taskSwitcher.yOffset = Math.max(0, root.taskSwitcher.yOffset - (mouse.y - oldMouseY));
                
                opening = oldMouseY > mouse.y;

                if (root.taskSwitcher.visibility == Window.Hidden && Math.abs(startMouseY - mouse.y) > PlasmaCore.Units.gridUnit && root.taskSwitcher.tasksCount) {
                    // start task switcher gesture
                    activeButton = null;
                    root.taskSwitcher.show(false);
                } else if (taskSwitcher.tasksCount === 0) { // no tasks, let's scroll up the homescreen instead
                    MobileShell.HomeScreenControls.requestRelativeScroll(Qt.point(mouse.x - oldMouseX, mouse.y - oldMouseY));
                }
                
                oldMouseY = mouse.y;
                oldMouseX = mouse.x;
            }
        }
        
        onReleased: {
            if (activeButton) {
                activeButton.clicked();
            }

            if (root.dragGestureEnabled && root.taskSwitcher.currentlyDragging) {
                root.taskSwitcher.currentlyDragging = false;
                root.taskSwitcher.snapOffset();
            }
        }
        
        Item {
            id: icons
            anchors.fill: parent

            visible: plasmoid.configuration.PanelButtonsVisible
            property real buttonLength: 0

            // background colour
            Rectangle {
                anchors.fill: parent
                color: root.backgroundColor
            }

            // button row (anchors provided by state)
            NavigationPanelButton {
                id: leftButton
                mouseArea: mouseArea
                colorGroup: root.foregroundColorGroup
                enabled: root.leftAction.enabled
                iconSizeFactor: root.leftAction.iconSizeFactor
                iconSource: root.leftAction.iconSource
                onClicked: {
                    if (enabled) {
                        root.leftAction.triggered();
                    }
                }
            }

            NavigationPanelButton {
                id: middleButton
                anchors.centerIn: parent
                mouseArea: mouseArea
                colorGroup: root.foregroundColorGroup
                enabled: root.middleAction.enabled
                iconSizeFactor: root.middleAction.iconSizeFactor
                iconSource: root.middleAction.iconSource
                onClicked: {
                    if (enabled) {
                        root.middleAction.triggered();
                    }
                }
            }

            NavigationPanelButton {
                id: rightButton
                mouseArea: mouseArea
                colorGroup: root.foregroundColorGroup
                enabled: root.rightAction.enabled
                iconSizeFactor: root.rightAction.iconSizeFactor
                iconSource: root.rightAction.iconSource
                onClicked: {
                    if (enabled) {
                        root.rightAction.triggered();
                    }
                }
            }
        }
    }

    states: [
        State {
            name: "landscape"
            when: Screen.width > Screen.height
            PropertyChanges {
                target: icons
                buttonLength: icons.height * 0.8 / 3
            }
            AnchorChanges {
                target: leftButton
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
            }
            PropertyChanges {
                target: leftButton
                width: parent.width
                height: icons.buttonLength
                anchors.topMargin: parent.height * 0.1
            }
            PropertyChanges {
                target: middleButton
                width: parent.width
                height: icons.buttonLength
            }
            AnchorChanges {
                target: rightButton
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
            }
            PropertyChanges {
                target: rightButton
                height: icons.buttonLength
                width: icons.width
                anchors.bottomMargin: parent.height * 0.1
            }
        }, State {
            name: "portrait"
            when: Screen.width <= Screen.height
            PropertyChanges {
                target: icons
                buttonLength: icons.width * 0.8 / 3
            }
            AnchorChanges {
                target: leftButton
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                }
            }
            PropertyChanges {
                target: leftButton
                height: parent.height
                width: icons.buttonLength
                anchors.leftMargin: parent.width * 0.1
            }
            PropertyChanges {
                target: middleButton
                height: parent.height
                width: icons.buttonLength
            }
            AnchorChanges {
                target: rightButton
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                }
            }
            PropertyChanges {
                target: rightButton
                height: parent.height
                width: icons.buttonLength
                anchors.rightMargin: parent.width * 0.1
            }
        }
    ]
}