// SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024-2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.taskswitcherplugin as TaskSwitcherPlugin

import org.kde.kwin 3.0 as KWinComponents
import org.kde.kwin.private.effects 1.0
import org.kde.kitemmodels


/**
 * Component that provides a task switcher.
 */
FocusScope {
    id: root
    focus: true

    property TaskSwitcherPlugin.MobileTaskSwitcherState state
    readonly property QtObject effect: KWinComponents.SceneView.effect
    readonly property QtObject targetScreen: KWinComponents.SceneView.screen

    readonly property real navBottomMargin: MobileShell.Constants.navigationPanelOnSide(width, height) ? 0 : MobileShell.Constants.navigationPanelThickness
    readonly property real navRightMargin: MobileShell.Constants.navigationPanelOnSide(width, height) ? MobileShell.Constants.navigationPanelThickness : 0
    readonly property real topMargin: ShellSettings.Settings.autoHidePanelsEnabled ? 0 : MobileShell.Constants.topPanelHeight
    readonly property real bottomMargin: ShellSettings.Settings.autoHidePanelsEnabled ? 0 : navBottomMargin
    readonly property real leftMargin: 0
    readonly property real rightMargin: ShellSettings.Settings.autoHidePanelsEnabled ? 0 : navRightMargin

    property var taskSwitcherHelpers: TaskSwitcherHelpers {
        taskSwitcher: root
        taskList: taskList
    }

    MobileShell.HapticsEffect {
        id: haptics
    }

    property TaskSwitcherPlugin.TaskFilterModel tasksModel: TaskSwitcherPlugin.TaskFilterModel {
        screenName: root.targetScreen.name
        windowModel: root.state.taskModel
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

    function initialSetup(): void {
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
        if (!state.gestureInProgress) {
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
    function hideAnimation(): void {
        closeAnim.restart();
    }

    function instantHide(): void {
        state.deactivate(true);
    }

    function hide(): void {
        state.deactivate(false);
    }

    Connections {
        target: root.state

        // task scrub mode allows scrubbing through a number of tasks with a mostly horizontal motion
        function taskScrubMode(): void {
            taskList.setTaskOffsetValue(0, false, Easing.OutQuart);
            if (!root.taskSwitcherHelpers.isInTaskScrubMode) {
                root.backgroundColorOpacity = 1;
                root.taskSwitcherHelpers.cancelAnimations();
                root.taskSwitcherHelpers.open();
                if (!root.taskSwitcherHelpers.hasVibrated) {
                    // Haptic feedback when the task scrub mode engages
                    haptics.buttonVibrate();
                    root.taskSwitcherHelpers.hasVibrated = true;
                }
            }
            // TODO this makes sense, but makes scrub mode feel a bit weird
            // improve trigger distance logic for task scrub mode to fix
            let newTaskIndex = Math.max(0, Math.min(root.tasksCount - 1, Math.floor(root.state.touchXPosition / root.taskSwitcherHelpers.taskScrubDistance) + root.state.initialTaskIndex - (root.state.wasInActiveTask ? 0 : 1)));
            if (newTaskIndex != root.state.currentTaskIndex || !root.taskSwitcherHelpers.isInTaskScrubMode) {
                root.taskSwitcherHelpers.animateGoToTaskIndex(newTaskIndex);
                root.taskSwitcherHelpers.isInTaskScrubMode = true;
            }
        }

        function onTouchPositionChanged(): void {
            let unmodifiedYposition = Math.abs(root.state.touchYPosition)
            if (root.taskSwitcherHelpers.isInTaskScrubMode || // once in scrub mode, let's not allow to go out, that can result in inconsistent UX
                (Math.abs(root.state.xVelocity) > Math.abs(root.state.yVelocity) * 3 && // gesture needs to be almost completely horizontal
                Math.abs(root.state.xVelocity) < 2.5 && // and not with a fast flick TODO! evaluate whether to keep this, it's kinda awkward
                Math.abs(root.state.touchXPosition) > root.taskSwitcherHelpers.taskScrubDistance * 0.95 && // and have moved far enough sideways
                unmodifiedYposition < Kirigami.Units.largeSpacing * 2 && // and be close to the screen edge
                root.tasksCount > 0 && // and there needs to be more than none task open
                !root.taskSwitcherHelpers.taskDrawerOpened // and the task drawer must not be open
                )) {
                taskScrubMode();
            } else {
                if (root.taskSwitcherHelpers.currentlyBeingClosed) {
                    // if the task switch is still open but playing the close animation
                    // setup some values and return to the initial setup so that the user can always navigate with no down time
                    root.state.wasInActiveTask = root.taskSwitcherHelpers.openAppAnim.running ? true : false
                    taskList.setTaskOffsetValue(root.state.wasInActiveTask ? root.taskSwitcherHelpers.taskOffsetValue : root.taskSwitcherHelpers.homeOffsetValue, true);
                    root.state.status = !root.state.wasInActiveTask ? (root.taskSwitcherHelpers.openAppAnim.closeAnim && !root.taskSwitcherHelpers.taskDrawerWillOpen ? TaskSwitcherPlugin.MobileTaskSwitcherState.Active : TaskSwitcherPlugin.MobileTaskSwitcherState.Inactive) : TaskSwitcherPlugin.MobileTaskSwitcherState.Inactive
                    root.initialSetup();
                } else if (root.taskSwitcherHelpers.openAnim.running) {
                    root.taskSwitcherHelpers.cancelAnimations();
                    root.state.status = root.taskSwitcherHelpers.stateClass.Active;
                }

                root.state.yPosition = unmodifiedYposition + (root.taskSwitcherHelpers.taskDrawerOpened || !root.state.wasInActiveTask ? root.taskSwitcherHelpers.openedYPosition : 0);

                let newXPosition = root.taskSwitcherHelpers.xPositionFromTaskIndex(root.state.initialTaskIndex);
                if (root.taskSwitcherHelpers.notHomeScreenState && !root.taskSwitcherHelpers.currentlyBeingClosed) {
                    newXPosition = newXPosition - (root.state.touchXPosition / root.taskSwitcherHelpers.currentScale);
                }
                root.state.xPosition = newXPosition;

                // allows the user to move the task drawer left and right when on the home screen
                taskList.homeTouchPositionX = root.taskSwitcherHelpers.notHomeScreenState ? 0 : (root.state.touchXPosition * 0.35);

                // dynamically update the task switcher state based off of the touch position and velocity
                updateTaskSwitcherState()
            }
        }

        function updateTaskSwitcherState(): void {
            let unmodifiedYposition = Math.abs(root.state.touchYPosition)

            // if the touch is above heightThreshold, set reachedHeightThreshold to true
            if (unmodifiedYposition > root.taskSwitcherHelpers.heightThreshold) {
                // set reachedHeightThreshold when above or below two separate points to helps prevent flickering when the task switcher moves in and out of view
                root.taskSwitcherHelpers.reachedHeightThreshold = true;
                root.backgroundColorOpacity = root.taskSwitcherHelpers.notHomeScreenState ? 0 : 1;
            } else if (unmodifiedYposition > root.taskSwitcherHelpers.undoYThreshold) {
                root.backgroundColorOpacity = 1;
            } else {
                root.backgroundColorOpacity = root.taskSwitcherHelpers.notHomeScreenState ? 1 : 0;
            }

            if (root.state.totalSquaredVelocity > root.state.flickVelocityThreshold) {
                // flick
                // ratio between y and x velocity as threshold between vertical and horizontal flick
                let xyVelocityRatio = 1.7; // with 1.7 swipes up to ~60° from horizontal are counted as horizontal
                if (root.state.yVelocity > Math.abs(root.state.xVelocity) * xyVelocityRatio) {
                    // downwards flick
                    root.setTaskDrawerState(TaskSwitcherHelpers.GestureStates.Undecided);
                    if (unmodifiedYposition < root.taskSwitcherHelpers.undoYThreshold) {
                        taskList.setTaskOffsetValue(root.taskSwitcherHelpers.notHomeScreenState ? 0 : root.taskSwitcherHelpers.homeOffsetValue);
                    }
                } else if (-root.state.yVelocity > Math.abs(root.state.xVelocity) * xyVelocityRatio || (root.taskSwitcherHelpers.reachedHeightThreshold && root.taskSwitcherHelpers.notHomeScreenState)) {
                    // upwards flick or if the touch is above heightThreshold
                    if (root.taskSwitcherHelpers.notHomeScreenState) {
                        // if in app or task switcher, go home
                        root.setTaskDrawerState(TaskSwitcherHelpers.GestureStates.Home);
                        if (root.taskSwitcherHelpers.reachedHeightThreshold) {
                            taskList.setTaskOffsetValue(root.taskSwitcherHelpers.taskOffsetValue);
                        }
                    } else if (unmodifiedYposition > root.taskSwitcherHelpers.undoYThreshold) {
                        // else, keep the task switcher in view
                        root.setTaskDrawerState(TaskSwitcherHelpers.GestureStates.TaskSwitcher);
                        taskList.setTaskOffsetValue(root.taskSwitcherHelpers.peekOffsetValue);
                    }
                } else if (!root.taskSwitcherHelpers.reachedHeightThreshold && !root.taskSwitcherHelpers.isInTaskScrubMode) {
                    // sideways flick
                    if (root.taskSwitcherHelpers.notHomeScreenState) {
                        taskList.setTaskOffsetValue(0, unmodifiedYposition < root.taskSwitcherHelpers.openedYPosition ? true : false);
                    }
                    root.setTaskDrawerState(TaskSwitcherHelpers.GestureStates.HorizontalSwipe);
                }
            } else {
                if (unmodifiedYposition > root.taskSwitcherHelpers.undoYThreshold) {
                    // if just moveing out of undoYThreshold, set the state to home
                    if (root.taskSwitcherHelpers.gestureState < TaskSwitcherHelpers.GestureStates.TaskSwitcher) {
                        root.setTaskDrawerState(TaskSwitcherHelpers.GestureStates.Home)
                    }
                    // if the touch is above heightThreshold, it will retrun home
                    if (unmodifiedYposition > root.taskSwitcherHelpers.heightThreshold) {
                        root.taskSwitcherHelpers.hasVibrated = true;
                        if (root.taskSwitcherHelpers.notHomeScreenState) {
                            // move the task switcher out of view
                            root.setTaskDrawerState(TaskSwitcherHelpers.GestureStates.Home);
                            taskList.setTaskOffsetValue(root.taskSwitcherHelpers.taskOffsetValue);
                        } else {
                            // keep the task switcher in view when above heightThreshold and from home
                            root.setTaskDrawerState(TaskSwitcherHelpers.GestureStates.TaskSwitcher);
                            taskList.setTaskOffsetValue(root.taskSwitcherHelpers.peekOffsetValue);
                        }
                        // minus largeSpacing from the heightThreshold to help prevent flickering when the task switcher moves in and out of view
                    } else if ((unmodifiedYposition < root.taskSwitcherHelpers.heightThreshold - Kirigami.Units.largeSpacing) || root.taskSwitcherHelpers.reachedHeightThreshold == false) {
                        // set reachedHeightThreshold when above or below two separate points to helps prevent flickering when the task switcher moves in and out of view
                        root.taskSwitcherHelpers.reachedHeightThreshold = false;
                        if (root.state.totalSquaredVelocity < root.state.flickVelocityThreshold && root.taskSwitcherHelpers.taskSwitchCanLaunch) {
                            // if velocity is small enough, move the task switcher into view
                            root.setTaskDrawerState(TaskSwitcherHelpers.GestureStates.TaskSwitcher);
                            taskList.setTaskOffsetValue(root.taskSwitcherHelpers.notHomeScreenState ? 0 : root.taskSwitcherHelpers.peekOffsetValue);
                        }
                    }
                } else {
                    // if under the undo threshold, it will go back to the task switcher if it is open
                    if (root.taskSwitcherHelpers.taskDrawerOpened) {
                        root.taskSwitcherHelpers.reachedHeightThreshold = false;
                        root.setTaskDrawerState(TaskSwitcherHelpers.GestureStates.TaskSwitcher)
                        taskList.setTaskOffsetValue(0);
                    } else {
                        root.taskSwitcherHelpers.reachedHeightThreshold = false;
                        root.setTaskDrawerState(TaskSwitcherHelpers.GestureStates.Undecided)
                        taskList.setTaskOffsetValue(root.taskSwitcherHelpers.notHomeScreenState ? 0 : root.taskSwitcherHelpers.homeOffsetValue);
                    }
                }
            }
        }

        // returns to the currently centered app. usually used to "back out" of the switcher
        // if accidentally invoked, but can also be used to switch to an adjacent app and then open it
        function returnToApp(): void {
            let newIndex = root.taskSwitcherHelpers.getNearestTaskIndex();
            root.taskSwitcherHelpers.openApp(newIndex);
        }

        // diagonal quick switch gesture logic
        function quickSwitch(): void {
            // should "quick switch" to adjacent app in task switcher, but only if we were in an app before
            let unmodifiedYposition = Math.abs(root.state.touchYPosition)
            let newIndex = root.state.currentTaskIndex;
            let shouldSwitch = false;
            if (root.state.xVelocity > 0) {
                if (root.taskSwitcherHelpers.notHomeScreenState) {
                    // flick to the right, go to the app on the left
                    newIndex = root.state.currentTaskIndex + 1;
                }
                if (newIndex < root.tasksCount) {
                    // switch only if flick doesn't go over end of list
                    shouldSwitch = true;
                }
            } else if (root.state.xVelocity < 0) {
                if (root.taskSwitcherHelpers.notHomeScreenState) {
                    // flick to the left, go to app to the right
                    newIndex = root.state.currentTaskIndex - 1;
                    if (newIndex >= 0) {
                        // switch only if flick doesn't go over end of list
                        shouldSwitch = true;
                    }
                } else {
                    // flick to the left on the home screen, dismiss the gesture
                    root.taskSwitcherHelpers.close();
                    return;
                }
            }
            if (shouldSwitch) {
                if (!root.taskSwitcherHelpers.taskDrawerOpened && unmodifiedYposition < root.taskSwitcherHelpers.openedYPosition) {
                    // if in a app, switch it to the new task when it is under the openedYPosition
                    taskList.setTaskOffsetValue(0, unmodifiedYposition < root.taskSwitcherHelpers.openedYPosition && root.taskSwitcherHelpers.notHomeScreenState);
                    root.taskSwitcherHelpers.openApp(newIndex, Kirigami.Units.longDuration * 4, Easing.OutExpo);
                } else {
                    // if already in the task switcher or above the openedYPosition, only change the focus to the new task
                    root.taskSwitcherHelpers.animateGoToTaskIndex(newIndex);
                    root.taskSwitcherHelpers.open();
                }
            } else {
                // if not switching, just open task switcher
                root.taskSwitcherHelpers.animateGoToTaskIndex(root.state.currentTaskIndex);
                root.taskSwitcherHelpers.open();
            }
        }

        // Logic for deciding how to handle the end of a gesture input
        function onGestureInProgressChanged(): void {
            root.taskSwitcherHelpers.fromButton = false;
            if (root.state.gestureInProgress) {
                root.taskSwitcherHelpers.currentDisplayTask = root.state.currentTaskIndex;
                return;
            }

            if (taskList.count === 0) {
                // dismiss the gesture if the task list is empty
                root.taskSwitcherHelpers.close();
            } if (root.taskSwitcherHelpers.isInTaskScrubMode) {
                // TODO! do we want to handle upwards flick to dismiss in task scrub mode?
                // TODO do we want to show a list of thumbnails in task scrub mode?
                let unmodifiedYposition = Math.abs(root.state.touchYPosition)
                root.backgroundColorOpacity = 1;
                if (root.taskSwitcherHelpers.taskDrawerOpened || unmodifiedYposition > root.taskSwitcherHelpers.undoYThreshold) {
                    root.taskSwitcherHelpers.animateGoToTaskIndex(root.state.currentTaskIndex);
                    root.taskSwitcherHelpers.open();
                    root.taskSwitcherHelpers.isInTaskScrubMode = false;
                } else {
                    root.taskSwitcherHelpers.openApp(root.state.currentTaskIndex);
                }
            } else if (root.taskSwitcherHelpers.gestureState == TaskSwitcherHelpers.GestureStates.Undecided) {
                if (root.taskSwitcherHelpers.taskDrawerOpened) {
                    // if in the task switcher, return to it
                    root.taskSwitcherHelpers.animateGoToTaskIndex(root.state.currentTaskIndex);
                    root.taskSwitcherHelpers.open();
                } else if (root.state.wasInActiveTask) {
                    // if inside a app, return to it
                    returnToApp();
                } else {
                    // else dismiss the gesture
                    root.taskSwitcherHelpers.close();
                }
            } else if (root.taskSwitcherHelpers.gestureState == TaskSwitcherHelpers.GestureStates.HorizontalSwipe) {
                // sideways flick
                root.backgroundColorOpacity = 1;
                quickSwitch();
            } else if (root.taskSwitcherHelpers.gestureState == TaskSwitcherHelpers.GestureStates.TaskSwitcher) {
                // open the task drawer
                root.backgroundColorOpacity = 1;
                root.taskSwitcherHelpers.animateGoToTaskIndex(root.state.currentTaskIndex);
                root.taskSwitcherHelpers.open();
            } else if (root.taskSwitcherHelpers.gestureState == TaskSwitcherHelpers.GestureStates.Home) {
                root.taskSwitcherHelpers.close();
            }
        }

        function onVelocityChanged(): void {

        }

        function onXPositionChanged(): void {
            root.taskSwitcherHelpers.updateTaskIndex();
        }
    }

    // kind of a hack, but this prevents the gesture from immediately activting the task switcher when it is not supposed to
    Timer {
        id: taskSwitchCanLaunchTimer
        interval: 1; running: true; repeat: false
        onTriggered: root.taskSwitcherHelpers.taskSwitchCanLaunch = true;
    }

    function setTaskDrawerState(value: int): void {
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
        outputName: root.targetScreen.name
    }

    // background colour
    Rectangle {
        id: backgroundRect
        anchors.fill: root

        opacity: container.opacity
        color: {
            return Qt.rgba(0, 0, 0, 0.6 * root.taskSwitcherHelpers.closingFactor * root.backgroundColorOpacity);
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
        z: root.taskSwitcherHelpers.taskDrawerOpened && !root.taskSwitcherHelpers.currentlyBeingClosed ? 1 : 0
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
                    if (taskList.count > 1 &&
                        root.state.elapsedTimeSinceStart != -1 &&
                        root.state.elapsedTimeSinceStart < root.state.doubleClickInterval) {
                        root.taskSwitcherHelpers.openApp(1);
                        return;
                    }

                    const currentIndex = root.state.currentTaskIndex;
                    root.taskSwitcherHelpers.openApp(root.state.currentTaskIndex);
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
                taskList.getTaskAt(root.state.currentTaskIndex).closeApp();
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
                width: navRightMargin
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
                height: navBottomMargin
            }
        }
    ]

    // task list
    Item {
        id: container

        // provide shell margins
        anchors.fill: root
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
                let baseOpacity = ((root.tasksCount === 0 && !root.taskSwitcherHelpers.currentlyBeingClosed) ? 0.9 : 0);
                return root.taskSwitcherHelpers.gestureState == TaskSwitcherHelpers.GestureStates.TaskSwitcher ? baseOpacity : 0;
            }
            Behavior on opacity { NumberAnimation { duration: 500 } }

            anchors.centerIn: container

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
            opacity: root.taskSwitcherHelpers.isInTaskScrubMode ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration } }

            anchors.bottom: container.bottom
            anchors.right: container.horizontalCenter
            anchors.bottomMargin: root.taskSwitcherHelpers.openedYPosition * 5 / 8

            anchors.rightMargin: {
                let size = Kirigami.Units.iconSizes.large + Kirigami.Units.largeSpacing * 2;
                let offset = (root.state.currentTaskIndex + 0.5) * size;
                return -offset;
            }
            Behavior on anchors.rightMargin {
                NumberAnimation {
                    duration: root.taskSwitcherHelpers.xAnimDuration;
                    easing.type: root.taskSwitcherHelpers.xAnimEasingType;
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
            opacity: root.taskSwitcherHelpers.isInTaskScrubMode ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            anchors.bottom: container.bottom
            anchors.horizontalCenter: container.horizontalCenter
            anchors.bottomMargin: root.taskSwitcherHelpers.openedYPosition * 1 / 4

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
                width: root.taskSwitcherHelpers.windowWidth / 4
            }

            Kirigami.Icon {
                id: iconScrubFront
                opacity: root.state.currentTaskIndex == root.tasksCount - 1 ? 0.3 : 1
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
            anchors.fill: container

            taskSwitcherState: root.state
            taskSwitcherHelpers: root.taskSwitcherHelpers
            tasksCount: root.tasksCount

            // don't allow FlickContainer to steal from swiping on tasks
            interactive: taskList.taskInteractingCount === 0

            // the item is effectively anchored to the flickable bounds
            TaskList {
                id: taskList
                taskSwitcher: root
                shellTopMargin: root.topMargin
                shellBottomMargin: root.bottomMargin


                x: flickable.contentX
                width: flickable.width
                height: flickable.height
            }

            PlasmaComponents.ToolButton {
                id: closeAllButton
                property bool closeRequested: false
                visible: root.tasksCount !== 0 && !root.taskSwitcherHelpers.isInTaskScrubMode
                enabled: !root.taskSwitcherHelpers.currentlyBeingClosed && !root.state.gestureInProgress

                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

                anchors {
                    bottom: taskList.bottom
                    bottomMargin: (taskList.taskYBase) * 0.75
                    horizontalCenter: taskList.horizontalCenter
                }

                opacity: (root.taskSwitcherHelpers.currentlyBeingClosed || root.state.gestureInProgress || !root.taskSwitcherHelpers.taskDrawerOpened) ? 0.0 : 1.0
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

