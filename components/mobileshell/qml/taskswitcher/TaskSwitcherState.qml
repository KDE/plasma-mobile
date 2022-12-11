/*
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15

import org.kde.plasma.core 2.1 as PlasmaCore

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState

/**
 * State object for the task switcher.
 */
QtObject {
    id: root
    
    // TaskSwitcher item component
    // We assume that the taskSwitcher the size of the entire screen.
    required property var taskSwitcher
    
    
    // ~~ positioning ~~
    
    // Position of the list view:
    // 
    // xPosition:
    // We start at 0, which is the position at which the first task in the task switcher is centered on the screen.
    // Decreasing xPosition results in the task switcher moving forward (to the second task, third task, etc), being the layout direction Right to Left.
    //
    // yPosition:
    // 0 - Start of swipe up gesture, if window was showing, the thumbnail is the size of it
    // Increasing yPosition results in the task switcher moving up (and thumbnails shrinking)
    property real xPosition: 0
    property real yPosition: 0
    
    // direction of the movement
    property bool movingRight: false
    property bool movingUp: false
    
    // used for calculating movement direction
    property real oldXPosition: 0
    property real oldYPosition: 0
    onXPositionChanged: {
        movingRight = xPosition < oldXPosition;
        oldXPosition = xPosition;
    }
    onYPositionChanged: {
        movingUp = yPosition > oldYPosition;
        oldYPosition = yPosition;
    }
    
    // yPosition when the task switcher is completely open
    readonly property real openedYPosition: (taskSwitcher.height - taskHeight) / 2
    
    // ~~ active state ~~
    
    // whether the user was in an active task before the task switcher was opened
    property bool wasInActiveTask: false
    
    // whether we are in a swipe up gesture to open the task switcher
    property bool currentlyBeingOpened: false
    
    // whether the task switcher is being closed: an animation is running
    property bool currentlyBeingClosed: false
    
    // whether we are in a swipe left/right gesture to walk through tasks
    property bool scrollingTasks: false
    
    readonly property int currentTaskIndex: {
        let candidateIndex = Math.round(-xPosition / (taskSpacing + taskWidth));
        return Math.max(0, Math.min(taskSwitcher.tasksCount - 1, candidateIndex));
    }
    
    // ~~ measurement constants ~~
    
    // dimensions of a real window on the screen
    readonly property real windowHeight: taskSwitcher.height - taskSwitcher.topMargin - taskSwitcher.bottomMargin
    readonly property real windowWidth: taskSwitcher.width - taskSwitcher.leftMargin - taskSwitcher.rightMargin
    
    // dimensions of the task previews
    readonly property real previewHeight: windowHeight * scalingFactor
    readonly property real previewWidth: windowWidth * scalingFactor
    readonly property real taskHeight: previewHeight + taskHeaderHeight
    readonly property real taskWidth: previewWidth
    
    // spacing between each task preview
    readonly property real taskSpacing: PlasmaCore.Units.largeSpacing
    
    // height of the task preview header
    readonly property real taskHeaderHeight: PlasmaCore.Units.gridUnit * 2 + PlasmaCore.Units.smallSpacing * 2
    
    // the scaling factor of the window preview compared to the actual window
    // we need to ensure that window previews always fit on screen
    readonly property real scalingFactor: {
        let candidateFactor = 0.6;
        let candidateTaskHeight = windowHeight * candidateFactor + taskHeaderHeight;
        let candidateTaskWidth = windowWidth * candidateFactor;
        
        let candidateHeight = (candidateTaskWidth / windowWidth) * windowHeight;
        if (candidateHeight > windowHeight) {
            return candidateTaskHeight / windowHeight;
        } else {
            return candidateTaskWidth / windowWidth;
        }
    }
    
    // scale of the task list (based on the progress of the swipe up gesture)
    readonly property real currentScale: {
        let maxScale = 1 / scalingFactor;
        let subtract = (maxScale - 1) * (yPosition / openedYPosition);
        let finalScale = Math.max(0, Math.min(maxScale, maxScale - subtract));
        
        // animate scale only if we are *not* opening from the homescreen
        if ((wasInActiveTask || !currentlyBeingOpened) && !scrollingTasks) {
            return finalScale;
        }
        return scrollingTasks ? maxScale : 1;
    }
    
    // ~~ signals and functions ~~
    
    // cancel all animated moving, as another flick source is taking over
    signal cancelAnimations()
    onCancelAnimations: {
        openAnim.stop();
        openAppAnim.stop();
        closeAnim.stop();
        xAnim.stop();
    }
    
    function open() {
        openAnim.restart();
    }
    
    function close() {
        closeAnim.restart();
    }
    
    function openApp(index) {
        animateGoToTaskIndex(index, PlasmaCore.Units.shortDuration);
        openAppAnim.restart();
    }
    
    // get the xPosition where the task will be centered on the screen
    function xPositionFromTaskIndex(index) {
        return -index * (taskWidth + taskSpacing);
    }
    
    // instantly go to the task index
    function goToTaskIndex(index) {
        xPosition = xPositionFromTaskIndex(index);
    }
    
    // go to the task index, animated
    function animateGoToTaskIndex(index, duration) {
        xAnim.duration = duration;
        xAnim.to = xPositionFromTaskIndex(index);
        xAnim.restart();
    }
    
    // called after a user finishes an interaction (ex. lets go of the screen)
    function updateState() {
        cancelAnimations();

        // update vertical state
        if ((movingUp || root.yPosition >= openedYPosition) && !scrollingTasks) {
            // open task switcher and stay
            openAnim.restart();
        } else {
            // close task switcher and return to app
            closeAnim.restart();
        }
        
        // update horizontal state
        let duration = PlasmaCore.Units.longDuration * 2;
        if (currentlyBeingOpened) {
            animateGoToTaskIndex(currentTaskIndex, duration);
        } else {
            let currentTaskIndexPosition = xPositionFromTaskIndex(currentTaskIndex);
            if (xPosition > currentTaskIndexPosition) {
                if (movingRight) {
                    animateGoToTaskIndex(currentTaskIndex, duration);
                } else {
                    animateGoToTaskIndex(Math.max(0, currentTaskIndex - 1), duration);
                }
            } else {
                if (movingRight) {
                    animateGoToTaskIndex(Math.min(taskSwitcher.tasksCount - 1, currentTaskIndex + 1), duration);
                } else {
                    animateGoToTaskIndex(currentTaskIndex, duration);
                }
            }
        }
    }
    
    // ~~ property animators ~~
    
    property var xAnim: NumberAnimation {
        target: root
        property: "xPosition"
        easing.type: Easing.OutBack
    }
    
    property var openAnim: NumberAnimation { 
        target: root
        property: "yPosition"
        to: openedYPosition
        duration: MobileShell.MobileShellSettings.animationsEnabled ? 300 : 0
        easing.type: Easing.OutBack     
        
        onFinished: {
            root.currentlyBeingOpened = false;
        }
    }
    
    property var closeAnim: NumberAnimation { 
        target: root
        property: "yPosition"
        to: 0
        duration: MobileShell.MobileShellSettings.animationsEnabled ? PlasmaCore.Units.longDuration : 0
        easing.type: Easing.InOutQuad
        
        onFinished: {
            root.currentlyBeingOpened = false;
            scrollingTasks = false;
            taskSwitcher.instantHide();

            if (root.wasInActiveTask) {
                taskSwitcher.setSingleActiveWindow(root.currentTaskIndex);
            }
        }
    }
    
    property var openAppAnim: NumberAnimation { 
        target: root 
        property: "yPosition"
        to: 0
        duration: MobileShell.MobileShellSettings.animationsEnabled ? 300 : 0
        easing.type: Easing.OutQuint
        
        onStarted: root.currentlyBeingClosed = true
        
        onFinished: {
            root.currentlyBeingClosed = false;
            root.currentlyBeingOpened = false;
            taskSwitcher.setSingleActiveWindow(root.currentTaskIndex);
            taskSwitcher.instantHide();
        }
    }
}
