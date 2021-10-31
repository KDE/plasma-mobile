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

//BEGIN functions
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
    
    function triggerHomescreen() {
        root.minimizeAll();
        MobileShell.HomeScreenControls.resetHomeScreenPosition();
        MobileShell.HomeScreenControls.showHomeScreen(true);
        plasmoid.nativeInterface.allMinimizedChanged();
    }
//END functions

    Connections {
        target: plasmoid.nativeInterface
        function onAllMinimizedChanged() {
            MobileShell.HomeScreenControls.homeScreenVisible = plasmoid.nativeInterface.allMinimized
        }
    }

    TaskManager.TasksModel {
        id: tasksModel
        groupMode: TaskManager.TasksModel.GroupDisabled

        screenGeometry: plasmoid.screenGeometry
        sortMode: TaskManager.TasksModel.SortAlpha

        virtualDesktop: virtualDesktopInfo.currentDesktop
        activity: activityInfo.currentActivity
    }

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }
    
    Window.onWindowChanged: {
        if (!Window.window)
            return;

        Window.window.offset = Qt.binding(() => {
            return plasmoid.formFactor === PlasmaCore.Types.Vertical ? MobileShell.TopPanelControls.panelHeight : 0
        });
    }

    // task switcher
    Loader {
        id: taskSwitcherLoader
        sourceComponent: TaskSwitcher {
            model: tasksModel
            taskPanelHeight: root.state === "portrait" ? root.height : root.width
        }
    }

    // bottom navigation panel
    NavigationPanel {
        id: panel
        anchors.fill: parent
        opacity: (root.taskSwitcher && root.taskSwitcher.visible) ? 0 : 1 // hide bar when task switcher is open
        
        backgroundColor: root.showingApp ? root.backgroundColor : "transparent"
        foregroundColorGroup: root.showingApp ? PlasmaCore.Theme.NormalColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
        
        dragGestureEnabled: true
        taskSwitcher: root.taskSwitcher
            
        leftAction: NavigationPanelAction {
            enabled: hasTasks
            iconSource: "mobile-task-switcher"
            iconSizeFactor: 0.75
            
            onTriggered: {
                plasmoid.nativeInterface.showDesktop = false;
                taskSwitcher.visible ? taskSwitcher.hide() : taskSwitcher.show(true);
            }
        }
        
        middleAction: NavigationPanelAction {
            enabled: true
            iconSource: "start-here-kde"
            iconSizeFactor: 1
            onTriggered: root.triggerHomescreen()
        }
        
        rightAction: NavigationPanelAction {
            enabled: TaskPanel.KWinVirtualKeyboard.visible || (plasmoid.nativeInterface.hasCloseableActiveWindow && !taskSwitcher.visible)
            // mobile-close-app (from plasma-frameworks) seems to have less margins than icons from breeze-icons
            iconSizeFactor: TaskPanel.KWinVirtualKeyboard.visible ? 1 : 0.75
            iconSource: TaskPanel.KWinVirtualKeyboard.visible ? "go-down-symbolic" : "mobile-close-app"
            
            onTriggered: {
                if (TaskPanel.KWinVirtualKeyboard.active) {
                    TaskPanel.KWinVirtualKeyboard.active = false;
                } else if (plasmoid.nativeInterface.hasCloseableActiveWindow) {
                    var index = taskSwitcher.model.activeTask;
                    if (index) {
                        taskSwitcher.model.requestClose(index);
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
                target: plasmoid.nativeInterface
                location: PlasmaCore.Types.RightEdge
            }
            PropertyChanges {
                target: plasmoid
                width: PlasmaCore.Units.gridUnit
                height: PlasmaCore.Units.gridUnit
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
        }
    ]
}
