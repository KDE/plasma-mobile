// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Flickable {
    id: root

    required property var taskSwitcherState

    // we use flickable solely for capturing flicks, not positioning elements
    contentWidth: width * tasksCount
    contentHeight: height
    contentX: startContentX

    readonly property real startContentX: 0

    // update position from horizontal flickable movement
    property real oldContentX
    onContentXChanged: {
        taskSwitcherState.xPosition += contentX - oldContentX;
        oldContentX = contentX;
    }

    onMovementStarted: taskSwitcherState.cancelAnimations();
    onMovementEnded: {
        resetPosition();
        taskSwitcherState.updateState();
    }

    onFlickStarted: {
        root.cancelFlick();
    }
    onFlickEnded: {
        resetPosition();
        taskSwitcherState.updateState();
    }

    onDraggingChanged: {
        if (!dragging) {
            resetPosition();
            taskSwitcherState.updateState();
        } else {
            taskSwitcherState.cancelAnimations();
        }
    }

    function resetPosition() {
        oldContentX = startContentX;
        contentX = startContentX;
    }
}
