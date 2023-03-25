/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Window

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager

import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.windowplugin as WindowPlugin

import "../components" as Components

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
     * Whether a component is being shown on top of the homescreen within the same
     * window.
     */
    readonly property bool overlayShown: startupFeedback.visible
    
    /**
     * Margins for the homescreen, taking panels into account.
     */
    property real topMargin
    property real bottomMargin
    property real leftMargin
    property real rightMargin

    function evaluateMargins() {
        topMargin = plasmoid.availableScreenRect.y
        // add a specific check for the nav panel for now, since the gesture mode still technically has height
        bottomMargin = ShellSettings.Settings.navigationPanelEnabled ? root.height - (plasmoid.availableScreenRect.y + plasmoid.availableScreenRect.height) : 0;
        leftMargin = plasmoid.availableScreenRect.x
        rightMargin = root.width - (plasmoid.availableScreenRect.x + plasmoid.availableScreenRect.width)
    }

    Connections {
        target: plasmoid

        // avoid binding loops with root.height and root.width changing along with the availableScreenRect
        function onAvailableScreenRectChanged() {
            Qt.callLater(() => root.evaluateMargins());
        }
    }

    //BEGIN API implementation

    Connections {
        target: MobileShellState.ShellDBusClient
        
        function onOpenHomeScreenRequested() {
            if (WindowPlugin.WindowMaximizedTracker.showingWindow) {
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
        
        function onOpenAppLaunchAnimationRequested(splashIcon, title, x, y, sourceIconSize) {
            startupFeedback.open(splashIcon, title, x, y, sourceIconSize);
        }
        
        function onCloseAppLaunchAnimationRequested() {
            startupFeedback.close();
        }
    }

//END API implementation

    Connections {
        target: MobileShellState.LockscreenDBusClient

        function onLockscreenActiveChanged() {
            // run zoom animation after login
            if (!MobileShellState.LockscreenDBusClient.lockscreenActive) {
                itemContainer.opacity = 0;
                itemContainer.zoomScale = 0.8;
                itemContainer.zoomIn();
            }
        }
    }

    Component.onCompleted: {
        // determine the margins used
        evaluateMargins();
    }
    
    // homescreen visual component
    Components.BaseItem {
        id: itemContainer
        anchors.fill: parent
        
        // animations
        opacity: 0
        property real zoomScale: 0.8
        
        Component.onCompleted: zoomIn()
        
        function zoomIn() {
            // don't use check animationsEnabled here, so we ensure the scale and opacity is always 1 when disabled
            scaleAnim.to = 1;
            scaleAnim.restart();
            opacityAnim.to = 1;
            opacityAnim.restart();
        }
        function zoomOut() {
            if (ShellSettings.Settings.animationsEnabled) {
                scaleAnim.to = 0.8;
                scaleAnim.restart();
                opacityAnim.to = 0;
                opacityAnim.restart();
            }
        }
        
        NumberAnimation on opacity {
            id: opacityAnim
            duration: ShellSettings.Settings.animationsEnabled ? 300 : 0
            running: false
        }
        
        NumberAnimation on zoomScale {
            id: scaleAnim
            duration: ShellSettings.Settings.animationsEnabled ? 600 : 0
            running: false
            easing.type: Easing.OutExpo
        }
        
        function evaluateAnimChange() {
            // only animate if homescreen is visible
            if (!WindowPlugin.WindowMaximizedTracker.showingWindow || WindowPlugin.WindowUtil.activeWindowIsShell) {
                itemContainer.zoomIn();
            } else {
                itemContainer.zoomOut();
            }
        }
        
        Connections {
            target: WindowPlugin.WindowUtil

            function onActiveWindowIsShellChanged() {
                itemContainer.evaluateAnimChange();
            }
        }

        Connections {
            target: WindowPlugin.WindowMaximizedTracker

            function onShowingWindowChanged() {
                itemContainer.evaluateAnimChange();
            }
        }
        
        transform: Scale { 
            origin.x: itemContainer.width / 2; 
            origin.y: itemContainer.height / 2; 
            xScale: itemContainer.zoomScale
            yScale: itemContainer.zoomScale
        }
    }
    
    // start app animation component
    Components.StartupFeedback {
        id: startupFeedback
        z: 999999
        anchors.fill: parent
    }
}
