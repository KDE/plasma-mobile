/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

NanoShell.FullScreenOverlay {
    id: window

    visible: false
    width: Screen.width
    height: Screen.height
    
    required property real taskPanelHeight // height of task panel, provided by main.qml
    
    // dimensions of a window on the screen
    readonly property real windowHeight: window.height - (navPanel.isPortrait ? window.taskPanelHeight : 0) - MobileShell.TopPanelControls.panelHeight
    readonly property real windowWidth: window.width - (navPanel.isPortrait ? 0 : window.taskPanelHeight)
    
    property int tasksCount: window.model.count
    property int currentTaskIndex: tasksView.currentIndex
    property TaskManager.TasksModel model
    
    // properties controlled from main.qml MouseArea (swipe to open gesture)
    property real oldYOffset: 0
    property real yOffset: 0
    
    // offset constants
    readonly property real targetYOffsetDist: window.height - tasksView.height // offset distance to perfect opening
    readonly property real dismissYOffsetDist: window.height
    
    // set from NavigationPanel in main.qml
    property bool wasInActiveTask: false // whether we were in an app before opening the task switcher
    property bool currentlyDragging: false // whether we are in a swipe up gesture

    Component.onCompleted: plasmoid.nativeInterface.panel = window;

    enum MovementDirection {
        None = 0,
        Left,
        Right
    }
    
    onVisibleChanged: {
        if (!visible) {
            window.contentItem.opacity = 1;
        }
        // hide homescreen elements to make use of wallpaper
        if (visible) {
            MobileShell.HomeScreenControls.hideHomeScreen(!window.wasInActiveTask); // only animate if going from homescreen
        } else {
            MobileShell.HomeScreenControls.showHomeScreen(true);
        }
        MobileShell.HomeScreenControls.taskSwitcherVisible = visible;
    }

    onTasksCountChanged: {
        if (tasksCount == 0) {
            hide();
        }
    }
    
    // background
    color: "transparent"
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6 * (window.wasInActiveTask ? 1 : Math.min(1, window.yOffset / window.targetYOffsetDist)))
        
        MouseArea {
            anchors.fill: parent
            onClicked: hide()
        }
    }

//BEGIN functions
    function show(animation) {
        window.yOffset = 0;
        window.wasInActiveTask = window.model.activeTask.row >= 0;
        
        // skip to first active task
        if (window.wasInActiveTask) {
            tasksView.currentIndex = window.model.activeTask.row;
            tasksView.contentX = Math.max(0, Math.min(tasksView.contentWidth, window.model.activeTask.row * (tasksView.width + tasksView.spacing)));
        }
        
        window.visible = true;
        root.minimizeAll();
        
        // animate app shrink
        if (animation) {
            offsetAnimator.to = window.targetYOffsetDist;
            offsetAnimator.restart();
        }
    }
    function hide() {
        if (!window.visible) return;
        window.visible = false;
    }

    function snapOffset() {
        let movingUp = window.yOffset > window.oldYOffset;
        
        if (movingUp || window.yOffset >= window.targetYOffsetDist) { // open task switcher and stay
            offsetAnimator.to = window.targetYOffsetDist;
            offsetAnimator.restart();
        } else { // close task switcher and return to app
            if (!window.wasInActiveTask) { // if pulled up from homescreen, don't activate app
                offsetAnimator.activateApp = false;
            }
            offsetAnimator.to = 0;
            offsetAnimator.restart();
        }
    }
    
    // scroll to delegate index, and activate it
    function activateWindow(id) {
        offsetAnimator.to = 0;
        offsetAnimator.restart();
    }
    
    function setSingleActiveWindow(id, delegate) {
        if (id < 0) {
            return;
        }

        var newActiveIdx = window.model.index(id, 0)
        var newActiveGeo = tasksModel.data(newActiveIdx, TaskManager.AbstractTasksModel.ScreenGeometry)
        for (var i = 0 ; i < tasksModel.count; i++) {
            var idx = window.model.index(i, 0)
            if (i == id) {
                window.model.requestActivate(idx);
            } else if (!tasksModel.data(idx, TaskManager.AbstractTasksModel.IsMinimized)) {
                var geo = tasksModel.data(idx, TaskManager.AbstractTasksModel.ScreenGeometry)
                // Only minimize the other windows in the same screen
                if (geo === newActiveGeo) {
                    tasksModel.requestToggleMinimized(idx);
                }
            }
        }
        
        window.visible = false;
    }
