/*
 *   SPDX-FileCopyrightText: 2014 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
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

NanoShell.FullScreenOverlay {
    id: window

    property int offset: 0 // slide progress
    property int openThreshold: PlasmaCore.Units.gridUnit * 2
    property bool userInteracting: false
    property bool initiallyOpened: false // whether the panel is already open after a touch release (then don't restrict to collapsed height)
    
    // height when quicksettings is fully open
    required property int fullyOpenHeight
    
    // flickable contentY
    readonly property int openedContentY: wideScreen || offset > (collapsedHeight + openThreshold) ? -topEmptyAreaHeight : offsetToContentY(collapsedHeight)
    readonly property int closedContentY: mainFlickable.contentHeight
    
    readonly property bool wideScreen: width > height || width > PlasmaCore.Units.gridUnit * 45
    readonly property int drawerWidth: wideScreen ? contentItem.implicitWidth : width

    property int drawerX: 0
    property alias fixedArea: mainScope
    property alias flickable: mainFlickable

    color: "transparent"
    property alias contentItem: contentArea.contentItem
    property int topPanelHeight
    property int collapsedHeight
    property real topEmptyAreaHeight
    
    property bool appletsShown: false // whether notifications or media player applets are shown

    signal closed

    width: Screen.width
    height: Screen.height

    Component.onCompleted: plasmoid.nativeInterface.panel = window;

    onVisibleChanged: if (!visible) {
        closed()
    }
    onInitiallyOpenedChanged: {
        if (initiallyOpened) mainFlickable.focus = true;
    }

    function offsetToContentY(num) { return -num + window.fullyOpenHeight; }
    function contentYToOffset(num) { return offsetToContentY(num); }
    
    // avoids binding loops
    function updateOffset(delta) {
        // only go to collapsed height for mousearea when not widescreen
        let maximum = window.wideScreen ? window.fullyOpenHeight : collapsedHeight + openThreshold / 2;
        offset = Math.max(0, Math.min(maximum, offset + delta));
        if (!mainFlickable.moving && !mainFlickable.dragging && !mainFlickable.flicking) {
            mainFlickable.contentY = offsetToContentY(window.offset);
        }
    }
    
    enum MovementDirection {
        None = 0,
        Up,
        Down
    }
    property int direction: SlidingContainer.MovementDirection.None

    function cancelAnimations() {
        closeAnim.stop();
        openAnim.stop();
    }
    function open() {
        cancelAnimations();
        openAnim.restart();
        initiallyOpened = true;
    }
    function close() {
        cancelAnimations();
        closeAnim.restart();
        initiallyOpened = false;
    }
    function expand() {
        cancelAnimations();
        expandAnim.restart();
        initiallyOpened = true;
    }
    function updateState() {
        cancelAnimations();
        if (window.offset <= 0) {
            // close immediately, so that we don't have to wait PlasmaCore.Units.longDuration 
            window.visible = false;
            close();
        } else if (window.direction === SlidingContainer.MovementDirection.None) {
            if (window.offset < openThreshold) {
                close();
            } else {
                open();
            }
        } else if (offset > openThreshold && window.direction === SlidingContainer.MovementDirection.Down) {
            open();
        } else if (mainFlickable.contentY > openThreshold) {
            close();
        } else {
            open();
        }
    }
    Timer {
        id: updateStateTimer
        interval: 0
        onTriggered: updateState()
    }

    onActiveChanged: {
        if (!active) {
            close();
        }
    }

    PropertyAnimation {
        id: closeAnim
        target: mainFlickable
        properties: "contentY"
        duration: PlasmaCore.Units.longDuration
        easing.type: Easing.InOutQuad
        to: window.closedContentY
        onFinished: {
            window.visible = false;
        }
    }
    PropertyAnimation {
        id: openAnim
        target: mainFlickable
        properties: "contentY"
        duration: PlasmaCore.Units.longDuration
        easing.type: Easing.InOutQuad
        to: window.openedContentY
    }
    PropertyAnimation {
        id: expandAnim
        target: mainFlickable
        properties: "contentY"
        duration: PlasmaCore.Units.longDuration
        easing.type: Easing.InOutQuad
        to: 0
    }

    // fullscreen background
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.75)
        opacity: (appletsShown ? 0.85 : 0.6) * Math.max(0, Math.min(1, offset / window.collapsedHeight))
        Behavior on opacity { // smooth opacity changes
            NumberAnimation { duration: 70 }
        }
    }
    
    PlasmaCore.ColorScope {
        id: mainScope
        colorGroup: PlasmaCore.Theme.ViewColorGroup
        anchors.fill: parent

        Flickable {
            id: mainFlickable
            anchors.fill: parent
            
            property real oldContentY
            contentY: contentHeight

            onContentYChanged: {
                if (contentY === oldContentY) {
                    window.direction = SlidingContainer.MovementDirection.None;
                } else {
                    window.direction = contentY > oldContentY ? SlidingContainer.MovementDirection.Up : SlidingContainer.MovementDirection.Down;
                }
                window.offset = contentYToOffset(contentY);
                oldContentY = contentY;
                
                // close panel immediately after panel is not shown, and the flickable is not being dragged
                if (initiallyOpened && window.offset <= 0 && !mainFlickable.dragging && !closeAnim.running && !openAnim.running) {
                    window.updateState();
                    focus = false;
                }
            }
            
            boundsMovement: Flickable.StopAtBounds
            contentWidth: window.width
            contentHeight: window.height
            bottomMargin: window.height
            onMovementStarted: {
                window.cancelAnimations();
                window.userInteracting = true;
            }
            onFlickStarted: window.userInteracting = true;
            onMovementEnded: {
                window.userInteracting = false;
                window.updateState();
            }
            onFlickEnded: {
                window.userInteracting = true;
                window.updateState();
            }
            
            MouseArea {
                id: dismissArea
                z: 2
                width: parent.width
                height: mainFlickable.contentHeight
                onClicked: window.close();

                // actual sliding contents
                PlasmaComponents.Control {
                    id: contentArea
                    z: 1
                    x: Math.max(0, Math.min(window.drawerX, window.width - window.drawerWidth))
                    width: Math.min(window.width, window.drawerWidth)
                }
            }
        }
    }
}
