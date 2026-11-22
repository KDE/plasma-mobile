// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024-2025 Luis Büchi <luis.buechi@kdemail.net>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell.taskswitcherplugin as TaskSwitcherPlugin
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import "../view"

/**
 * Sizes and positions of the task switcher.
 */
QtObject {
    id: root

    // We assume that the taskSwitcher is the size of the entire screen.
    required property TaskSwitcher taskSwitcher

    property TaskSwitcherPlugin.TaskLayout layout: carouselLayout

    // ~~ screen ~~

    // dimensions of a real window on the screen
    readonly property real windowHeight: taskSwitcher.height - taskSwitcher.topMargin - taskSwitcher.bottomMargin
    readonly property real windowWidth: taskSwitcher.width - taskSwitcher.leftMargin - taskSwitcher.rightMargin

    // ~~ layouts ~~

    readonly property TaskSwitcherPlugin.CarouselTaskLayout carouselLayout: TaskSwitcherPlugin.CarouselTaskLayout {
        count: root.taskSwitcher.tasksCount
        windowSize: Qt.size(root.windowWidth, root.windowHeight)
        spacing: root.taskSpacing
        headerHeight: root.taskHeaderHeight
    }

    // The grid is used on large screens (tablets)
    readonly property TaskSwitcherPlugin.GridTaskLayout gridLayout: TaskSwitcherPlugin.GridTaskLayout {
        count: root.taskSwitcher.tasksCount
        windowSize: Qt.size(root.windowWidth, root.windowHeight)
        spacing: root.taskSpacing
        headerHeight: root.taskHeaderHeight
    }

    readonly property bool useGrid: {
        switch (ShellSettings.Settings.taskSwitcherLayout) {
        case ShellSettings.Settings.TaskSwitcherLayoutCarousel:
            return false;
        case ShellSettings.Settings.TaskSwitcherLayoutGrid:
            return true;
        default:
            return windowWidth >= gridMinimumWidth && windowHeight >= gridMinimumHeight;
        }
    }
    readonly property real gridMinimumWidth: Kirigami.Units.gridUnit * 36
    readonly property real gridMinimumHeight: Kirigami.Units.gridUnit * 30

    readonly property bool isGridLayout: layout === gridLayout

    // ~~ tasks ~~

    // dimensions of the task previews
    readonly property real taskWidth: layout.taskWidth
    readonly property real taskHeight: layout.taskHeight
    readonly property real previewWidth: taskWidth
    readonly property real previewHeight: taskHeight - taskHeaderHeight

    // spacing between each task preview
    readonly property real taskSpacing: Kirigami.Units.gridUnit

    // height of the task preview header
    readonly property real taskHeaderHeight: Kirigami.Units.gridUnit * 2 + Kirigami.Units.smallSpacing * 2

    // the y position of a vertically centered task, centering the preview between the shell panels
    readonly property real restingTaskY: {
        const panelsDiff = taskSwitcher.topMargin - taskSwitcher.bottomMargin;
        const baseY = (taskSwitcher.height / 2) - (taskHeight / 2) - (taskHeaderHeight / 2);
        return baseY + panelsDiff / 2 - taskSwitcher.topMargin;
    }

    // the window area on the screen
    readonly property rect windowRect: Qt.rect(taskSwitcher.leftMargin, taskSwitcher.topMargin, windowWidth, windowHeight)

    // ~~ vertical position (yPosition) and thresholds ~~

    // yPosition when the task switcher is completely open
    readonly property real openedYPosition: Math.round((taskSwitcher.height - taskHeight) / 2)

    // yPosition threshold below which opening the task switcher should be undone and returned to the previously active task
    readonly property real undoYThreshold: openedYPosition / 2

    // the height threshold where if the yPosition is above this value the task switch will return home
    readonly property real heightThreshold: windowHeight * 0.55

    readonly property real scrubModeBottomMargin: Math.round(openedYPosition * 5 / 8)
    // how far the tasks move up in scrub mode, to make space for the scrub icons
    readonly property real scrubModeOverrun: Math.max(0, scrubModeBottomMargin + Kirigami.Units.iconSizes.huge + Kirigami.Units.smallSpacing - openedYPosition)

    // horizontal distance to scrub through one task, so that 6 tasks can be scrubbed through in half the window width
    readonly property real taskScrubDistance: windowWidth / (2 * 6)
}
