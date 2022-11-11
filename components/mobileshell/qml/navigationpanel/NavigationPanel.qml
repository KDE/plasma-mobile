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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState

Item {
    id: root
    
    property bool shadow: false
    property color backgroundColor
    property var foregroundColorGroup
    
    property bool dragGestureEnabled: false
    property var taskSwitcher
    
    property NavigationPanelAction leftAction
    property NavigationPanelAction middleAction
    property NavigationPanelAction rightAction
    
    property NavigationPanelAction leftCornerAction
    property NavigationPanelAction rightCornerAction
    
    DropShadow {
        anchors.fill: mouseArea
        visible: shadow
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

        MobileShell.HapticsEffectLoader {
            id: haptics
        }
        
        onPressed: {
            startMouseX = oldMouseX = mouse.y;
            startMouseY = oldMouseY = mouse.y;
            activeButton = icons.childAt(mouse.x, mouse.y);
            if (activeButton && activeButton.enabled) {
                haptics.buttonVibrate();
            }
        }
        
        onPositionChanged: {
            let newButton = icons.childAt(mouse.x, mouse.y);
            if (newButton != activeButton) {
                activeButton = null;
            }
            
            if (root.dragGestureEnabled) {
                if (!opening && Math.abs(startMouseY - oldMouseY) < root.height) {
                    oldMouseY = mouse.y;
                    return;
                } else if (mouseArea.pressed) {
                    opening = true;
                }

                if (root.taskSwitcher.visible) {
                    // update task switcher drag
                    let offsetY = (mouse.y - oldMouseY) * 0.5; // we want to make the gesture take a longer swipe than it being pixel perfect
                    let offsetX = (mouse.x - oldMouseX) * 0.7; // we want to make the gesture not too hard to swipe, but not too easy
                    taskSwitcher.taskSwitcherState.yPosition = Math.max(0, taskSwitcher.taskSwitcherState.yPosition - offsetY);
                    taskSwitcher.taskSwitcherState.xPosition -= offsetX;
                }

                if (!root.taskSwitcher.visible && Math.abs(startMouseY - mouse.y) > PlasmaCore.Units.gridUnit && taskSwitcher.tasksCount) {
                    // start task switcher gesture
                    activeButton = null;
                    root.taskSwitcher.show(false);
                } else if (taskSwitcher.tasksCount === 0) { // no tasks, let's scroll up the homescreen instead
                    MobileShellState.HomeScreenControls.requestRelativeScroll(Qt.point(mouse.x - oldMouseX, mouse.y - oldMouseY));
                }
                
                oldMouseY = mouse.y;
                oldMouseX = mouse.x;
            }
        }
        
        onReleased: {
            if (activeButton) {
                activeButton.clicked();
            } else if (root.dragGestureEnabled && taskSwitcher.taskSwitcherState.currentlyBeingOpened) {
                taskSwitcher.taskSwitcherState.updateState();
            }
        }
        
        Item {
            id: icons
            anchors.fill: parent

            property real buttonLength: 0

            // background colour
            Rectangle {
                anchors.fill: parent
                color: root.backgroundColor
            }

            // button row (anchors provided by state)
            NavigationPanelButton {
                id: leftButton
                visible: root.leftAction.visible
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
                visible: root.middleAction.visible
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
                visible: root.rightAction.visible
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
            
            NavigationPanelButton {
                id: rightCornerButton
                visible: root.rightCornerAction.visible
                mouseArea: mouseArea
                colorGroup: root.foregroundColorGroup
                enabled: root.rightCornerAction.enabled
                iconSizeFactor: root.rightCornerAction.iconSizeFactor
                iconSource: root.rightCornerAction.iconSource
                onClicked: {
                    if (enabled) {
                        root.rightCornerAction.triggered();
                    }
                }
            }
        }
    }

    states: [
        State {
            name: "landscape"
            when: root.width < root.height
            PropertyChanges {
                target: icons
                buttonLength: Math.min(PlasmaCore.Units.gridUnit * 10, icons.height * 0.7 / 3)
            }
            AnchorChanges {
                target: leftButton
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: middleButton.bottom
                }
            }
            PropertyChanges {
                target: leftButton
                width: parent.width
                height: icons.buttonLength
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
                    bottom: middleButton.top
                }
            }
            PropertyChanges {
                target: rightButton
                height: icons.buttonLength
                width: icons.width
            }
            AnchorChanges {
                target: rightCornerButton
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
            }
            PropertyChanges {
                target: rightCornerButton
                height: PlasmaCore.Units.gridUnit * 2
                width: icons.width
            }
        }, State {
            name: "portrait"
            when: root.width >= root.height
            PropertyChanges {
                target: icons
                buttonLength: Math.min(PlasmaCore.Units.gridUnit * 8, icons.width * 0.7 / 3)
            }
            AnchorChanges {
                target: leftButton
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: middleButton.left
                }
            }
            PropertyChanges {
                target: leftButton
                height: parent.height
                width: icons.buttonLength
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
                    left: middleButton.right
                }
            }
            PropertyChanges {
                target: rightButton
                height: parent.height
                width: icons.buttonLength
            }
            AnchorChanges {
                target: rightCornerButton
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                }
            }
            PropertyChanges {
                target: rightCornerButton
                height: parent.height
                width: PlasmaCore.Units.gridUnit * 2
            }
        }
    ]
}
