// SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

import org.kde.kwin 3.0 as KWinComponents
import org.kde.kwin.private.effects 1.0
import org.kde.kitemmodels

/**
 * Component that provides a task switcher.
 */
FocusScope {
    id: root
    focus: true

    readonly property QtObject effect: KWinComponents.SceneView.effect
    readonly property QtObject targetScreen: KWinComponents.SceneView.screen

    readonly property real topMargin: MobileShell.Constants.topPanelHeight
    readonly property real bottomMargin: MobileShell.Constants.navigationPanelOnSide(width, height) ? 0 : MobileShell.Constants.navigationPanelThickness
    readonly property real leftMargin: 0
    readonly property real rightMargin: MobileShell.Constants.navigationPanelOnSide(width, height) ? MobileShell.Constants.navigationPanelThickness : 0

    property var taskSwitcherState: TaskSwitcherState {
        taskSwitcher: root
    }

    KWinComponents.WindowModel {
        id: stackModel
    }

    KWinComponents.VirtualDesktopModel {
        id: desktopModel
    }

    property var baseTasksModel: KWinComponents.WindowFilterModel {
        activity: KWinComponents.Workspace.currentActivity
        desktop: KWinComponents.Workspace.currentDesktop
        screenName: root.targetScreen.name
        windowModel: stackModel
        minimizedWindows: true
        windowType: ~KWinComponents.WindowFilterModel.Dock &
                    ~KWinComponents.WindowFilterModel.Desktop &
                    ~KWinComponents.WindowFilterModel.Notification &
                    ~KWinComponents.WindowFilterModel.CriticalNotification
    }

    property var tasksModel: KSortFilterProxyModel {
        sourceModel: baseTasksModel
        filterRoleName: 'skipSwitcher'
        filterRowCallback: function(source_row, source_parent) {
            const window = sourceModel.data(sourceModel.index(source_row, 0, source_parent), Qt.DisplayRole);
            // ensure apps marked to skip the task switcher are skipped (ex. xwaylandvideobridge)
            return !window.skipSwitcher;
        }
    }

    readonly property int tasksCount: taskList.count

    // keep track of task list events
    property int oldTasksCount: tasksCount
    onTasksCountChanged: {
        if (tasksCount === 0 && oldTasksCount !== 0) {
            hide();
        } else if (tasksCount < oldTasksCount && taskSwitcherState.currentTaskIndex >= tasksCount - 1) {
            // if the user is on the last task, and it is closed, scroll left
            taskSwitcherState.animateGoToTaskIndex(tasksCount - 1, Kirigami.Units.longDuration);
        }

        oldTasksCount = tasksCount;
    }

    Keys.onEscapePressed: hide();

    Component.onCompleted: {
        taskList.jumpToFirstVisibleWindow();
        taskList.minimizeAll();

        // fully open the panel (if this is a button press, not gesture)
        if (!root.effect.gestureInProgress) {
            taskSwitcherState.open();
        }
    }

    // called by c++ plugin
    function hideAnimation() {
        closeAnim.restart();
    }

    function instantHide() {
        root.effect.deactivate(true);
    }

    function hide() {
        root.effect.deactivate(false);
    }

    // scroll to delegate index, and activate it
    function activateWindow(index, window) {
        KWinComponents.Workspace.activeWindow = window;
        taskSwitcherState.openApp(index, window);
    }

    Connections {
        target: root.effect

        function onPartialActivationFactorChanged() {
            taskSwitcherState.yPosition = taskSwitcherState.openedYPosition * root.effect.partialActivationFactor;
        }

        function onGestureInProgressChanged() {
            if (!root.effect.gestureInProgress) {
                taskSwitcherState.updateState();
            }
        }
    }

    // view of the desktop background
    KWinComponents.DesktopBackground {
        id: backgroundItem
        activity: KWinComponents.Workspace.currentActivity
        desktop: KWinComponents.Workspace.currentDesktop
        outputName: targetScreen.name
    }

    // background colour
    Rectangle {
        id: backgroundRect
        anchors.fill: parent

        opacity: container.opacity
        color: {
            // animate background colour only if we are *not* opening from the homescreen
            if (taskSwitcherState.wasInActiveTask || !taskSwitcherState.currentlyBeingOpened) {
                return Qt.rgba(0, 0, 0, 0.6);
            } else {
                return Qt.rgba(0, 0, 0, 0.6 * Math.min(1, taskSwitcherState.yPosition / taskSwitcherState.openedYPosition));
            }
        }
    }

    // status bar
    // TODO: improve load times, it is quite slow
    // MobileShell.StatusBar {
    //     id: statusBar
    //     z: 1
    //     colorGroup: Kirigami.Theme.ComplementaryColorGroup
    //     backgroundColor: "transparent"
    //
    //     height: root.topMargin
    //     anchors.top: parent.top
    //     anchors.left: parent.left
    //     anchors.right: parent.right
    // }

    // navigation panel
    MobileShell.NavigationPanel {
        id: navigationPanel
        z: 1
        backgroundColor: Qt.rgba(0, 0, 0, 0.1)
        foregroundColorGroup: Kirigami.Theme.Complementary
        shadow: false

        isVertical: MobileShell.Constants.navigationPanelOnSide(root.width, root.height)

        leftAction: MobileShell.NavigationPanelAction {
            enabled: true
            iconSource: "mobile-task-switcher"
            iconSizeFactor: 0.75

            onTriggered: {
                if (taskList.count === 0) {
                    root.hide();
                } else {
                    const currentIndex = taskSwitcherState.currentTaskIndex;
                    taskSwitcherState.openApp(taskSwitcherState.currentTaskIndex, taskList.getTaskAt(currentIndex).window);
                }
            }
        }

        // home button
        middleAction: MobileShell.NavigationPanelAction {
            enabled: true
            iconSource: "start-here-kde"
            iconSizeFactor: 1
            onTriggered: root.hide()
        }

        // close app/keyboard button
        rightAction: MobileShell.NavigationPanelAction {
            enabled: true
            iconSource: "mobile-close-app"
            iconSizeFactor: 0.75

            onTriggered: {
                taskList.getTaskAt(taskSwitcherState.currentTaskIndex).closeApp();
            }
        }

        rightCornerAction: MobileShell.NavigationPanelAction {
            visible: false
        }
    }

    states: [
        State {
            name: "landscape"
            when: MobileShell.Constants.navigationPanelOnSide(root.width, root.height)
            AnchorChanges {
                target: navigationPanel
                anchors {
                    right: root.right
                    top: root.top
                    bottom: root.bottom
                    left: undefined
                }
            }
            PropertyChanges {
                target: navigationPanel
                width: root.rightMargin
                anchors.topMargin: root.topMargin
            }
        },
        State {
            name: "portrait"
            when: !MobileShell.Constants.navigationPanelOnSide(root.width, root.height)
            AnchorChanges {
                target: navigationPanel
                anchors {
                    top: undefined
                    right: root.right
                    left: root.left
                    bottom: root.bottom
                }
            }
            PropertyChanges {
                target: navigationPanel
                height: root.bottomMargin
            }
        }
    ]

    // task list
    Item {
        id: container

        // provide shell margins
        anchors.fill: parent
        anchors.leftMargin: root.leftMargin
        anchors.rightMargin: root.rightMargin
        anchors.bottomMargin: root.bottomMargin
        anchors.topMargin: root.topMargin

        NumberAnimation on opacity {
            id: closeAnim
            running: false
            to: 0
            duration: 200
            easing.type: Easing.InOutQuad

            onFinished: {
                closeAllButton.closeRequested = false;
            }
        }

        // placeholder message
        ColumnLayout {
            id: placeholder
            spacing: Kirigami.Units.gridUnit
            opacity: (root.tasksCount === 0 && !taskSwitcherState.currentlyBeingClosed) ? 0.9 : 0
            Behavior on opacity { NumberAnimation { duration: 500 } }

            anchors.centerIn: parent

            Kirigami.Icon {
                id: icon
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: Kirigami.Units.iconSizes.large
                implicitHeight: Kirigami.Units.iconSizes.large
                source: "window"
                color: "white"
            }

            Kirigami.Heading {
                Layout.fillWidth: true
                Layout.maximumWidth: root.width * 0.75
                Layout.alignment: Qt.AlignHCenter
                color: "white"
                level: 3
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: i18n("No applications are running.")
            }
        }

        // flicking area for task switcher
        FlickContainer {
            id: flickable
            anchors.fill: parent

            taskSwitcherState: root.taskSwitcherState

            // don't allow FlickContainer to steal from swiping on tasks
            interactive: taskList.taskInteractingCount === 0

            // the item is effectively anchored to the flickable bounds
            TaskList {
                id: taskList
                taskSwitcher: root
                shellTopMargin: root.topMargin
                shellBottomMargin: root.bottomMargin

                opacity: {
                    // animate opacity only if we are *not* opening from the homescreen
                    if (taskSwitcherState.wasInActiveTask || !taskSwitcherState.currentlyBeingOpened) {
                        return 1;
                    } else {
                        return Math.min(1, taskSwitcherState.yPosition / taskSwitcherState.openedYPosition);
                    }
                }

                x: flickable.contentX
                width: flickable.width
                height: flickable.height

                PlasmaComponents.ToolButton {
                    id: closeAllButton
                    property bool closeRequested: false
                    visible: root.tasksCount !== 0

                    anchors {
                        bottom: parent.bottom
                        bottomMargin: taskList.taskY / 2
                        horizontalCenter: parent.horizontalCenter
                    }

                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    Kirigami.Theme.inherit: false

                    opacity: (taskSwitcherState.currentlyBeingOpened || taskSwitcherState.currentlyBeingClosed) ? 0.0 : 1.0
                    Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration } }

                    icon.name: "edit-clear-history"
                    font.bold: true

                    text: closeRequested ? i18n("Confirm Close All") : i18n("Close All")

                    onClicked: {
                        if (closeRequested) {
                            taskList.closeAll();
                        } else {
                            closeRequested = true;
                        }
                    }
                }
            }
        }
    }
}

