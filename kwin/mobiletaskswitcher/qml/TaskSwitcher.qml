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
        // we need to subtract 1 from the current index when the closed task index is smaller
        // this is because this part of the list has been shifted down by 1 when the closed task was removed.
        if (taskSwitcherHelpers.lastClosedTask < state.currentTaskIndex) {
            state.currentTaskIndex -= 1;

            // animated at the same speed as the task x position in the TaskList so that the task appears not to move from the perspective of the user.
            taskSwitcherHelpers.animateGoToTaskIndex(state.currentTaskIndex, Kirigami.Units.longDuration, Easing.InOutQuad);
            taskSwitcherHelpers.lastClosedTask = -1;
        }

        if (tasksCount === 0 && oldTasksCount !== 0) {
            hide();
        } else if (tasksCount < oldTasksCount) {
            if (state.currentTaskIndex < 0) {
                // if the user is on the frist task, and it is closed, scroll right
                taskSwitcherHelpers.animateGoToTaskIndex(0, Kirigami.Units.longDuration);
            } else if (state.currentTaskIndex >= tasksCount) {
                // if the user is on the last task, and it is closed, scroll left
                taskSwitcherHelpers.animateGoToTaskIndex(tasksCount - 1, Kirigami.Units.longDuration);
            }
        }

        oldTasksCount = tasksCount;
    }

    Keys.onEscapePressed: hide();

    Component.onCompleted: {
        initialSetup();
    }

    function initialSetup() {
        taskSwitcherHelpers.cancelAnimations();
        state.updateWasInActiveTask(KWinComponents.Workspace.activeWindow);

        // ensure the task drawer is not opened and reset values to defaults
        taskSwitcherHelpers.reachedHeightThreshold = false;
        taskSwitcherHelpers.gestureState = TaskSwitcherHelpers.GestureStates.Undecided;
        taskSwitcherHelpers.isInTaskScrubMode = false;

        taskSwitcherHelpers.hasVibrated = false;

        taskSwitcherHelpers.closingFactor = 1;

        taskSwitcherHelpers.taskSwitchCanLaunch = false;
        taskSwitchCanLaunchTimer.restart()

        taskList.taskOffsetEasing = Easing.InOutQuart;
        taskList.homeTouchPositionX = 0;

        backgroundColorOpacityAn.enabled = false;
        backgroundColorOpacity = state.wasInActiveTask ? 1 : 0;
        backgroundColorOpacityAn.enabled = true;

        // reset the offset to have the task drawer off screen
        taskList.setTaskOffsetValue(state.wasInActiveTask ? taskSwitcherHelpers.taskOffsetValue : taskSwitcherHelpers.homeOffsetValue, true);

        // task index from the last time using the switcher
        state.initialTaskIndex = Math.min(state.currentTaskIndex, tasksCount - 1);
        if (state.wasInActiveTask) {
            // if we were in an active task instead set initial task index to the position of that task
            state.initialTaskIndex = taskSwitcherHelpers.getTaskIndexFromWindow(KWinComponents.Workspace.activeWindow);
        } else {
            // reset the task index to the start if on home screen
            state.initialTaskIndex = 0
        }
        state.currentTaskIndex = state.initialTaskIndex

        taskSwitcherHelpers.currentDisplayTask = state.currentTaskIndex;

        taskSwitcherHelpers.goToTaskIndex(state.initialTaskIndex);
        taskList.minimizeAll();

        // fully open the switcher (if this is a button press, not gesture)
        if (!root.state.gestureInProgress) {
            taskSwitcherHelpers.fromButton = true;
            if (state.wasInActiveTask) {
                taskList.setTaskOffsetValue(0, true);
            } else {
                taskList.setTaskOffsetValue(0);
            }
            backgroundColorOpacity = 1;
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
            taskList.setTaskOffsetValue(0, false, Easing.OutQuart);
            if (!taskSwitcherHelpers.isInTaskScrubMode) {
                backgroundColorOpacity = 1;
                taskSwitcherHelpers.cancelAnimations();
                taskSwitcherHelpers.open();
                if (!taskSwitcherHelpers.hasVibrated) {
                    // Haptic feedback when the task scrub mode engages
                    haptics.buttonVibrate();
                    taskSwitcherHelpers.hasVibrated = true;
                }
            }
            // TODO this makes sense, but makes scrub mode feel a bit weird
            // improve trigger distance logic for task scrub mode to fix
            let newTaskIndex = Math.max(0, Math.min(tasksCount - 1, Math.floor(state.touchXPosition / taskSwitcherHelpers.taskScrubDistance) + state.initialTaskIndex - (state.wasInActiveTask ? 0 : 1)));
            if (newTaskIndex != state.currentTaskIndex || !taskSwitcherHelpers.isInTaskScrubMode) {
                taskSwitcherHelpers.animateGoToTaskIndex(newTaskIndex);
                taskSwitcherHelpers.isInTaskScrubMode = true;
            }
        }

        function onTouchPositionChanged() {
            let unmodifiedYposition = Math.abs(state.touchYPosition)
            if (taskSwitcherHelpers.isInTaskScrubMode || // once in scrub mode, let's not allow to go out, that can result in inconsistent UX
                (Math.abs(state.xVelocity) > Math.abs(state.yVelocity) * 3 && // gesture needs to be almost completely horizontal
                Math.abs(state.xVelocity) < 2.5 && // and not with a fast flick TODO! evaluate whether to keep this, it's kinda awkward
                Math.abs(state.touchXPosition) > taskSwitcherHelpers.taskScrubDistance * 0.95 && // and have moved far enough sideways
                unmodifiedYposition < Kirigami.Units.largeSpacing * 2 && // and be close to the screen edge
                tasksCount > 0 && // and there needs to be more than none task open
                !taskSwitcherHelpers.taskDrawerOpened // and the task drawer must not be open
                )) {
                taskScrubMode();
            } else {
                if (taskSwitcherHelpers.currentlyBeingClosed) {
                    // if the task switch is still open but playing the close animation
                    // setup some values and return to the initial setup so that the user can always navigate with no down time
                    state.wasInActiveTask = taskSwitcherHelpers.openAppAnim.running ? true : false
                    taskList.setTaskOffsetValue(state.wasInActiveTask ? taskSwitcherHelpers.taskOffsetValue : taskSwitcherHelpers.homeOffsetValue, true);
                    state.status = !state.wasInActiveTask ? (taskSwitcherHelpers.openAppAnim.closeAnim && !taskSwitcherHelpers.taskDrawerWillOpen ? TaskSwitcherData.TaskSwitcherState.Active : TaskSwitcherData.TaskSwitcherState.Inactive) : TaskSwitcherData.TaskSwitcherState.Inactive
                    initialSetup();
                } else if (taskSwitcherHelpers.openAnim.running) {
                    taskSwitcherHelpers.cancelAnimations();
                    state.status = taskSwitcherHelpers.stateClass.Active;
                }

                state.yPosition = unmodifiedYposition + (taskSwitcherHelpers.taskDrawerOpened || !state.wasInActiveTask ? taskSwitcherHelpers.openedYPosition : 0);

                let newXPosition = taskSwitcherHelpers.xPositionFromTaskIndex(state.initialTaskIndex);
                if (taskSwitcherHelpers.notHomeScreenState && !taskSwitcherHelpers.currentlyBeingClosed) {
                    newXPosition = newXPosition - (state.touchXPosition / taskSwitcherHelpers.currentScale);
                }
                state.xPosition = newXPosition;

                // allows the user to move the task drawer left and right when on the home screen
                taskList.homeTouchPositionX = taskSwitcherHelpers.notHomeScreenState ? 0 : (state.touchXPosition * 0.35);

                // dynamically update the task switcher state based off of the touch position and velocity
                updateTaskSwitcherState()
            }
        }

        function updateTaskSwitcherState() {
            let unmodifiedYposition = Math.abs(state.touchYPosition)

            // if the touch is above heightThreshold, set reachedHeightThreshold to true
            if (unmodifiedYposition > taskSwitcherHelpers.heightThreshold) {
                // set reachedHeightThreshold when above or below two separate points to helps prevent flickering when the task switcher moves in and out of view
                taskSwitcherHelpers.reachedHeightThreshold = true;
                backgroundColorOpacity = taskSwitcherHelpers.notHomeScreenState ? 0 : 1;
            } else if (unmodifiedYposition > taskSwitcherHelpers.undoYThreshold) {
                backgroundColorOpacity = 1;
            } else {
                backgroundColorOpacity = taskSwitcherHelpers.notHomeScreenState ? 1 : 0;
            }

            if (state.totalSquaredVelocity > state.flickVelocityThreshold) {
                // flick
                // ratio between y and x velocity as threshold between vertical and horizontal flick
                let xyVelocityRatio = 1.7; // with 1.7 swipes up to ~60° from horizontal are counted as horizontal
                if (state.yVelocity > Math.abs(state.xVelocity) * xyVelocityRatio) {
                    // downwards flick
                    setTaskDrawerState(TaskSwitcherHelpers.GestureStates.Undecided);
                    if (unmodifiedYposition < taskSwitcherHelpers.undoYThreshold) {
                        taskList.setTaskOffsetValue(taskSwitcherHelpers.notHomeScreenState ? 0 : taskSwitcherHelpers.homeOffsetValue);
                    }
                } else if (-state.yVelocity > Math.abs(state.xVelocity) * xyVelocityRatio || (taskSwitcherHelpers.reachedHeightThreshold && taskSwitcherHelpers.notHomeScreenState)) {
                    // upwards flick or if the touch is above heightThreshold
                    if (taskSwitcherHelpers.notHomeScreenState) {
                        // if in app or task switcher, go home
                        setTaskDrawerState(TaskSwitcherHelpers.GestureStates.Home);
                        if (taskSwitcherHelpers.reachedHeightThreshold) {
                            taskList.setTaskOffsetValue(taskSwitcherHelpers.taskOffsetValue);
                        }
                    } else if (unmodifiedYposition > taskSwitcherHelpers.undoYThreshold) {
                        // else, keep the task switcher in view
                        setTaskDrawerState(TaskSwitcherHelpers.GestureStates.TaskSwitcher);
                        taskList.setTaskOffsetValue(taskSwitcherHelpers.peekOffsetValue);
                    }
                } else if (!taskSwitcherHelpers.reachedHeightThreshold && !taskSwitcherHelpers.isInTaskScrubMode) {
                    // sideways flick
                    if (taskSwitcherHelpers.notHomeScreenState) {
                        taskList.setTaskOffsetValue(0, unmodifiedYposition < taskSwitcherHelpers.openedYPosition ? true : false);
                    }
                    setTaskDrawerState(TaskSwitcherHelpers.GestureStates.HorizontalSwipe);
                }
            } else {
                if (unmodifiedYposition > taskSwitcherHelpers.undoYThreshold) {
                    // if just moveing out of undoYThreshold, set the state to home
                    if (taskSwitcherHelpers.gestureState < TaskSwitcherHelpers.GestureStates.TaskSwitcher) {
                        setTaskDrawerState(TaskSwitcherHelpers.GestureStates.Home)
                    }
                    // if the touch is above heightThreshold, it will retrun home
                    if (unmodifiedYposition > taskSwitcherHelpers.heightThreshold) {
                        taskSwitcherHelpers.hasVibrated = true;
                        if (taskSwitcherHelpers.notHomeScreenState) {
                            // move the task switcher out of view
                            setTaskDrawerState(TaskSwitcherHelpers.GestureStates.Home);
                            taskList.setTaskOffsetValue(taskSwitcherHelpers.taskOffsetValue);
                        } else {
                            // keep the task switcher in view when above heightThreshold and from home
                            setTaskDrawerState(TaskSwitcherHelpers.GestureStates.TaskSwitcher);
                            taskList.setTaskOffsetValue(taskSwitcherHelpers.peekOffsetValue);
                        }
                        // minus largeSpacing from the heightThreshold to help prevent flickering when the task switcher moves in and out of view
                    } else if ((unmodifiedYposition < taskSwitcherHelpers.heightThreshold - Kirigami.Units.largeSpacing) || taskSwitcherHelpers.reachedHeightThreshold == false) {
                        // set reachedHeightThreshold when above or below two separate points to helps prevent flickering when the task switcher moves in and out of view
                        taskSwitcherHelpers.reachedHeightThreshold = false;
                        if (state.totalSquaredVelocity < state.flickVelocityThreshold && taskSwitcherHelpers.taskSwitchCanLaunch) {
                            // if velocity is small enough, move the task switcher into view
                            setTaskDrawerState(TaskSwitcherHelpers.GestureStates.TaskSwitcher);
                            taskList.setTaskOffsetValue(taskSwitcherHelpers.notHomeScreenState ? 0 : taskSwitcherHelpers.peekOffsetValue);
                        }
                    }
                } else {
                    // if under the undo threshold, it will go back to the task switcher if it is open
                    if (taskSwitcherHelpers.taskDrawerOpened) {
                        taskSwitcherHelpers.reachedHeightThreshold = false;
                        setTaskDrawerState(TaskSwitcherHelpers.GestureStates.TaskSwitcher)
                        taskList.setTaskOffsetValue(0);
                    } else {
                        taskSwitcherHelpers.reachedHeightThreshold = false;
                        setTaskDrawerState(TaskSwitcherHelpers.GestureStates.Undecided)
                        taskList.setTaskOffsetValue(taskSwitcherHelpers.notHomeScreenState ? 0 : taskSwitcherHelpers.homeOffsetValue);
                    }
                }
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
            let unmodifiedYposition = Math.abs(state.touchYPosition)
            let newIndex = state.currentTaskIndex;
            let shouldSwitch = false;
            if (state.xVelocity > 0) {
                if (taskSwitcherHelpers.notHomeScreenState) {
                    // flick to the right, go to the app on the left
                    newIndex = state.currentTaskIndex + 1;
                }
                if (newIndex < tasksCount) {
                    // switch only if flick doesn't go over end of list
                    shouldSwitch = true;
                }
            } else if (state.xVelocity < 0) {
                if (taskSwitcherHelpers.notHomeScreenState) {
                    // flick to the left, go to app to the right
                    newIndex = state.currentTaskIndex - 1;
                    if (newIndex >= 0) {
                        // switch only if flick doesn't go over end of list
                        shouldSwitch = true;
                    }
                } else {
                    // flick to the left on the home screen, dismiss the gesture
                    taskSwitcherHelpers.close();
                    retrun;
                }
            }
            if (shouldSwitch) {
                if (!taskSwitcherHelpers.taskDrawerOpened && unmodifiedYposition < taskSwitcherHelpers.openedYPosition) {
                    // if in a app, switch it to the new task when it is under the openedYPosition
                    taskList.setTaskOffsetValue(0, unmodifiedYposition < taskSwitcherHelpers.openedYPosition && taskSwitcherHelpers.notHomeScreenState);
                    let appAtNewIndex = taskList.getTaskAt(newIndex).window;
                    taskSwitcherHelpers.openApp(newIndex, appAtNewIndex, Kirigami.Units.longDuration * 4, Easing.OutExpo);
                } else {
                    // if already in the task switcher or above the openedYPosition, only change the focus to the new task
                    taskSwitcherHelpers.animateGoToTaskIndex(newIndex);
                    taskSwitcherHelpers.open();
                }
            } else {
                // if not switching, just open task switcher
                taskSwitcherHelpers.animateGoToTaskIndex(state.currentTaskIndex);
                taskSwitcherHelpers.open();
            }
        }

        // Logic for deciding how to handle the end of a gesture input
        function onGestureInProgressChanged() {
            taskSwitcherHelpers.fromButton = false;
            if (state.gestureInProgress) {
                taskSwitcherHelpers.currentDisplayTask = state.currentTaskIndex;
                return;
            }

            if (taskList.count === 0) {
                // dismiss the gesture if the task list is empty
                taskSwitcherHelpers.close();
            } if (taskSwitcherHelpers.isInTaskScrubMode) {
                // TODO! do we want to handle upwards flick to dismiss in task scrub mode?
                // TODO do we want to show a list of thumbnails in task scrub mode?
                let unmodifiedYposition = Math.abs(state.touchYPosition)
                backgroundColorOpacity = 1;
                if (taskSwitcherHelpers.taskDrawerOpened || unmodifiedYposition > taskSwitcherHelpers.undoYThreshold) {
                    taskSwitcherHelpers.animateGoToTaskIndex(state.currentTaskIndex);
                    taskSwitcherHelpers.open();
                    taskSwitcherHelpers.isInTaskScrubMode = false;
                } else {
                    taskSwitcherHelpers.openApp(state.currentTaskIndex, taskList.getTaskAt(state.currentTaskIndex).window);
                }
            } else if (taskSwitcherHelpers.gestureState == TaskSwitcherHelpers.GestureStates.Undecided) {
                if (taskSwitcherHelpers.taskDrawerOpened) {
                    // if in the task switcher, return to it
                    taskSwitcherHelpers.animateGoToTaskIndex(state.currentTaskIndex);
                    taskSwitcherHelpers.open();
                } else if (state.wasInActiveTask) {
                    // if inside a app, return to it
                    returnToApp();
                } else {
                    // else dismiss the gesture
                    taskSwitcherHelpers.close();
                }
            } else if (taskSwitcherHelpers.gestureState == TaskSwitcherHelpers.GestureStates.HorizontalSwipe) {
                // sideways flick
                backgroundColorOpacity = 1;
                quickSwitch();
            } else if (taskSwitcherHelpers.gestureState == TaskSwitcherHelpers.GestureStates.TaskSwitcher) {
                // open the task drawer
                backgroundColorOpacity = 1;
                taskSwitcherHelpers.animateGoToTaskIndex(state.currentTaskIndex);
                taskSwitcherHelpers.open();
            } else if (taskSwitcherHelpers.gestureState == TaskSwitcherHelpers.GestureStates.Home) {
                taskSwitcherHelpers.close();
            }
        }

        function onVelocityChanged() {

        }

        function onXPositionChanged() {
            taskSwitcherHelpers.updateTaskIndex();
        }
    }

    // kind of a hack, but this prevents the gesture from immediately activting the task switcher when it is not supposed to
    Timer {
        id: taskSwitchCanLaunchTimer
        interval: 1; running: true; repeat: false
        onTriggered: taskSwitcherHelpers.taskSwitchCanLaunch = true;
    }

    function setTaskDrawerState(value) {
        if (taskSwitcherHelpers.gestureState != TaskSwitcherHelpers.GestureStates.TaskSwitcher && value == TaskSwitcherHelpers.GestureStates.TaskSwitcher) {
            // vibrate only if switching to task drawer
            if (!taskSwitcherHelpers.hasVibrated) {
                // Haptic feedback when the task scrub mode engages
                haptics.buttonVibrate();
                taskSwitcherHelpers.hasVibrated = true;
            }

        }
        taskSwitcherHelpers.gestureState = value;
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
            return Qt.rgba(0, 0, 0, 0.6 * taskSwitcherHelpers.closingFactor * backgroundColorOpacity);
        }
    }

    // animate the background opacity based off of the state.
    property real backgroundColorOpacity: 1
    Behavior on backgroundColorOpacity {
        id: backgroundColorOpacityAn
        NumberAnimation {
            duration: Kirigami.Units.longDuration
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

            opacity: {
                let baseOpacity = ((root.tasksCount === 0 && !taskSwitcherHelpers.currentlyBeingClosed) ? 0.9 : 0);
                return taskSwitcherHelpers.gestureState == TaskSwitcherHelpers.GestureStates.TaskSwitcher ? baseOpacity : 0;
            }
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
            }

            PlasmaComponents.ToolButton {
                id: closeAllButton
                property bool closeRequested: false
                visible: root.tasksCount !== 0 && !taskSwitcherHelpers.isInTaskScrubMode
                enabled: !taskSwitcherHelpers.currentlyBeingClosed && !root.state.gestureInProgress

                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

                anchors {
                    bottom: parent.bottom
                    bottomMargin: (taskList.taskYBase) * 0.75
                    horizontalCenter: taskList.horizontalCenter
                }

                opacity: (taskSwitcherHelpers.currentlyBeingClosed || root.state.gestureInProgress || !taskSwitcherHelpers.taskDrawerOpened) ? 0.0 : 1.0
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

