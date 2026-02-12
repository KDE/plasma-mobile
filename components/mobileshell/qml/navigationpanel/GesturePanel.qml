// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Window

import org.kde.plasma.plasmoid

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

import org.kde.kirigami as Kirigami

Rectangle {
    id: root

    // Whether the bar background should be opaque
    required property bool opaqueBar

    signal handleClicked()
    signal handlePressedAndHeld()

    color: opaqueBar ? Kirigami.Theme.backgroundColor : "transparent"

    // Handle
    MouseArea {
        anchors.centerIn: parent
        width: Math.min(root.width * 0.2, Kirigami.Units.gridUnit * 12)
        height: parent.height

        cursorShape: Qt.PointingHandCursor

        onClicked: root.handleClicked()
        onPressAndHold: root.handlePressedAndHeld()

        property real startX
        property real startY
        onPressed: {
            startX = mouseX;
            startY = mouseY;
        }
        onPositionChanged: (mouse) => {
            // Trigger gesture after threshold is crossed (root.height)
            if (startY - mouse.y > root.height) {
                root.handleClicked();
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: 4
            radius: height / 2

            opacity: 0.8
            color: Kirigami.Theme.textColor
        }
    }
}
