/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
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
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.nanoshell 2.0 as NanoShell

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

PlasmaCore.ColorScope {
    id: root
    width: 600
    height: 480
    colorGroup: showingApp ? PlasmaCore.Theme.HeaderColorGroup : PlasmaCore.Theme.ComplementaryColorGroup

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    readonly property color backgroundColor: NanoShell.StartupFeedback.visible ? NanoShell.StartupFeedback.backgroundColor : PlasmaCore.ColorScope.backgroundColor
    readonly property bool showingApp: !plasmoid.nativeInterface.allMinimized

    readonly property bool hasTasks: tasksModel.count > 0

    property QtObject taskSwitcher: taskSwitcherLoader.item ? taskSwitcherLoader.item : null
    Loader {
        id: taskSwitcherLoader
    }
    //FIXME: why it crashes on startup if TaskSwitcher is loaded immediately?
    Connections {
        target: plasmoid.nativeInterface
        function onAllMinimizedChanged() {
            MobileShell.HomeScreenControls.homeScreenVisible = plasmoid.nativeInterface.allMinimized
        }
    }
    Timer {
        running: true
        interval: 200
        onTriggered: {
            taskSwitcherLoader.setSource(Qt.resolvedUrl("TaskSwitcher.qml"), {"model": tasksModel});
        }
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

    TaskManager.TasksModel {
        id: tasksModel
        groupMode: TaskManager.TasksModel.GroupDisabled

        screenGeometry: plasmoid.screenGeometry
        sortMode: TaskManager.TasksModel.SortAlpha

        virtualDesktop: virtualDesktopInfo.currentDesktop
        activity: activityInfo.currentActivity
        //FIXME: workaround
        Component.onCompleted: tasksModel.countChanged();
    }

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }

    MouseArea {
        id: mainMouseArea
        anchors.fill: parent
        property int oldMouseY: 0
        property int startMouseY: 0
        property bool isDragging: false
        property bool opening: false
        drag.filterChildren: true
        property Button activeButton

        onPressed: {
            startMouseY = oldMouseY = mouse.y;
            taskSwitcher.offset = -taskSwitcher.height;
            activeButton = icons.childAt(mouse.x, mouse.y);
        }
        onPositionChanged: {
            let newButton = icons.childAt(mouse.x, mouse.y);
            if (newButton != activeButton) {
                activeButton = null;
            }
            if (!isDragging && Math.abs(startMouseY - oldMouseY) < root.height) {
                oldMouseY = mouse.y;
                return;
            } else {
                isDragging = true;
            }

            taskSwitcher.offset = taskSwitcher.offset - (mouse.y - oldMouseY);
            opening = oldMouseY > mouse.y;

            if (taskSwitcher.visibility == Window.Hidden && taskSwitcher.offset > -taskSwitcher.height + units.gridUnit && taskSwitcher.tasksCount) {
                activeButton = null;
                taskSwitcher.showFullScreen();
            //no tasks, let's scroll up the homescreen instead
            } else if (taskSwitcher.tasksCount === 0) {
                MobileShell.HomeScreenControls.requestHomeScreenPosition(MobileShell.HomeScreenControls.homeScreenPosition - (mouse.y - oldMouseY));
            }
            oldMouseY = mouse.y;
        }
        onReleased: {
            if (taskSwitcher.visibility == Window.Hidden) {
                if (taskSwitcher.tasksCount === 0) {
                    MobileShell.HomeScreenControls.snapHomeScreenPosition();
                }

                if (activeButton) {
                    activeButton.clicked();
                }
                return;
            }

            if (!isDragging) {
                return;
            }

            if (opening) {
                taskSwitcher.show();
            } else {
                taskSwitcher.hide();
            }
        }

        DropShadow {
            anchors.fill: icons
            visible: !showingApp
            cached: true
            horizontalOffset: 0
            verticalOffset: 1
            radius: 4.0
            samples: 17
            color: Qt.rgba(0,0,0,0.8)
            source: icons
        }
        Item {
            id: icons
            anchors.fill: parent

            visible: plasmoid.configuration.PanelButtonsVisible
            
            PlasmaCore.Svg {
                id: panelSvg
                imagePath: "icons/mobile"
                colorGroup: root.showingApp ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
            }
            PlasmaCore.Svg {
                id: startSvg
                imagePath: "icons/start"
                colorGroup: root.showingApp ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
            }
            
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: showingApp ? root.backgroundColor : "transparent"
                    }
                    GradientStop {
                        position: 1
                        color: showingApp ? root.backgroundColor : Qt.rgba(0, 0, 0, 0.1)
                    }
                }
            }

            Button {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: parent.width * 0.1
                }
                height: parent.height
                width: parent.width*0.8/3
                mouseArea: mainMouseArea
                enabled: root.hasTasks
                onClicked: {
                    if (!enabled) {
                        return;
                    }
                    plasmoid.nativeInterface.showDesktop = false;
                    taskSwitcher.visible ? taskSwitcher.hide() : taskSwitcher.show();
                }
                PlasmaCore.SvgItem {
                    anchors.centerIn: parent
                    implicitHeight: 0.75 * parent.height * 0.6 // 0.75 sizing adjustment fix needed 
                    implicitWidth: implicitHeight
                    opacity: parent.enabled ? 1 : 0.5
                    svg: panelSvg
                    elementId: "mobile-task-switcher"
                    
                    Behavior on opacity {
                        NumberAnimation { duration: units.shortDuration }
                    }
                }
            }

            Button {
                id: showDesktopButton
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
                height: parent.height
                width: parent.width*0.8/3
                mouseArea: mainMouseArea
                enabled: !taskSwitcher.visible && (root.showingApp || MobileShell.HomeScreenControls.homeScreenPosition != 0)
                onClicked: {
                    if (!enabled) {
                        return;
                    }
                    root.minimizeAll();
                    MobileShell.HomeScreenControls.resetHomeScreenPosition();
                    plasmoid.nativeInterface.allMinimizedChanged();
                }
                PlasmaCore.SvgItem {
                    anchors.centerIn: parent
                    implicitHeight: parent.height * 0.6
                    implicitWidth: implicitHeight
                    opacity: parent.enabled ? 1 : 0.5
                    svg: startSvg
                    elementId: "16-16-start-here-kde"
                    
                    Behavior on opacity {
                        NumberAnimation { duration: units.shortDuration }
                    }
                }
            }

            Button {
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: parent.width * 0.1
                }
                height: parent.height
                width: parent.width*0.8/3
                mouseArea: mainMouseArea
                enabled: plasmoid.nativeInterface.hasCloseableActiveWindow && !taskSwitcher.visible
                onClicked: {
                    if (!enabled) {
                        return;
                    }
                    if (!plasmoid.nativeInterface.hasCloseableActiveWindow) {
                        return;
                    }
                    var index = taskSwitcher.model.activeTask;
                    if (index) {
                        taskSwitcher.model.requestClose(index);
                    }
                }

                PlasmaCore.SvgItem {
                    anchors.centerIn: parent
                    implicitHeight: 0.75 * parent.height * 0.6 // 0.75 sizing adjustment fix needed 
                    implicitWidth: implicitHeight
                    opacity: parent.enabled ? 1 : 0.5
                    svg: panelSvg
                    elementId: "mobile-close-app"
                    
                    Behavior on opacity {
                        NumberAnimation { duration: units.shortDuration }
                    }
                }
            }
        }
    }
}
