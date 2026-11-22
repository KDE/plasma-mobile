// SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
// SPDX-FileCopyrightText: 2024-2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell.taskswitcherplugin as TaskSwitcherPlugin

/**
 * How far the task drawer is moved out of view, while the task switcher opens and closes.
 */
QtObject {
    id: root

    required property TaskSwitcherController controller
    readonly property TaskSwitcherGeometry geometry: controller.geometry
    readonly property TaskSwitcherPlugin.TaskNavigator navigator: controller.navigator

    // the target value, set through set()
    property real value: 0

    // ~~ positions ~~

    // in place
    readonly property real openedValue: 0
    // peeking in, when invoked from the home screen
    readonly property real peekValue: 1.85
    // out of view, when invoked from the home screen
    readonly property real homeValue: 2.6
    // out of view, when invoked from an app
    readonly property real appValue: 1.5
    // when closing: a bit further than out of view, so that the tasks keep moving while they fade out
    readonly property real closingValue: homeValue + 0.25

    // set the position the gesture asked for
    function setPosition(position: int, immediately: bool): void {
        switch (position) {
        case TaskSwitcherPlugin.TaskSwitcherGesture.DrawerPosition.Peek:
            set(peekValue, immediately);
            break;
        case TaskSwitcherPlugin.TaskSwitcherGesture.DrawerPosition.OffscreenHome:
            set(homeValue, immediately);
            break;
        case TaskSwitcherPlugin.TaskSwitcherGesture.DrawerPosition.OffscreenTask:
            set(appValue, immediately);
            break;
        default:
            set(openedValue, immediately);
            break;
        }
    }

    // when opened from the home screen: the touch x position, so that the task drawer follows the finger sideways
    property real homeTouchPositionX: 0

    // ~~ animation timing ~~

    property int easing: Easing.InOutQuart

    // the next change is instant, set through set()
    property bool immediate: true

    // the durations for the tasks on the left and right of the current task
    readonly property real durationLeft: immediate ? 0 : dynamicDuration(true)
    readonly property real durationRight: immediate ? 0 : dynamicDuration(false)

    // the touch x position normalized between 0 and 1, 0.5 on the home screen
    readonly property real touchPosition: {
        if (navigator.onHomeScreen) {
            return 0.5;
        }
        // since the touch position starts at 0, we add half the window width and then divide it by the full width to normalize it
        const value = (controller.gesture.touchX + (geometry.windowWidth / 2)) / geometry.windowWidth;
        return Math.min(1, Math.max(0, value));
    }

    // tasks on the side the finger is on move more slowly
    function dynamicDuration(left: bool): int {
        let duration = Kirigami.Units.longDuration * 1.75;
        // use the standard duration while closing, and when the touch position is not relevant
        if (!controller.state.closingToHome && !navigator.onHomeScreen && controller.gesture.intent !== TaskSwitcherPlugin.TaskSwitcherGesture.Intent.HorizontalSwipe && !controller.isInTaskScrubMode) {
            duration = duration * ((left ? touchPosition : (1 - touchPosition)) + 1);
        }
        return duration;
    }

    // Set the value, animated unless immediately. By default it speeds up and slows down,
    // except when the task drawer comes into view from the home screen or from out of view.
    function set(newValue: real, immediately = false, newEasing = ((!navigator.onHomeScreen || (newValue != 0)) && (value != appValue)) ? Easing.InOutQuart : Easing.OutQuart): void {
        if (value == newValue && immediately) {
            // change it anyway, so that a running animation towards the value stops
            value = newValue + 1;
        }
        immediate = immediately;
        easing = newEasing;
        value = newValue;
    }
}
