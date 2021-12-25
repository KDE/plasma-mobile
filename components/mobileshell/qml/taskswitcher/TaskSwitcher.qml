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

Item {
    id: root
    visible: false
    
    readonly property real taskPanelHeight: MobileShell.TaskPanelControls.panelHeight
    readonly property real taskPanelWidth: MobileShell.TaskPanelControls.panelWidth
    readonly property bool isPortrait: MobileShell.TaskPanelControls.isPortrait
    
    // dimensions of a window on the screen
    readonly property real windowHeight: root.height - (root.isPortrait ? root.taskPanelHeight : 0) - MobileShell.TopPanelControls.panelHeight
    readonly property real windowWidth: root.width - (root.isPortrait ? 0 : root.taskPanelWidth)
    
    readonly property int tasksCount: root.model.count
    readonly property int currentTaskIndex: tasksView.currentIndex
    property TaskManager.TasksModel model
    
    // offset constants
    readonly property real targetYOffsetDist: root.height - tasksView.height // offset distance to perfect opening
    readonly property real dismissYOffsetDist: root.height
    
    // properties controlled from NavigationPanel (swipe to open gesture)
    property real oldYOffset: 0
    property real yOffset: 0
    
    // set from NavigationPanel in taskpanel containment
    property bool wasInActiveTask: false // whether we were in an app before opening the task switcher
    property bool currentlyDragging: false // whether we are in a swipe up gesture

    property var displaysModel: MobileShell.DisplaysModel {}
    
    enum MovementDirection {
        None = 0,
        Left,
        Right
    }
    
    onVisibleChanged: MobileShell.HomeScreenControls.taskSwitcherVisible = visible;

    onTasksCountChanged: {
        if (tasksCount == 0) {
            hide();
        }
    }
    
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6 * (root.wasInActiveTask ? 1 : Math.min(1, root.yOffset / root.targetYOffsetDist)))
        
        MouseArea {
            anchors.fill: parent
            onClicked: root.hide()
        }
    }

//BEGIN functions

    function show(animation) {
        root.yOffset = 0;
        root.wasInActiveTask = root.model.activeTask.row >= 0;
        
        // skip to first active task
        if (root.wasInActiveTask) {
            tasksView.currentIndex = root.model.activeTask.row;
            tasksView.positionViewAtIndex(root.model.activeTask.row, ListView.SnapPosition);
        }
        
        root.visible = true;
        minimizeAll();
        
        // animate app shrink
        if (animation) {
            offsetAnimator.to = root.targetYOffsetDist;
            offsetAnimator.restart();
        }
    }
    function hide() {
        if (!root.visible) return;
        root.visible = false;
    }

    function snapOffset() {
        let movingUp = root.yOffset > root.oldYOffset;
        
        if (movingUp || root.yOffset >= root.targetYOffsetDist) { // open task switcher and stay
            offsetAnimator.to = root.targetYOffsetDist;
            offsetAnimator.restart();
        } else { // close task switcher and return to app
            if (!root.wasInActiveTask) { // if pulled up from homescreen, don't activate app
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

        var newActiveIdx = root.model.index(id, 0)
        var newActiveGeo = tasksModel.data(newActiveIdx, TaskManager.AbstractTasksModel.ScreenGeometry)
        for (var i = 0 ; i < tasksModel.count; i++) {
            var idx = root.model.index(i, 0)
            if (i == id) {
                root.model.requestActivate(idx);
            } else if (!tasksModel.data(idx, TaskManager.AbstractTasksModel.IsMinimized)) {
                var geo = tasksModel.data(idx, TaskManager.AbstractTasksModel.ScreenGeometry)
                // Only minimize the other windows in the same screen
                if (geo === newActiveGeo) {
                    tasksModel.requestToggleMinimized(idx);
                }
            }
        }
        
        root.visible = false;
    }
    
    function minimizeAll() {
        for (var i = 0 ; i < tasksModel.count; i++) {
            var idx = tasksModel.makeModelIndex(i);
            if (!tasksModel.data(idx, TaskManager.AbstractTasksModel.IsMinimized)) {
                tasksModel.requestToggleMinimized(idx);
            }
        }
    }

    function restoreAll() {
        for (var i = 0 ; i < tasksModel.count; i++) {
            var idx = tasksModel.makeModelIndex(i);
            if (tasksModel.data(idx, TaskManager.AbstractTasksModel.IsMinimized)) {
                tasksModel.requestToggleMinimized(idx);
            }
        }
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
        // root.targetYOffsetDist - animate shrinking of thumbnail, to listview (open task switcher)
        to: 0
        onFinished: {
            if (to === 0) { // close task switcher, and switch to current app
                if (!root.visible) return;
                root.visible = false;
                
                if (activateApp) {
                    setSingleActiveWindow(root.currentTaskIndex);
                }
                activateApp = true;
            } else if (to == root.dismissYOffsetDist) {
                root.hide();
            }
        }
    }
    
    Item {
        id: container
        
        // provide shell margins
        anchors.fill: parent
        anchors.rightMargin: root.isPortrait ? 0 : root.taskPanelWidth
        anchors.bottomMargin: root.isPortrait ? root.taskPanelHeight : 0
        anchors.topMargin: MobileShell.TopPanelControls.panelHeight
        
        // applications list
        ListView {
            id: tasksView
            opacity: root.wasInActiveTask ? 1 : Math.min(1, root.yOffset / root.targetYOffsetDist)        
            anchors.centerIn: parent
            
            readonly property real sizeFactor: 0.75
            readonly property real taskHeaderHeight: PlasmaCore.Units.gridUnit * 2 + PlasmaCore.Units.smallSpacing * 2
            
            width: root.windowWidth * sizeFactor
            height: root.windowHeight * sizeFactor + taskHeaderHeight
            
            model: root.model
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
                let candidateHeight = (tasksView.width / root.windowWidth) * root.windowHeight;
                if (candidateHeight > tasksView.height) {
                    return tasksView.height / root.windowHeight;
                } else {
                    return tasksView.width / root.windowWidth;
                }
            }
            
            delegate: Task {
                id: task
                property int curIndex: model.index
                z: root.currentTaskIndex === curIndex ? 1 : 0
                width: tasksView.width
                height: tasksView.height
                
                taskSwitcher: root
                displaysModel: root.displaysModel
                
                // account for header offset (center the preview)
                y: -tasksView.taskHeaderHeight / 2
                
                // scale gesture
                scale: {
                    let maxScale = 1 / tasksView.scalingFactor;
                    let subtract = (maxScale - 1) * (root.yOffset / root.targetYOffsetDist);
                    let finalScale = Math.max(0, Math.min(maxScale, maxScale - subtract));
                    
                    if ((root.wasInActiveTask || !taskSwitcher.currentlyDragging) && root.currentTaskIndex === task.curIndex) {
                        return finalScale;
                    }
                    return 1;
                }
                
                // ensure that window previews are exactly to the scale of the device screen
                previewWidth: tasksView.scalingFactor * root.windowWidth
                previewHeight: tasksView.scalingFactor * root.windowHeight
            }
        }
    }
}
