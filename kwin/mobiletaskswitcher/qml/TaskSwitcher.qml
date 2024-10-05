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
import org.kde.private.mobileshell.taskswitcher 1.0 as TaskSwitcherData

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
    readonly property TaskSwitcherData.TaskSwitcherState state: TaskSwitcherData.TaskSwitcherState
    readonly property QtObject targetScreen: KWinComponents.SceneView.screen

    readonly property real topMargin: MobileShell.Constants.topPanelHeight
    readonly property real bottomMargin: MobileShell.Constants.navigationPanelOnSide(width, height) ? 0 : MobileShell.Constants.navigationPanelThickness
    readonly property real leftMargin: 0
    readonly property real rightMargin: MobileShell.Constants.navigationPanelOnSide(width, height) ? MobileShell.Constants.navigationPanelThickness : 0

    property var taskSwitcherHelpers: TaskSwitcherHelpers {
        taskSwitcher: root
        stateClass: TaskSwitcherData.TaskSwitcherState
    }

    MobileShell.HapticsEffect {
        id: haptics
    }

    property var tasksModel: TaskSwitcherData.TaskFilterModel {
        screenName: root.targetScreen.name
        windowModel: TaskSwitcherData.TaskModel
    }

    readonly property int tasksCount: taskList.count

    // keep track of task list events
    property int oldTasksCount: tasksCount
    onTasksCountChanged: {
        if (tasksCount === 0 && oldTasksCount !== 0) {
            hide();
        } else if (tasksCount < oldTasksCount && state.currentTaskIndex >= tasksCount) {
            // if the user is on the last task, and it is closed, scroll left
            taskSwitcherHelpers.animateGoToTaskIndex(tasksCount - 1, Kirigami.Units.longDuration);
        }

        oldTasksCount = tasksCount;
    }

    Keys.onEscapePressed: hide();

    Component.onCompleted: {
        state.updateWasInActiveTask(KWinComponents.Workspace.activeWindow);

        // task index from last time using the switcher
        state.initialTaskIndex = Math.min(state.currentTaskIndex, tasksCount - 1);
        if (state.wasInActiveTask) {
            // if we were in an active task instead set initial task index to the position of that task
            state.initialTaskIndex = taskSwitcherHelpers.getTaskIndexFromWindow(KWinComponents.Workspace.activeWindow);
        }

        taskSwitcherHelpers.goToTaskIndex(state.initialTaskIndex);
        taskList.minimizeAll();

        // fully open the switcher (if this is a button press, not gesture)
        if (!root.state.gestureInProgress) {
            taskSwitcherHelpers.open();
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

    Connections {
        target: root.state

        // task scrub mode allows scrubbing through a number of tasks with a mostly horizontal motion
        function taskScrubMode() {
            if (!taskSwitcherHelpers.isInTaskScrubMode) {
                taskSwitcherHelpers.isInTaskScrubMode = true;
                taskSwitcherHelpers.cancelAnimations();
                taskSwitcherHelpers.open();
                if (!taskSwitcherHelpers.hasVibrated) {
                    // Haptic feedback when the task scrub mode engages
                    haptics.buttonVibrate();
                    taskSwitcherHelpers.hasVibrated = true;
                }

            }
            let newTaskIndex = Math.max(0, Math.min(tasksCount - 1, Math.floor(state.touchXPosition / taskSwitcherHelpers.taskScrubDistance) + state.initialTaskIndex));
            if (newTaskIndex != state.currentTaskIndex) {
                taskSwitcherHelpers.animateGoToTaskIndex(newTaskIndex);
            }
        }

        function onTouchPositionChanged() {
            if (taskSwitcherHelpers.isInTaskScrubMode || // once in scrub mode, let's not allow to go out, that can result in inconsistent UX
                (Math.abs(state.xVelocity) > Math.abs(state.yVelocity) * 3 && // gesture needs to be almost completely horizontal
                 Math.abs(state.xVelocity) < 2.5 && // and not with a fast flick TODO! evaluate whether to keep this, it's kinda awkward
                 Math.abs(state.touchXPosition) > taskSwitcherHelpers.taskScrubDistance * 0.95 && // and have moved far enough sideways
                 state.yPosition < taskSwitcherHelpers.undoYThreshold && // and be close to the screen edge
                 tasksCount > 1 // and there needs to be more than one task open
                )) {
                taskScrubMode();
            } else {
                if (state.status == TaskSwitcherData.TaskSwitcherState.Active) {
                    // task switcher is already open
                    // TODO add some sort of feedback for dismissing task switcher (maybe opacity reduction?)
                    return;
                }
                state.yPosition = Math.abs(state.touchYPosition);
                state.xPosition = taskSwitcherHelpers.xPositionFromTaskIndex(state.initialTaskIndex) - state.touchXPosition;
            }
        }

        // actions on an upwards flick
        function upwardsFlick() {
            if (state.wasInActiveTask) {
                // go to homescreen if we were in an active task
                taskSwitcherHelpers.close();
            } else {
                // or normally open task switcher if we were on the homescreen already
                taskSwitcherHelpers.animateGoToTaskIndex(state.currentTaskIndex);
                taskSwitcherHelpers.open();
            }
        }

        // returns to the currently centered app. usually used to "back out" of the switcher
        // if accidentally invoked, but can also be used to switch to an adjacent app and then open it
        function returnToApp() {
            let newIndex = taskSwitcherHelpers.getNearestTaskIndex();
            let appAtNewIndex = taskList.getTaskAt(newIndex).window;
            taskSwitcherHelpers.openApp(newIndex, appAtNewIndex);
        }

        // diagonal quick switch gesture logic
        function quickSwitch() {
            // should "quick switch" to adjacent app in task switcher, but only if we were in an app before
            let newIndex = state.currentTaskIndex;
            let shouldSwitch = false;
            if (state.xVelocity > 0 && state.wasInActiveTask) {
                // flick to the right, go to app to the left
                newIndex = state.currentTaskIndex + 1;
                if (newIndex < tasksCount) {
                    // switch only if flick doesn't go over end of list
                    shouldSwitch = true;
                }
            } else if (state.xVelocity < 0 && state.wasInActiveTask) {
                // flick to the left, go to app to the right
                newIndex = state.currentTaskIndex - 1;
                if (newIndex >= 0) {
                    // switch only if flick doesn't go over end of list
                    shouldSwitch = true;
                }
            }
            if (shouldSwitch) {
                let appAtNewIndex = taskList.getTaskAt(newIndex).window;
                taskSwitcherHelpers.openApp(newIndex, appAtNewIndex, Kirigami.Units.longDuration * 4, Easing.OutExpo);
            } else {
                // if not switching, just open task switcher
                taskSwitcherHelpers.animateGoToTaskIndex(state.currentTaskIndex);
                taskSwitcherHelpers.open();
            }
        }

        // Logic for deciding how to handle the end of a gesture input
        function onGestureInProgressChanged() {
            if (state.gestureInProgress) {
                return;
            }

            if (state.status == TaskSwitcherData.TaskSwitcherState.Active) {
                if (taskSwitcherHelpers.isInTaskScrubMode) {
                    // TODO! do we want to handle upwards flick to dismiss in task scrub mode?
                    // TODO do we want to show a list of thumbnails in task scrub mode?
                    taskSwitcherHelpers.openApp(state.currentTaskIndex, taskList.getTaskAt(state.currentTaskIndex).window);
                } else if (state.yPosition > taskSwitcherHelpers.undoYThreshold) {
                    // close task switcher if it was already open but only if swipe was higher than the undo threshold
                    taskSwitcherHelpers.close();
                    return;
                }
            } else if (state.status == TaskSwitcherData.TaskSwitcherState.Inactive) {
                if (state.totalSquaredVelocity > state.flickVelocityThreshold) {
                    // flick
                    // ratio between y and x velocity as threshold between vertical and horizontal flick
                    let xyVelocityRatio = 1.7; // with 1.7 swipes up to ~60° from horizontal are counted as horizontal
                    if (-state.yVelocity > Math.abs(state.xVelocity) * xyVelocityRatio) {
                        upwardsFlick();
                    } else if (state.yVelocity > Math.abs(state.xVelocity) * xyVelocityRatio) {
                        // downwards flick
                        returnToApp();
                    } else {
                        // sideways flick
                        quickSwitch();
                    }
                } else {
                    // no flick
                    if (state.yPosition > taskSwitcherHelpers.undoYThreshold) {
                        // normal task switcher open
                        taskSwitcherHelpers.animateGoToTaskIndex(state.currentTaskIndex);
                        taskSwitcherHelpers.open();
                    } else {
                        // no flick and not enough activation to go to task switcher
                        if (state.wasInActiveTask) {
                            returnToApp();
                        } else {
                            // do open switcher in case we were on homescreen before
                            taskSwitcherHelpers.animateGoToTaskIndex(state.currentTaskIndex);
                            state.yPosition = taskSwitcherHelpers.openedYPosition;
                            taskSwitcherHelpers.open();
                        }

                    }
                }
            }
        }

        function onVelocityChanged() {
            if (!taskSwitcherHelpers.hasVibrated) {
                if (!state.wasInActiveTask ||
                    (state.wasInActiveTask &&
                     state.yPosition > taskSwitcherHelpers.undoYThreshold &&
                     state.totalSquaredVelocity < state.flickVelocityThreshold)) {
                        // Haptic feedback when conditions are met for the task switcher to open
                        haptics.buttonVibrate();
                        taskSwitcherHelpers.hasVibrated = true;
                }

            }
        }

        function onXPositionChanged() {
            taskSwitcherHelpers.updateTaskIndex();
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
            if (state.wasInActiveTask || !state.currentlyBeingOpened) {
                return Qt.rgba(0, 0, 0, 0.6);
            } else {
                return Qt.rgba(0, 0, 0, 0.6 * Math.min(1, state.yPosition / state.openedYPosition));
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
        visible: ShellSettings.Settings.navigationPanelEnabled
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
                    const currentIndex = state.currentTaskIndex;
                    taskSwitcherHelpers.openApp(state.currentTaskIndex, taskList.getTaskAt(currentIndex).window);
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
                taskList.getTaskAt(state.currentTaskIndex).closeApp();
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
            opacity: (root.tasksCount === 0 && !taskSwitcherHelpers.currentlyBeingClosed) ? 0.9 : 0
            Behavior on opacity { NumberAnimation { duration: 500 } }

            anchors.centerIn: parent

            Kirigami.Icon {
                id: icon
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: Kirigami.Units.iconSizes.large
                implicitHeight: Kirigami.Units.iconSizes.large
                source: "edit-none-symbolic"
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

        RowLayout {
            id: scrubIconList
            opacity: taskSwitcherHelpers.isInTaskScrubMode ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration } }

            anchors.bottom: parent.bottom
            anchors.right: parent.horizontalCenter
            anchors.bottomMargin: taskSwitcherHelpers.openedYPosition * 5 / 8

            anchors.rightMargin: {
                let size = Kirigami.Units.iconSizes.large + Kirigami.Units.largeSpacing * 2;
                let offset = (root.state.currentTaskIndex + 0.5) * size;
                return -offset;
            }
            Behavior on anchors.rightMargin {
                NumberAnimation {
                    duration: taskSwitcherHelpers.xAnimDuration;
                    easing.type: taskSwitcherHelpers.xAnimEasingType;
                }
            }

            spacing: Kirigami.Units.largeSpacing * 2

            layoutDirection: Qt.RightToLeft

            Repeater {
                model: root.tasksModel

                delegate: Kirigami.Icon {
                    id: iconDelegate

                    required property QtObject window
                    required property int index

                    readonly property bool isCenteredIcon: iconDelegate.index === root.state.currentTaskIndex;
                    Layout.preferredHeight: isCenteredIcon ? Kirigami.Units.iconSizes.huge : Kirigami.Units.iconSizes.large
                    Layout.preferredWidth: isCenteredIcon ? Kirigami.Units.iconSizes.huge : Kirigami.Units.iconSizes.large
                    Layout.alignment: Qt.AlignVCenter
                    source: iconDelegate.window.icon
                }
            }
        }

        RowLayout {
            id: scrubIndicator
            opacity: taskSwitcherHelpers.isInTaskScrubMode ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: taskSwitcherHelpers.openedYPosition * 1 / 4

            Kirigami.Icon {
                id: iconScrubBack
                opacity: root.state.currentTaskIndex == 0 ? 0.3 : 1
                Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration * 2; easing.type: Easing.OutExpo } }
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: Kirigami.Units.iconSizes.medium
                implicitHeight: Kirigami.Units.iconSizes.medium
                source: "draw-arrow-back"
                color: "white"
            }

            Item {
                width: taskSwitcherHelpers.windowWidth / 4
            }

            Kirigami.Icon {
                id: iconScrubFront
                opacity: root.state.currentTaskIndex == tasksCount - 1 ? 0.3 : 1
                Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration * 2; easing.type: Easing.OutExpo } }
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: Kirigami.Units.iconSizes.medium
                implicitHeight: Kirigami.Units.iconSizes.medium
                source: "draw-arrow-forward"
                color: "white"
            }
        }

        // flicking area for task switcher
        FlickContainer {
            id: flickable
            anchors.fill: parent

            taskSwitcherState: root.state
            taskSwitcherHelpers: root.taskSwitcherHelpers

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
                    // TODO! do we really not want to animate it always? it's a bit harsh to look at when opening from homescreen
                    if (state.wasInActiveTask || !state.currentlyBeingOpened) {
                        return 1;
                    } else {
                        return Math.min(1, state.yPosition / state.openedYPosition);
                    }
                }

                x: flickable.contentX
                width: flickable.width
                height: flickable.height

                PlasmaComponents.ToolButton {
                    id: closeAllButton
                    property bool closeRequested: false
                    visible: root.tasksCount !== 0 && !taskSwitcherHelpers.isInTaskScrubMode

                    anchors {
                        bottom: parent.bottom
                        bottomMargin: (taskList.taskY + taskList.trackFingerYOffset) / 2
                        horizontalCenter: parent.horizontalCenter
                    }

                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    Kirigami.Theme.inherit: false

                    opacity: (taskSwitcherHelpers.currentlyBeingClosed) ? 0.0 : 1.0
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

