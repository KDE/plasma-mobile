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
    
    required property real panelHeight // height of task panel, provided by main.qml
    
    property int tasksCount: window.model.count
    property int currentTaskIndex: tasksView.contentX / (tasksView.width + tasksView.spacing)
    property TaskManager.TasksModel model
    
    // properties controlled from main.qml MouseArea (swipe to open gesture)
    property real oldYOffset: 0
    property real yOffset: 0
    
    // offset constants
    readonly property real targetYOffsetDist: window.height - tasksView.height // offset distance to perfect opening
    readonly property real dismissYOffsetDist: window.height
    
    // set from main.qml
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
            tasksView.contentX = Math.max(0, Math.min(tasksView.contentWidth, window.model.activeTask.row * (tasksView.width + tasksView.spacing)));
        }
        
        root.minimizeAll();
        window.visible = true;
        
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
        height: window.height - (MobileShell.TopPanelControls.panelHeight + window.panelHeight + footerButtons.height 
                + PlasmaCore.Units.gridUnit * 2 + PlasmaCore.Units.largeSpacing * 2)
        
        // scale gesture
        scale: {
            if (window.wasInActiveTask || !taskSwitcher.currentlyDragging) {
                let maxScale = 1 / tasksView.scalingFactor;
                let subtract = (maxScale - 1) * (window.yOffset / window.targetYOffsetDist);
                let finalScale = Math.max(0, Math.min(maxScale, maxScale - subtract));
                
                return finalScale;
            }
            return 1;
        }

        // ensure that window previews are exactly to the scale of the device screen
        property real windowHeight: window.height - window.panelHeight - MobileShell.TopPanelControls.panelHeight
        property real scalingFactor: {
            let candidateWidth = tasksView.width;
            let candidateHeight = (tasksView.width / window.width) * windowHeight;
            
            if (candidateHeight > tasksView.height) {
                return tasksView.height / windowHeight;
            } else {
                return tasksView.width / window.width;
            }
        }
                
        model: window.model
        snapMode: ListView.SnapToItem
        orientation: ListView.Horizontal
        spacing: PlasmaCore.Units.largeSpacing
        displayMarginBeginning: 2 * (width + spacing)
        displayMarginEnd: 2 * (width + spacing)
        
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: PlasmaCore.Units.longDuration; easing.type: Easing.InOutQuad }
        }
        
        property real currentIndexInView: indexAt(contentX, contentY)
        
        MouseArea {
            z: -1
            anchors.fill: parent
            visible: tasksView.count === 0
            enabled: visible
            onClicked: { // close window on tap if there are no delegates
                if (tasksView.count === 0) {
                    window.hide()
                }
            }
            
            PlasmaComponents.Label {
                anchors.centerIn: parent
                text: i18n("No applications are open")
                color: "white"
            }
        }
        
        delegate: Task {
            id: task
            property int curIndex: model.index
            width: tasksView.width
            height: tasksView.height
            z: curIndex === tasksView.currentIndexInView ? 1 : 0
            
            // ensure that window previews are exactly to the scale of the device screen
            previewWidth: tasksView.scalingFactor * window.width
            previewHeight: tasksView.scalingFactor * tasksView.windowHeight
        }
    }
    
    RowLayout {
        id: footerButtons
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: PlasmaCore.Units.largeSpacing + window.panelHeight
        anchors.topMargin: PlasmaCore.Units.largeSpacing
        
        spacing: PlasmaCore.Units.largeSpacing
        
        PlasmaComponents.ToolButton {
            Layout.alignment: Qt.AlignRight
            icon.width: PlasmaCore.Units.iconSizes.medium
            icon.height: PlasmaCore.Units.iconSizes.medium
            icon.name: "view-list-symbolic" // "view-grid-symbolic"
            text: i18n("Switch to list view")
            display: PlasmaComponents.ToolButton.IconOnly
        }
        
        PlasmaComponents.ToolButton {
            Layout.alignment: Qt.AlignHCenter
            icon.width: PlasmaCore.Units.iconSizes.medium
            icon.height: PlasmaCore.Units.iconSizes.medium
            icon.name: "trash-empty"
            text: i18n("Clear All")
            display: PlasmaComponents.ToolButton.IconOnly
        }
        
        PlasmaComponents.ToolButton {
            Layout.alignment: Qt.AlignLeft
            icon.width: PlasmaCore.Units.iconSizes.medium
            icon.height: PlasmaCore.Units.iconSizes.medium
            icon.name: "system-search"
            text: i18n("Search")
            display: PlasmaComponents.ToolButton.IconOnly
        }
    }
}
