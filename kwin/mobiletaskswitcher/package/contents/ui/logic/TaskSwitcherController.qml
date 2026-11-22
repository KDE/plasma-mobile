// SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024-2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell.taskswitcherplugin as TaskSwitcherPlugin

import org.kde.kwin 3.0 as KWinComponents
import "../view"

/**
 * What the task switcher does: opening, closing and launching tasks, following the gesture
 * and moving between tasks, with the animations for all of these.
 */
QtObject {
    id: root

    required property TaskSwitcher taskSwitcher
    required property TaskSwitcherGeometry geometry
    required property TaskList taskList
    required property FlickContainer flickable

    readonly property TaskSwitcherPlugin.MobileTaskSwitcherState state: taskSwitcher.state

    readonly property TaskDrawerOffset drawerOffset: TaskDrawerOffset {
        controller: root
    }

    // ~~ state ~~

    // where the task switcher is, and which task is current
    readonly property TaskSwitcherPlugin.TaskNavigator navigator: TaskSwitcherPlugin.TaskNavigator {
        layout: root.geometry.layout
        taskDrawerOpened: root.taskDrawerOpened
        openedYPosition: root.geometry.openedYPosition
        // the current task only follows the scroll position while nothing else moves the list
        tracking: !(root.state.gestureInProgress || root.state.closing) || root.isInTaskScrubMode
    }

    // following the gesture, or animating open
    readonly property bool opening: state.gestureInProgress || openAnim.running

    // whether the switcher is opened or not
    readonly property bool taskDrawerOpened: state.taskDrawerOpened

    // set to true if the taskSwitcher is opened by the navbar button
    property bool openedWithButton: false

    readonly property bool isInTaskScrubMode: gesture.scrubbing

    // interprets the swipe from the screen edge, and decides what will happen when it is completed
    readonly property TaskSwitcherPlugin.TaskSwitcherGesture gesture: TaskSwitcherPlugin.TaskSwitcherGesture {
        startedInApp: root.navigator.startedInApp
        taskDrawerOpened: root.taskDrawerOpened
        tasksCount: root.taskSwitcher.tasksCount

        undoThreshold: root.geometry.undoYThreshold
        openedDistance: root.geometry.openedYPosition
        homeThreshold: root.geometry.heightThreshold
        homeThresholdHysteresis: Kirigami.Units.largeSpacing
        scrubDistance: root.geometry.taskScrubDistance
        scrubMaxEdgeDistance: Kirigami.Units.largeSpacing * 2
    }

    // ~~ lifecycle ~~

    // Prepare for showing the task switcher, either when it is activated or when a gesture starts while it is closing.
    function initialSetup(): void {
        reset();
        startAtOrigin();
        if (!state.gestureInProgress) {
            openFromButton();
        }
    }

    // forget what is left over from the last time the task switcher was shown
    function reset(): void {
        taskSwitcher.resetView();
        cancelAnimations();
        navigator.startedInApp = state.isAppWindow(KWinComponents.Workspace.activeWindow);
        gesture.reset();

        closingFactor = 1;
        navigator.closingScale = 1;

        drawerOffset.easing = Easing.InOutQuart;
        drawerOffset.homeTouchPositionX = 0;
        flickable.resetPosition();
    }

    // start out of view, at the app the task switcher was invoked from, or the most recent one from the home screen
    function startAtOrigin(): void {
        taskSwitcher.setBackgroundColorOpacity(navigator.startedInApp ? 1 : 0, false);
        drawerOffset.set(navigator.startedInApp ? drawerOffset.appValue : drawerOffset.homeValue, true);

        navigator.start(navigator.startedInApp ? Math.max(0, taskSwitcher.tasksModel.indexOf(KWinComponents.Workspace.activeWindow)) : 0);

        taskList.minimizeAll();
    }

    // open the task switcher fully, when invoked with the button rather than a gesture
    function openFromButton(): void {
        openedWithButton = true;
        drawerOffset.set(0, navigator.startedInApp);
        taskSwitcher.backgroundColorOpacity = 1;
        open();
    }

    function open(): void {
        gesture.intent = TaskSwitcherPlugin.TaskSwitcherGesture.Intent.TaskSwitcher;
        openAnim.restart();

        // update the task offset position
        drawerOffset.set(0, false, Easing.OutQuart);
    }

    // open the task drawer, moving to the task
    function openAt(index: int): void {
        animateGoToTaskIndex(index);
        open();
    }

    function close(): void {
        // update the task offset position
        drawerOffset.set(drawerOffset.closingValue, false, Easing.Linear);

        gesture.intent = TaskSwitcherPlugin.TaskSwitcherGesture.Intent.Undecided;
        cancelAnimations();
        navigator.closingScale = navigator.scale;
        state.beginClosing(TaskSwitcherPlugin.MobileTaskSwitcherState.Phase.ClosingToHome);
        closeTransition.restart();
    }

    function hide(): void {
        state.deactivate(false);
    }

    function openApp(index: int, duration = Kirigami.Units.shortDuration): void {
        // cancel any opening animations ongoing
        openAnim.stop();
        cancelAnimations();

        animateGoToTaskIndex(index, duration);
        state.beginClosing(TaskSwitcherPlugin.MobileTaskSwitcherState.Phase.LaunchingTask);
        launchAnim.restart();
        KWinComponents.Workspace.activeWindow = taskList.getTaskAt(index).window;
    }

    // open the current task, or the previous one when invoked twice quickly
    function activateCurrentTask(): void {
        if (taskSwitcher.tasksCount === 0) {
            hide();
            return;
        }

        if (taskSwitcher.tasksCount > 1 && state.isDoubleToggle()) {
            openApp(1);
            return;
        }

        openApp(navigator.currentTaskIndex);
    }

    // cancel all animated moving, as another flick source is taking over
    function cancelAnimations(): void {
        const wasClosing = state.closing;
        closeTransition.stop();
        launchAnim.stop();
        xAnim.stop();
        if (wasClosing) {
            state.cancelClosing();
        }
    }

    // ~~ gesture ~~

    readonly property Connections stateConnections: Connections {
        target: root.state

        function onActivated(): void {
            root.taskSwitcher.tasksModel.refresh();
            root.initialSetup();
        }

        function onTouchMoved(x: real, y: real): void {
            root.gesture.moveTouch(x, y);
            root.followTouch();
        }

        function onGestureInProgressChanged(): void {
            root.openedWithButton = false;
            if (root.state.gestureInProgress) {
                root.gesture.resetTouch();
                root.navigator.beginGesture();
            } else {
                root.finishGesture();
            }
        }
    }

    // follow the touch position of the gesture
    function followTouch(): void {
        if (gesture.shouldScrub()) {
            followScrub();
            return;
        }

        if (state.closing) {
            // if the task switch is still open but playing the close animation
            // setup some values and return to the initial setup so that the user can always navigate with no down time
            navigator.startedInApp = state.launchingTask;
            drawerOffset.set(navigator.startedInApp ? drawerOffset.appValue : drawerOffset.homeValue, true);
            state.restartFromClosing();
            initialSetup();
        } else if (openAnim.running) {
            // a new gesture started while the task drawer was animating open, treat it as opened
            cancelAnimations();
            openAnim.stop();
            state.openingFinished();
        }

        navigator.followTouch(gesture.touchX, gesture.touchY);

        // from the home screen, the task drawer follows the finger sideways, at about a third of its speed
        drawerOffset.homeTouchPositionX = navigator.onHomeScreen ? gesture.touchX * 0.35 : 0;

        // dynamically update the task switcher state based off of the touch position and velocity
        gesture.update();
    }

    // task scrub mode allows scrubbing through a number of tasks with a mostly horizontal motion
    function followScrub(): void {
        drawerOffset.set(0, false, Easing.OutQuart);
        if (!gesture.scrubbing) {
            taskSwitcher.backgroundColorOpacity = 1;
            cancelAnimations();
            open();
        }
        // TODO this makes sense, but makes scrub mode feel a bit weird
        // improve trigger distance logic for task scrub mode to fix
        const newTaskIndex = navigator.scrubTarget(gesture.touchX, geometry.taskScrubDistance);
        if (newTaskIndex != navigator.currentTaskIndex || !gesture.scrubbing) {
            animateGoToTaskIndex(newTaskIndex);
            gesture.enterScrub();
        }
    }

    // Decide what to do now that the gesture has ended
    function finishGesture(): void {
        switch (gesture.endAction()) {
        case TaskSwitcherPlugin.TaskSwitcherGesture.EndAction.Close:
            close();
            break;
        case TaskSwitcherPlugin.TaskSwitcherGesture.EndAction.ReturnToApp:
            returnToApp();
            break;
        case TaskSwitcherPlugin.TaskSwitcherGesture.EndAction.ReturnToSwitcher:
            openAt(navigator.currentTaskIndex);
            break;
        case TaskSwitcherPlugin.TaskSwitcherGesture.EndAction.OpenSwitcher:
            taskSwitcher.backgroundColorOpacity = 1;
            openAt(navigator.currentTaskIndex);
            break;
        case TaskSwitcherPlugin.TaskSwitcherGesture.EndAction.QuickSwitch:
            taskSwitcher.backgroundColorOpacity = 1;
            quickSwitch();
            break;
        case TaskSwitcherPlugin.TaskSwitcherGesture.EndAction.OpenSwitcherFromScrub:
            taskSwitcher.backgroundColorOpacity = 1;
            openAt(navigator.currentTaskIndex);
            gesture.leaveScrub();
            break;
        case TaskSwitcherPlugin.TaskSwitcherGesture.EndAction.LaunchScrubbedTask:
            taskSwitcher.backgroundColorOpacity = 1;
            openApp(navigator.currentTaskIndex);
            break;
        }
    }

    // Returns to the currently centered app
    function returnToApp(): void {
        openApp(navigator.nearestTask());
    }

    // Diagonal quick switch gesture: switch to the adjacent app
    function quickSwitch(): void {
        // flicking to the right goes to the app on the left (the next one), and the other way around
        const direction = Math.sign(gesture.xVelocity);
        if (direction < 0 && navigator.onHomeScreen) {
            // flick to the left on the home screen, dismiss the gesture
            close();
            return;
        }

        const newIndex = navigator.quickSwitchTarget(direction);
        if (newIndex < 0) {
            // no app in that direction, just open the task switcher
            openAt(navigator.currentTaskIndex);
        } else if (!taskDrawerOpened && Math.abs(gesture.touchY) < geometry.openedYPosition) {
            // still in an app, switch to the new one
            drawerOffset.set(0, !navigator.onHomeScreen);
            openApp(newIndex, Kirigami.Units.longDuration * 4);
        } else {
            // in the task switcher, only move to the new task
            openAt(newIndex);
        }
    }

    // react to the requests from the gesture while it is in progress
    readonly property Connections gestureConnections: Connections {
        target: root.gesture

        function onBackgroundOpacityRequested(opacity: real): void {
            root.taskSwitcher.backgroundColorOpacity = opacity;
        }

        function onVibrationRequested(): void {
            root.taskSwitcher.vibrate();
        }

        function onDrawerPositionRequested(position: int, immediate: bool): void {
            root.drawerOffset.setPosition(position, immediate);
        }
    }

    // ~~ moving between tasks ~~

    // made as variables to keep x anim in task list and task scrub icon list in sync
    property int xAnimDuration: Kirigami.Units.longDuration * 2
    property int xAnimEasingType: Easing.OutExpo

    // go to the task index, animated
    function animateGoToTaskIndex(index: int, duration = Kirigami.Units.longDuration * 2, easing = Easing.OutExpo): void {
        xAnimDuration = duration;
        xAnimEasingType = easing;
        xAnim.to = geometry.layout.scrollPositionForTask(index) - (gesture.intent === TaskSwitcherPlugin.TaskSwitcherGesture.Intent.HorizontalSwipe && !state.gestureInProgress && !navigator.onHomeScreen ? geometry.taskSpacing / 2 : 0);
        xAnim.restart();
    }

    // FlickContainer doesn't flick, so after dragging the list it snaps to the next task in the direction it was moving
    function snapToNearestTaskWorkaround(movingRight: bool): void {
        animateGoToTaskIndex(navigator.snapTarget(movingRight));
    }

    readonly property Connections tasksModelConnections: Connections {
        target: root.taskSwitcher.tasksModel

        function onRowsRemoved(parent: var, first: int, last: int): void {
            root.handleTasksRemoved(first, last);
        }
    }

    // keep the current task in view when the tasks first..last are removed
    function handleTasksRemoved(first: int, last: int): void {
        const count = taskSwitcher.tasksModel.rowCount();
        if (count === 0) {
            hide();
            return;
        }

        if (navigator.removeTasks(first, last, count)) {
            // at the same speed as the tasks moving into the place of the removed ones, so that the
            // current task appears not to move
            animateGoToTaskIndex(navigator.currentTaskIndex, Kirigami.Units.longDuration, Easing.InOutQuad);
        }
    }

    // ~~ animations ~~

    // fades out the task switcher when closing
    property real closingFactor: 1

    readonly property NumberAnimation xAnim: NumberAnimation {
        target: root.navigator
        property: "xPosition"
        duration: root.xAnimDuration
        easing.type: root.xAnimEasingType
    }

    readonly property NumberAnimation openAnim: NumberAnimation {
        target: root.navigator
        property: "yPosition"
        to: root.geometry.openedYPosition
        duration: 250
        easing.type: Easing.OutQuart

        onFinished: {
            if (!root.isInTaskScrubMode) {
                root.state.openingFinished();
            }
        }
    }

    // Closing to the home screen: the task list moves away, shrinks and fades out
    readonly property ParallelAnimation closeTransition: ParallelAnimation {
        // TODO: This animation should ideally be replaced by some speed tracking to track finger movement better.
        // Until then InBack at least pretends to go in the finger move direction
        NumberAnimation {
            target: root.navigator
            property: "yPosition"
            to: 0
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InBack
        }
        NumberAnimation {
            target: root.navigator
            property: "closingScale"
            to: 0.1
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: root
            property: "closingFactor"
            to: 0
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InQuad
        }

        onFinished: root.state.closingFinished()
        onStopped: root.navigator.closingScale = 1
    }

    // Launching a task: the task list zooms into the task
    readonly property NumberAnimation launchAnim: NumberAnimation {
        target: root.navigator
        property: "yPosition"
        to: 0
        duration: 300
        easing.type: Easing.OutQuint
        onFinished: root.state.closingFinished()
    }
}
