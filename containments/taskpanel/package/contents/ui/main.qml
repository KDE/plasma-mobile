/*
 *  Copyright 2015 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
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
    colorGroup: showingApp ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    readonly property bool showingApp: !plasmoid.nativeInterface.allMinimized// !plasmoid.nativeInterface.showDesktop && (hasTasks || NanoShell.StartupFeedback.visible)

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
        function managePressed(mouse) {
            startMouseY = oldMouseY = mouse.y;
            taskSwitcher.offset = -taskSwitcher.height
        }
        onPressed: managePressed(mouse);
        onPositionChanged: {
            if (!isDragging && Math.abs(startMouseY - oldMouseY) < root.height) {
                oldMouseY = mouse.y;
                return;
            } else {
                isDragging = true;
            }

            taskSwitcher.offset = taskSwitcher.offset - (mouse.y - oldMouseY);
            opening = oldMouseY > mouse.y;
            oldMouseY = mouse.y;
            if (taskSwitcher.visibility == Window.Hidden && taskSwitcher.offset > -taskSwitcher.height + units.gridUnit && taskSwitcher.tasksCount) {
                taskSwitcher.showFullScreen();
            }
        }
        onReleased: {
            if (!isDragging) {
                return;
            }

            if (taskSwitcher.visibility == Window.Hidden) {
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
/*
            Rectangle {
                anchors.fill: parent
                color: root.backgroundColor
                opacity: showingApp ? 1 : 0
                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }
                    height: 1
                    color: PlasmaCore.ColorScope.textColor
                    opacity: 0.2
                }
            }*/
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: showingApp ? PlasmaCore.ColorScope.backgroundColor : "transparent"
                    }
                    GradientStop {
                        position: 1
                        color: showingApp ? PlasmaCore.ColorScope.backgroundColor : Qt.rgba(0, 0, 0, 0.05)
                    }
                }
            }

            Button {
                anchors.left: parent.left
                height: parent.height
                width: parent.width/3
                enabled: root.hasTasks
                iconSource: "box"
                onClicked: {
                    if (taskSwitcher.visible) {
                        return;
                    }
                    plasmoid.nativeInterface.showDesktop = false;
                    taskSwitcher.visible ? taskSwitcher.hide() : taskSwitcher.show();
                }
                onPressed: mainMouseArea.managePressed(mouse);
                onPositionChanged: mainMouseArea.positionChanged(mouse);
                onReleased: mainMouseArea.released(mouse);
            }

            Button {
                id: showDesktopButton
                height: parent.height
                width: parent.width/3
                anchors.horizontalCenter: parent.horizontalCenter
                iconSource: "start-here-kde"
                enabled: taskSwitcher && taskSwitcher.tasksCount > 0
                //checkable: true
                onClicked: {
                    if (taskSwitcher.visible) {
                        return;
                    }
                    root.minimizeAll();
                    MobileShell.HomeScreenControls.resetHomeScreenPosition();
                    plasmoid.nativeInterface.allMinimizedChanged();
                    //plasmoid.nativeInterface.showDesktop = checked;
                }
                onPressed: mainMouseArea.managePressed(mouse);
                onPositionChanged: mainMouseArea.positionChanged(mouse);
                onReleased: mainMouseArea.released(mouse);
                Connections {
                    target: root.taskSwitcher
                    onCurrentTaskIndexChanged: {
                        if (root.taskSwitcher.currentTaskIndex < 0) {
                            showDesktopButton.checked = false;
                        }
                    }
                }
            }

            Button {
                height: parent.height
                width: parent.width/3
                anchors.right: parent.right
                iconSource: "paint-none"
                //FIXME:Qt.UserRole+9 is IsWindow Qt.UserRole+15 is IsClosable. We can't reach that enum from QML
                opacity: plasmoid.nativeInterface.hasCloseableActiveWindow ? 1 : 0.4
                onClicked: {
                    if (taskSwitcher.visible) {
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
                onPressed: mainMouseArea.managePressed(mouse);
                onPositionChanged: mainMouseArea.positionChanged(mouse);
                onReleased: mainMouseArea.released(mouse);
            }
        }
    }
}
