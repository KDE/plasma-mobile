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
    
    required property bool gestureDragging
    required property real panelHeight // height of task panel, provided by main.qml
    
    property int tasksCount: window.model.count
    property int currentTaskIndex: tasksView.contentX / (tasksView.width + tasksView.spacing)
    property TaskManager.TasksModel model
    
    property real offset: 0

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
        MobileShell.HomeScreenControls.setHomeScreenOpacity(visible ? 0 : 1);
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
        color: Qt.rgba(0, 0, 0, 0.6)
        
        MouseArea {
            anchors.fill: parent
            onClicked: hide()
        }
    }

    function show() {
        window.offset = 0;
        // skip to first active task
        if (window.model.activeTask.row >= 0) {
            tasksView.contentX = window.model.activeTask.row * (tasksView.width + tasksView.spacing);
        }
        
        root.minimizeAll();
        window.visible = true;
    }
    function hide() {
        if (!window.visible) {
            return;
        }
        window.visible = false;
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
    
    //Rectangle {
        //id: liveAppShrink
        //anchors.fill: parent
        //anchors.topMargin: MobileShell.TopPanelControls.panelHeight
        //anchors.bottomMargin: window.panelHeight
        
////         visible: window.gestureDragging
        //z: tasksView.z + 1
        //color: Qt.rgba(255, 255, 255, 0.1)
        
        //transform: Scale {
            //origin.x: window.width / 2
            //origin.y: MobileShell.TopPanelControls.panelHeight + liveAppShrink.height / 2
            //xScale: {
                //let minScale = tasksView.scalingFactor;
                //let travelDist = window.height - tasksView.height;
                //let subtract = (1 - minScale) * (window.offset / travelDist);
                //return Math.min(1, Math.max(minScale, 1 - subtract));
            //}
            //yScale: xScale
        //}
        
        //Loader {
            //id: pipeWireLoader
            //anchors.fill: parent
            
            //z: tasksView.z + 1
            //source: Qt.resolvedUrl("./Thumbnail.qml")
            //onStatusChanged: {
                //if (status === Loader.Error) {
                    //visible = false;
                //}
            //}
            
            //function syncDelegateGeometry() {
                //window.model.requestPublishDelegateGeometry(window.model.activeTask, Qt.rect(parent.x, parent.y, pipeWireLoader.width, pipeWireLoader.height), pipeWireLoader);
            //}
            //Component.onCompleted: syncDelegateGeometry();
            //Connections {
                //target: window.model
                //function onActiveTaskChanged() {
                    //pipeWireLoader.syncDelegateGeometry();
                //}
            //}
        //}
    //}
    
    ListView {
        id: tasksView
        z: 100
        
        property real horizontalMargin: PlasmaCore.Units.gridUnit * 3
        anchors.centerIn: parent
        
        width: window.width - horizontalMargin * 2
        height: window.height - (MobileShell.TopPanelControls.panelHeight + window.panelHeight + footerButtons.height 
                + PlasmaCore.Units.gridUnit * 2 + PlasmaCore.Units.largeSpacing * 2)
        
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
        
        property real offset: 0
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
            
            // ensure that window previews are exactly to the scale of the device screen
            previewWidth: tasksView.scalingFactor * window.width
            previewHeight: tasksView.scalingFactor * tasksView.windowHeight
            
            scale: {
                if (task.curIndex === window.currentTaskIndex) {
                    let maxScale = 1 / tasksView.scalingFactor;
                    let travelDist = window.height - tasksView.height;
                    let subtract = (maxScale - 1) * (window.offset / travelDist);
                    let finalScale = Math.max(1, Math.min(maxScale, maxScale - subtract));
                    
                    return finalScale;
                }
                return 1;
            }
            
            onDragOffsetChanged: tasksView.offset = dragOffset
            
            // TODO slide right animation
            //transform: Translate { 
                //x: task.curIndex < tasksView.currentIndexInView ? Math.min(task.width + tasksView.spacing, tasksView.offset / 2) : 0 
            //}
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
