// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick

import org.kde.plasma.private.mobileshell.taskswitcherplugin as TaskSwitcherPlugin
import "../view"

/**
 * How the grid moves as a whole while the task switcher opens and closes, on top of the layout.
 */
QtObject {
    id: root

    required property bool active

    required property TaskList taskList

    readonly property TaskSwitcherGeometry geometry: taskList.geometry
    readonly property TaskSwitcherPlugin.TaskNavigator navigator: taskList.navigator
    readonly property TaskDrawerOffset taskDrawerOffset: taskList.controller.drawerOffset

    // ~~ output ~~

    readonly property real xOffset: (active && !navigator.startedInApp) ? entranceOffset : 0
    readonly property real yOffset: active ? -taskList.currentTaskPlacement.rowOffset * (1 - navigator.openProgress) : 0

    // ~~ entrance from the home screen ~~

    property real drawerOffset: taskDrawerOffset.value
    Behavior on drawerOffset {
        enabled: root.active
        NumberAnimation {
            duration: root.taskDrawerOffset.durationLeft
            easing.type: root.taskDrawerOffset.easing
            easing.overshoot: 0.85
        }
    }

    // the right edge of the first column on screen (the task list is scaled around its center)
    readonly property real rightEdge: geometry.windowWidth / 2 + (geometry.taskWidth / 2 - geometry.layout.displayedScrollPosition) * navigator.scale

    readonly property real peekWidth: geometry.taskWidth * navigator.scale * 0.4

    readonly property real entranceOffset: {
        const peek = taskDrawerOffset.peekValue;
        const home = taskDrawerOffset.homeValue;
        const peekShift = peekWidth - rightEdge;
        const hiddenShift = -geometry.taskSpacing - rightEdge;
        if (drawerOffset <= peek) {
            return peekShift * drawerOffset / peek;
        }
        return peekShift + (hiddenShift - peekShift) * Math.min(1.5, (drawerOffset - peek) / (home - peek));
    }
}
