/*
 *   SPDX-FileCopyrightText: 2014 Marco Martin <notmart@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.14
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell

NanoShell.FullScreenOverlay {
    id: window

    property int offset: 0
    property int openThreshold
    property bool userInteracting: false
    readonly property bool wideScreen: width > height || width > units.gridUnit * 45
    readonly property int drawerWidth: wideScreen ? contentItem.implicitWidth : width
    property int drawerX: 0
    property alias fixedArea: mainScope
    property alias flickable: mainFlickable

    color: "transparent"
    property alias contentItem: contentArea.contentItem
    property int headerHeight
    property real topEmptyAreaHeight

    signal closed

    width: Screen.width
    height: Screen.height

    enum MovementDirection {
        None = 0,
        Up,
        Down
    }
    property int direction: SlidingPanel.MovementDirection.None

    function cancelAnimations() {
        closeAnim.stop();
        openAnim.stop();
    }
    function open() {
        cancelAnimations();
        window.showFullScreen();
        openAnim.restart();
    }
    function close() {
        cancelAnimations();
        closeAnim.restart();
    }
    function updateState() {
        cancelAnimations();
        if (window.offset <= -headerHeight) {
            // close immediately, so that we don't have to wait units.longDuration 
            window.visible = false;
            window.closed();
        } else if (window.direction === SlidingPanel.MovementDirection.None) {
            if (offset < openThreshold) {
                close();
            } else {
                openAnim.restart();
            }
        } else if (offset > openThreshold && window.direction === SlidingPanel.MovementDirection.Down) {
            openAnim.restart();
        } else if (mainFlickable.contentY > openThreshold) {
            close();
        } else {
            openAnim.restart();
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
    /*onVisibleChanged: {
        if (visible) {
            window.width = Screen.width;
            window.height = Screen.height;
            window.requestActivate();
        }
    }*/

    SequentialAnimation {
        id: closeAnim
        PropertyAnimation {
            target: window
            duration: units.longDuration
            easing.type: Easing.InOutQuad
            properties: "offset"
            from: window.offset
            to: -headerHeight
        }
        ScriptAction {
            script: {
                window.visible = false;
                window.closed();
            }
        }
    }
    PropertyAnimation {
        id: openAnim
        target: window
        duration: units.longDuration
        easing.type: Easing.InOutQuad
        properties: "offset"
        from: window.offset
        to: contentArea.height - topEmptyAreaHeight
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: parent.height - headerHeight // don't layer on top panel indicators (area is darkened separately)
        color: "black"
        opacity: 0.6 * Math.min(1, offset/contentArea.height)
    
        Rectangle {
            height: headerHeight
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.top
            }
            color: "black"
            opacity: 0.2
        }
        Rectangle {
            height: units.smallSpacing
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            gradient: Gradient {
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(0, 0, 0, 0.0)
                }
                GradientStop {
                    position: 0.5
                    color: Qt.rgba(0, 0, 0, 0.4)
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }
        }
    }
    PlasmaCore.ColorScope {
        id: mainScope
        anchors.fill: parent

        Flickable {
            id: mainFlickable
            anchors {
                fill: parent
                topMargin: headerHeight
            }
            Binding {
                target: mainFlickable
                property: "contentY"
                value: -window.offset + contentArea.height
                when: !mainFlickable.moving && !mainFlickable.dragging && !mainFlickable.flicking
            }
            //no loop as those 2 values compute to exactly the same
            onContentYChanged: {
                if (contentY === oldContentY) {
                    window.direction = SlidingPanel.MovementDirection.None;
                } else {
                    window.direction = contentY > oldContentY ? SlidingPanel.MovementDirection.Up : SlidingPanel.MovementDirection.Down;
                }
                window.offset = -contentY + contentArea.height
                oldContentY = contentY;
            }
            property real oldContentY
            boundsMovement: Flickable.StopAtBounds
            contentWidth: window.width
            contentHeight: window.height*2 - headerHeight*2
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
                PlasmaComponents.Control {
                    id: contentArea
                    z: 1
                    y: 0
                    x: drawerX
                    width: drawerWidth
                }
            }
        }
    }
}
