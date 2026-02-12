/*
 *   SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021-2025 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.kirigami as Kirigami

Item {
    id: root

    // Content margins
    property real topPadding: 0
    property real bottomPadding: 0
    property real leftPadding: 0
    property real rightPadding: 0

    // Call when the gesture has started
    function startGesture() {
        krunnerScreen.clearField();
        flickable.contentY = flickable.closedContentY;
    }

    // Call when the touch gesture has been updated
    function updateGestureOffset(yOffset) {
        flickable.contentY = Math.max(0, Math.min(flickable.closedContentY, flickable.contentY + yOffset));
    }

    // Call when the touch gesture has let go
    function endGesture() {
        flickable.opening ? open() : close();
    }

    // Open the search widget (animated)
    function open() {
        anim.to = flickable.openedContentY;
        anim.restart();
    }

    // Close the search widget (animated)
    function close() {
        anim.to = flickable.closedContentY;
        anim.restart();
    }

    // Emitted when it is requested to force active focus on the parent and release focus on the widget
    signal releaseFocusRequested()

    readonly property real openFactor: Math.max(0, Math.min(1, 1 - flickable.contentY / flickable.closedContentY))
    readonly property bool isOpen: openFactor != 0

    // Pass focus to search screen
    onFocusChanged: {
        if (focus) {
            krunnerScreen.requestFocus();
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)
        opacity: root.openFactor
    }

    Flickable {
        id: flickable

        anchors.fill: parent
        anchors.topMargin: root.topPadding
        anchors.bottomMargin: root.bottomPadding
        anchors.leftMargin: root.leftPadding
        anchors.rightMargin: root.rightPadding

        opacity: root.openFactor

        contentHeight: flickable.height + flickable.closedContentY
        contentY: flickable.closedContentY

        property real oldContentY: contentY
        property bool opening: false

        // The y at which the flickable is fully open
        readonly property real closedContentY: Kirigami.Units.gridUnit * 5

        // The y at which the flickable is fully closed
        readonly property real openedContentY: 0

        onContentYChanged: {
            opening = contentY < oldContentY;
            oldContentY = contentY;

            if (krunnerScreen.focus) {
                // Unfocus from search
                root.releaseFocusRequested();
            }
        }

        onMovementEnded: root.endGesture()
        onDraggingChanged: {
            if (!dragging) {
                root.endGesture();
            }
        }

        NumberAnimation on contentY {
            id: anim
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutQuad
            running: false
            onFinished: {
                if (anim.to === flickable.openedContentY) {
                    krunnerScreen.requestFocus();
                } else {
                    // Unfocus from search
                    root.releaseFocusRequested();
                }
            }
        }

        MobileShell.KRunnerScreen {
            id: krunnerScreen
            width: parent.width
            height: parent.height

            onRequestedClose: root.close();
        }
    }
}
