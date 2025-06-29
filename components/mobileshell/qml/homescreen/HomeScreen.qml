// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window

import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin

/**
 * The base homescreen component, implementing features that simplify
 * homescreen implementation.
 */

Item {
    id: root

    /**
     * Emitted when an action is triggered to open the homescreen.
     */
    signal homeTriggered()

    /**
     * Emitted when resetting the homescreen position is requested.
     */
    signal resetHomeScreenPosition()

    /**
     * Emitted when moving the homescreen position is requested.
     */
    signal requestRelativeScroll(var pos)

    /**
     * The visual item that is the homescreen.
     */
    property alias contentItem: itemContainer.contentItem

    /**
     * The root PlasmoidItem of the containment this is used into
     */
    property PlasmoidItem plasmoidItem

    /**
     * Margins for the homescreen, taking panels into account.
     */
    property real topMargin
    property real bottomMargin
    property real leftMargin
    property real rightMargin

    /**
     * The opacity value that the homescreen content gets.
     */
    readonly property real contentOpacity: itemContainer.opacity

    function evaluateMargins() {
        topMargin = plasmoidItem.availableScreenRect.y
        bottomMargin = root.height - (plasmoidItem.availableScreenRect.y + plasmoidItem.availableScreenRect.height)
        leftMargin = plasmoidItem.availableScreenRect.x
        rightMargin = root.width - (plasmoidItem.availableScreenRect.x + plasmoidItem.availableScreenRect.width)
    }

    Connections {
        target: Plasmoid

        // avoid binding loops with root.height and root.width changing along with the availableScreenRect
        function onAvailableScreenRectChanged() {
            Qt.callLater(() => root.evaluateMargins());
        }
    }

    //BEGIN API implementation

    Connections {
        target: MobileShellState.ShellDBusClient

        function onOpenHomeScreenRequested() {
            if (windowMaximizedTracker.showingWindow) {
                itemContainer.zoomIn();
            }

            resetHomeScreenPosition();

            WindowPlugin.WindowUtil.unsetAllMinimizedGeometries(root);
            WindowPlugin.WindowUtil.minimizeAll();

            root.homeTriggered();
        }

        function onResetHomeScreenPositionRequested() {
            root.resetHomeScreenPosition();
        }

        function onIsTaskSwitcherVisibleChanged() {
            if (MobileShellState.ShellDBusClient.isTaskSwitcherVisible) {
                itemContainer.zoomOutImmediately();
            } else if (!windowMaximizedTracker.showingWindow) {
                itemContainer.zoomIn();
            }
        }
    }

    //END API implementation

    Component.onCompleted: {
        // determine the margins used
        evaluateMargins();
    }

    WindowPlugin.WindowMaximizedTracker {
        id: windowMaximizedTracker
        screenGeometry: Plasmoid.containment.screenGeometry

        onShowingWindowChanged: {
            itemContainer.evaluateAnimChange();
        }
    }

    // homescreen visual component
    MobileShell.BaseItem {
        id: itemContainer
        anchors.fill: parent

        // animations
        opacity: 0
        property real scaleAmount: 1

        readonly property real zoomScaleOut: 0.8

        function zoomIn() {
            // don't use check animationsEnabled here, so we ensure the scale and opacity is always 1 when disabled
            scaleAnim.to = 1;
            scaleAnim.restart();
            opacityAnim.to = 1;
            opacityAnim.restart();
        }

        function zoomOut() {
            scaleAnim.to = zoomScaleOut;
            scaleAnim.restart();
            opacityAnim.to = 0;
            opacityAnim.restart();
        }

        function zoomOutImmediately() {
            scaleAnim.stop();
            opacityAnim.stop();
            scaleAmount = zoomScaleOut;
            opacity = 0;
        }

        NumberAnimation on opacity {
            id: opacityAnim
            duration: 300
            running: false
        }

        NumberAnimation on scaleAmount {
            id: scaleAnim
            duration: 600
            running: false
            easing.type: Easing.OutExpo
        }

        function evaluateAnimChange() {
            // only animate if homescreen is visible
            if (!windowMaximizedTracker.showingWindow && !MobileShellState.ShellDBusClient.isTaskSwitcherVisible) {
                itemContainer.zoomIn();
            } else {
                itemContainer.zoomOut();
            }
        }

        transform: Scale {
            origin.x: itemContainer.width / 2;
            origin.y: itemContainer.height / 2;
            xScale: itemContainer.scaleAmount
            yScale: itemContainer.scaleAmount
        }
    }

    // App start animation component
    MobileShell.StartupFeedbackWindows {
        id: startupFeedbackWindows
        screen: Plasmoid.screen

        topMargin: root.topMargin
        bottomMargin: root.bottomMargin
        leftMargin: root.leftMargin
        rightMargin: root.rightMargin

        anchors.fill: parent
        visible: false
    }
}
