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
import org.kde.plasma.phone.taskpanel 1.0 as TaskPanel

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
        property int oldMouseX: 0
        property int startMouseX: 0
        property bool isDragging: false
        property bool opening: false
        drag.filterChildren: true
        property Button activeButton

        onPressed: {
            startMouseX = oldMouseX = mouse.y;
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
                MobileShell.HomeScreenControls.requestRelativeScroll(Qt.point(mouse.x - oldMouseX, mouse.y - oldMouseY));
            }
            oldMouseY = mouse.y;
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
            property real buttonLength: 0
            
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
                id: tasksButton
                mouseArea: mainMouseArea
                enabled: root.hasTasks
                onClicked: {
                    if (!enabled) {
                        return;
                    }
                    plasmoid.nativeInterface.showDesktop = false;
                    taskSwitcher.visible ? taskSwitcher.hide() : taskSwitcher.show();
                }
                iconSizeFactor: 0.75
                iconSource: "mobile-task-switcher"
                colorGroup: root.showingApp ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
            }

            Button {
                id: showDesktopButton
                anchors.centerIn: parent
                mouseArea: mainMouseArea
                onClicked: {
                    if (!enabled) {
                        return;
                    }
                    root.minimizeAll();
                    MobileShell.HomeScreenControls.resetHomeScreenPosition();
                    plasmoid.nativeInterface.allMinimizedChanged();
                }
                iconSizeFactor: 1
                iconSource: "start-here-kde"
                colorGroup: root.showingApp ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
            }

            Button {
                id: closeTaskButton
                mouseArea: mainMouseArea
                enabled: TaskPanel.KWinVirtualKeyboard.visible || (plasmoid.nativeInterface.hasCloseableActiveWindow && !taskSwitcher.visible)
                onClicked: {
                    if (!enabled) {
                        return
                    }
                    if (TaskPanel.KWinVirtualKeyboard.active) {
                        TaskPanel.KWinVirtualKeyboard.active = false
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

                // mobile-close-app (from plasma-frameworks) seems to have less margins than icons from breeze-icons
                iconSizeFactor: TaskPanel.KWinVirtualKeyboard.visible ? 1 : 0.75
                iconSource: TaskPanel.KWinVirtualKeyboard.visible ? "go-down-symbolic" : "mobile-close-app"
                colorGroup: root.showingApp ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
            }
        }

        Window.onWindowChanged: {
            if (!Window.window)
                return;

            Window.window.offset = Qt.binding(() => {
                // FIXME: find a more precise way to determine the top panel height
                return plasmoid.formFactor === PlasmaCore.Types.Vertical ? MobileShell.TopPanelControls.panelHeight : 0
            });
        }

        states: [
            State {
                name: "landscape"
                when: Screen.width > Screen.height
                PropertyChanges {
                    target: plasmoid.nativeInterface
                    location: PlasmaCore.Types.RightEdge
                }
                PropertyChanges {
                    target: plasmoid
                    width: PlasmaCore.Units.gridUnit
                    height: PlasmaCore.Units.gridUnit
                }
                PropertyChanges {
                    target: icons
                    buttonLength: icons.height * 0.8 / 3
                }
                AnchorChanges {
                    target: tasksButton
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                    }
                }
                PropertyChanges {
                    target: tasksButton
                    width: parent.width
                    height: icons.buttonLength
                    anchors.topMargin: parent.height * 0.1
                }
                PropertyChanges {
                    target: showDesktopButton
                    width: parent.width
                    height: icons.buttonLength
                }
                AnchorChanges {
                    target: closeTaskButton
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                    }
                }
                PropertyChanges {
                    target: closeTaskButton
                    height: icons.buttonLength
                    width: icons.width
                    anchors.bottomMargin: parent.height * 0.1
                }
            }, State {
                name: "portrait"
                when: Screen.width <= Screen.height
                PropertyChanges {
                    target: plasmoid
                    height: PlasmaCore.Units.gridUnit
                }
                PropertyChanges {
                    target: plasmoid.nativeInterface
                    location: PlasmaCore.Types.BottomEdge
                }
                PropertyChanges {
                    target: icons
                    buttonLength: icons.width * 0.8 / 3
                }
                AnchorChanges {
                    target: tasksButton
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                    }
                }
                PropertyChanges {
                    target: tasksButton
                    height: parent.height
                    width: icons.buttonLength
                    anchors.leftMargin: parent.width * 0.1
                }
                PropertyChanges {
                    target: showDesktopButton
                    height: parent.height
                    width: icons.buttonLength
                }
                AnchorChanges {
                    target: closeTaskButton
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                    }
                }
                PropertyChanges {
                    target: closeTaskButton
                    height: parent.height
                    width: icons.buttonLength
                    anchors.rightMargin: parent.width * 0.1
                }
            }
        ]
    }
}
