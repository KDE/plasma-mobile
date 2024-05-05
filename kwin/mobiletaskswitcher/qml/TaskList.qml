// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.kwin 3.0 as KWinComponents

MouseArea {
    id: root
    readonly property int count: repeater.count

    required property real shellTopMargin
    required property real shellBottomMargin

    required property var taskSwitcher
    readonly property var taskSwitcherState: taskSwitcher.state
    readonly property var taskSwitcherHelpers: taskSwitcher.taskSwitcherHelpers

    property int taskInteractingCount: 0

    // account for system header and footer offset (center the preview image)
    readonly property real taskY: {
        let headerHeight = shellTopMargin;
        let footerHeight = shellBottomMargin;
        let diff = headerHeight - footerHeight;

        let baseY = (taskSwitcher.height / 2) - (taskSwitcherHelpers.taskHeight / 2) - (taskSwitcherHelpers.taskHeaderHeight / 2);

        return baseY + diff / 2 - shellTopMargin - trackFingerYOffset;
    }
    readonly property real trackFingerYOffset: taskSwitcherHelpers.isScaleClamped ? taskSwitcherState.yPosition - taskSwitcherHelpers.openedYPosition : 0

    function getTaskAt(index) {
        return repeater.itemAt(index);
    }

    function closeAll() {
        for (let i = 0; i < repeater.count; i++) {
            repeater.itemAt(i).closeApp();
        }
    }

    function minimizeAll() {
        for (let i = 0; i < repeater.count; i++) {
            let item = repeater.itemAt(i);

            // minimize window
            if (!item.window.minimized) {
                item.minimizeApp();
            }
        }
    }

    function jumpToFirstVisibleWindow() {
        for (let i = 0; i < repeater.count; i++) {
            let item = repeater.itemAt(i);

            if (!item.window.minimized) {
                taskSwitcherHelpers.goToTaskIndex(i);
                break;
            }
        }
    }

    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: taskSwitcherHelpers.currentScale
        yScale: taskSwitcherHelpers.currentScale
    }

    onClicked: {
        // if tapped on the background, then hide
        taskSwitcher.hide();
    }

    onPressedChanged: {
        if (!taskSwitcherState.currentlyBeingOpened && pressed) {
            // ensure animations aren't running when finger is pressed
            taskSwitcherHelpers.cancelAnimations();
        }
    }

    Repeater {
        id: repeater
        model: taskSwitcher.tasksModel

        // left margin from root edge such that the task is centered
        readonly property real leftMargin: (root.width / 2) - (taskSwitcherHelpers.taskWidth / 2)

        delegate: Task {
            id: task
            readonly property int currentIndex: model.index

            // this is the x-position with respect to the list
            property real listX: taskSwitcherHelpers.xPositionFromTaskIndex(currentIndex);
            Behavior on listX {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }

            // this is the actual displayed x-position on screen
            x: listX + repeater.leftMargin - taskSwitcherState.xPosition
            y: root.taskY

            // ensure current task is above others
            z: taskSwitcherState.currentTaskIndex === currentIndex ? 1 : 0

            // only show header once task switcher is opened
            showHeader: !taskSwitcherState.gestureInProgress && !taskSwitcherHelpers.currentlyBeingClosed && !taskSwitcherHelpers.isInTaskScrubMode

            // darken effect as task gets away from the centre of the screen
            darken: {
                const distFromCentreProgress = Math.abs(x - repeater.leftMargin) / taskSwitcherHelpers.taskWidth;
                const upperBoundAdjust = Math.min(0.5, distFromCentreProgress) - 0.2;
                return Math.max(0, upperBoundAdjust);
            }

            // update count of tasks being interacted with, so we know whether we are in a swipe up action
            onInteractingActiveChanged: {
                let offset = interactingActive ? 1 : -1;
                taskInteractingCount = Math.max(0, taskInteractingCount + offset);
            }

            width: taskSwitcherHelpers.taskWidth
            height: taskSwitcherHelpers.taskHeight
            previewWidth: taskSwitcherHelpers.previewWidth
            previewHeight: taskSwitcherHelpers.previewHeight

            taskSwitcher: root.taskSwitcher
        }
    }
}
