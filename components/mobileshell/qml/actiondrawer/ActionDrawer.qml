/*
 *   SPDX-FileCopyrightText: 2014 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell

import "../components" as Components

/**
 * Swipe top left - minimized quick settings, fully shown notifications list
 * Swipe top right - full quick settings, minimized notifications list
 * Swiping up and down on notifications list toggle minimized/maximized
 * Swiping up and down on panel hides and shows the panel
 */

NanoShell.FullScreenOverlay {
    id: window
    
    /**
     * The model for the notification widget.
     */
    property var notificationModel
    
    /**
     * The notification settings object to be used in the notification widget.
     */
    property var notificationSettings

    /**
     * The amount of pixels moved by touch/mouse in the process of opening/closing the panel.
     */
    property real offset: 0
    
    /**
     * Whether the panel is being dragged.
     */
    property bool dragging: false
    
    /**
     * Whether the panel is open after touch/mouse release from the first opening swipe.
     */
    property bool opened: false

    /**
     * Direction the panel is currently moving in.
     */
    property int direction: Components.Direction.None
    
    property int mode: (height > width && width <= largePortraitThreshold) ? ActionDrawer.Portrait : ActionDrawer.Landscape
    
    /**
     * At some point, even if the screen is technically portrait, if we have a ton of width it'd be best to just show the landscape mode.
     */
    readonly property real largePortraitThreshold: PlasmaCore.Units.gridUnit * 35
    
    enum Mode {
        Portrait = 0,
        Landscape
    }
    
    width: Screen.width
    height: Screen.height
    
    color: "transparent"

    onOpenedChanged: {
        if (opened) flickable.focus = true;
    }
    onActiveChanged: {
        if (!active) {
            close();
        }
    }
    
    property real oldOffset
    onOffsetChanged: {
        if (offset < 0) {
            offset = 0;
        }
        window.direction = (oldOffset === offset) 
                            ? Components.Direction.None 
                            : (offset > oldOffset ? Components.Direction.Down : Components.Direction.Up);
            
        oldOffset = offset;
        
        // close panel immediately after panel is not shown, and the flickable is not being dragged
        if (opened && window.offset <= 0 && !flickable.dragging && !closeAnim.running && !openAnim.running) {
            window.updateState();
            focus = false;
        }
    }

    function cancelAnimations() {
        closeAnim.stop();
        openAnim.stop();
    }
    function open() {
        cancelAnimations();
        openAnim.restart();
    }
    function closeImmediately() {
        cancelAnimations();
        offset = 0;
        closeAnim.finished();
    }
    function close() {
        cancelAnimations();
        closeAnim.restart();
    }
    function expand() {
        cancelAnimations();
        expandAnim.restart();
    }
    function updateState() {
        cancelAnimations();
        let openThreshold = PlasmaCore.Units.gridUnit;
        
        if (window.offset <= 0) {
            // close immediately, so that we don't have to wait PlasmaCore.Units.longDuration 
            window.visible = false;
            close();
        } else if (window.direction === Components.Direction.None || !window.opened) {
            if (window.offset < openThreshold) {
                close();
            } else {
                open();
            }
        } else if (window.offset > contentContainerLoader.maximizedQuickSettingsOffset) {
            expand();
        } else if (window.offset > contentContainerLoader.minimizedQuickSettingsOffset) {
            if (window.direction === Components.Direction.Down) {
                expand();
            } else {
                open();
            }
        } else if (window.direction === Components.Direction.Down) {
            open();
        } else {
            close();
        }
    }
    Timer {
        id: updateStateTimer
        interval: 0
        onTriggered: updateState()
    }

    PropertyAnimation on offset {
        id: closeAnim
        duration: PlasmaCore.Units.longDuration
        easing.type: Easing.InOutQuad
        to: 0
        onFinished: {
            window.visible = false;
            window.opened = false;
        }
    }
    PropertyAnimation on offset {
        id: openAnim
        duration: PlasmaCore.Units.longDuration
        easing.type: Easing.InOutQuad
        to: contentContainerLoader.minimizedQuickSettingsOffset
        onFinished: window.opened = true
    }
    PropertyAnimation on offset {
        id: expandAnim
        duration: PlasmaCore.Units.longDuration
        easing.type: Easing.InOutQuad
        to: contentContainerLoader.maximizedQuickSettingsOffset
        onFinished: window.opened = true;
    }
    
    Flickable {
        id: flickable
        anchors.fill: parent
        
        contentWidth: window.width
        contentHeight: window.height + 999999
        contentY: contentHeight / 2
        
        // if the recent window.offset change was due to this flickable
        property bool offsetChangedDueToContentY: false
        Connections {
            target: window
            function onOffsetChanged() {
                if (!flickable.offsetChangedDueToContentY) {
                    // ensure the flickable's contentY is not moving when other sources change window.offset
                    flickable.cancelFlick(); 
                }
                flickable.offsetChangedDueToContentY = false;
            }
        }
        
        property real oldContentY
        onContentYChanged: {
            offsetChangedDueToContentY = true;
            window.offset += oldContentY - contentY;
            oldContentY = contentY;
        }
        
        onMovementStarted: {
            window.cancelAnimations();
            window.dragging = true;
        }
        onFlickStarted: window.dragging = true;
        onMovementEnded: {
            window.dragging = false;
            window.updateState();
        }
        onFlickEnded: {
            window.dragging = true;
            window.updateState();
        }
        
        onDraggingChanged: {
            if (!dragging) {
                window.dragging = false;
                flickable.cancelFlick();
                window.updateState();
            }
        }
        
        // the flickable is only used to measure drag changes, we implement our own UI component movements
        // the window element is not affected by contentY changes (it's effectively anchored to the flickable)
        Loader {
            id: contentContainerLoader
            
            property real minimizedQuickSettingsOffset: item ? item.minimizedQuickSettingsOffset : 0
            property real maximizedQuickSettingsOffset: item ? item.maximizedQuickSettingsOffset : 0
            
            y: flickable.contentY
            width: window.width
            height: window.height
            
            sourceComponent: window.mode == ActionDrawer.Portrait ? portraitContentContainer : landscapeContentContainer
        }
        
        Component {
            id: portraitContentContainer
            PortraitContentContainer {
                actionDrawer: window
                width: window.width
                height: window.height
            }
        }
        
        Component {
            id: landscapeContentContainer
            LandscapeContentContainer {
                actionDrawer: window
                width: window.width
                height: window.height
            }
        }
    }
}