//END functions
    
    // animate app grow and shrink
    NumberAnimation on yOffset {
        id: offsetAnimator
        duration: PlasmaCore.Units.longDuration
        easing.type: Easing.InOutQuad
        
        property bool activateApp: true
        
        // states of to:
        // 0 - open/resume app (zoom up the thumbnail)
        // window.targetYOffsetDist - animate shrinking of thumbnail, to listview (open task switcher)
        to: 0
        onFinished: {
            if (to === 0) { // close task switcher, and switch to current app
                if (!window.visible) return;
                window.visible = false;
                
                if (activateApp) {
                    setSingleActiveWindow(window.currentTaskIndex);
                }
                activateApp = true;
            } else if (to == window.dismissYOffsetDist) {
                window.hide();
            }
        }
    }
    
    ListView {
        id: tasksView
        z: 100
        opacity: window.wasInActiveTask ? 1 : Math.min(1, window.yOffset / window.targetYOffsetDist)
        
        property real horizontalMargin: PlasmaCore.Units.gridUnit * 3
        anchors.centerIn: parent
        
        width: window.width - horizontalMargin * 2
        height: window.windowHeight - (PlasmaCore.Units.gridUnit * 2 + PlasmaCore.Units.largeSpacing * 2)
        
        model: window.model
        orientation: ListView.Horizontal
        
        highlightRangeMode: ListView.StrictlyEnforceRange // ensures currentIndex is updated
        snapMode: ListView.SnapToItem
        
        spacing: PlasmaCore.Units.largeSpacing
        displayMarginBeginning: 2 * (width + spacing)
        displayMarginEnd: 2 * (width + spacing)
        
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: PlasmaCore.Units.longDuration; easing.type: Easing.InOutQuad }
        }
        
        // ensure that window previews are exactly to the scale of the device screen
        property real scalingFactor: {
            let candidateHeight = (tasksView.width / window.width) * window.windowHeight;
            
            if (candidateHeight > tasksView.height) {
                return tasksView.height / window.windowHeight;
            } else {
                return tasksView.width / window.windowWidth;
            }
        }
        
        delegate: Task {
            id: task
            property int curIndex: model.index
            z: window.currentTaskIndex === curIndex ? 1 : 0
            width: tasksView.width
            height: tasksView.height
            
            // account for header offset (center the preview)
            y: task.headerHeight / 2
            
            // scale gesture
            scale: {
                let maxScale = 1 / tasksView.scalingFactor;
                let subtract = (maxScale - 1) * (window.yOffset / window.targetYOffsetDist);
                let finalScale = Math.max(0, Math.min(maxScale, maxScale - subtract));
                
                if ((window.wasInActiveTask || !taskSwitcher.currentlyDragging) && window.currentTaskIndex === task.curIndex) {
                    return finalScale;
                }
                return 1;
            }
            
            // ensure that window previews are exactly to the scale of the device screen
            previewWidth: tasksView.scalingFactor * window.windowWidth
            previewHeight: tasksView.scalingFactor * window.windowHeight
        }
    }
    
    // top panel swipe down gesture
    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: MobileShell.TopPanelControls.panelHeight
        
        property int oldMouseY: 0
        onPositionChanged: {
            MobileShell.TopPanelControls.requestRelativeScroll(mouse.y - oldMouseY);
            oldMouseY = mouse.y;
        }
        onPressed: {
            oldMouseY = mouse.y;
            MobileShell.TopPanelControls.startSwipe();
        }
        onReleased: MobileShell.TopPanelControls.endSwipe();
    }
    
    // task panel
    NavigationPanel {
        id: navPanel
        
        property bool isPortrait: Screen.width <= Screen.height
        width: isPortrait ? implicitWidth : window.taskPanelHeight
        height: isPortrait ? window.taskPanelHeight : implicitWidth
        
        anchors.left: isPortrait ? parent.left : undefined
        anchors.right: parent.right
        anchors.top: isPortrait ? undefined: parent.top
        anchors.bottom: parent.bottom
        
        taskSwitcher: window
        backgroundColor: window.visible ? Qt.rgba(0, 0, 0, 0.1) : "transparent"
        foregroundColorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        dragGestureEnabled: false
        
        Behavior on backgroundColor { ColorAnimation {} }
        
        leftAction: NavigationPanelAction {
            enabled: true
            iconSource: "mobile-task-switcher"
            iconSizeFactor: 0.75
            onTriggered: {
                if (window.wasInActiveTask) {
                    window.activateWindow(window.currentTaskIndex);
                } else {
                    window.hide();
                }
            }
        }
        
        middleAction: NavigationPanelAction {
            enabled: true
            iconSource: "start-here-kde"
            iconSizeFactor: 1
            onTriggered: {
                window.hide();
                root.triggerHomescreen();
            }
        }
        
        rightAction: NavigationPanelAction {
            enabled: true
            iconSource: "mobile-close-app"
            iconSizeFactor: 0.75
            onTriggered: {
                tasksModel.requestClose(tasksModel.index(window.currentTaskIndex, 0));
            }
        }
    }
}
