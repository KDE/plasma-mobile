// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2

/**
 * This component is an AbstractButton with some added functionality to simulate a MouseArea.
 *
 * The hovered property of AbstractButton is much more accurate than the containsMouse property of MouseArea,
 * and so this is useful for creating custom buttons.
 */

QQC2.AbstractButton {
    id: root

    /**
     * The cursor shape when the mouse is over the button.
     */
    property alias cursorShape: hoverHandler.cursorShape

    /**
     * Alias to MouseArea used in the button.
     */
    property alias mouseArea: mouseArea

    /**
     * Whether a mouse is hovering over the button (not touch).
     */
    readonly property bool mouseHovered: hoverHandler.hovered

    /**
     * Signal that is emitted when the right click button is pressed.
     */
    signal rightClickPressed()

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: mouse => {
            if (mouse.button === Qt.RightButton) {
                root.rightClickPressed();
            } else {
                mouse.accepted = false;
            }
        }
    }

    HoverHandler {
        id: hoverHandler
        acceptedDevices: PointerDevice.Mouse
        acceptedPointerTypes: PointerDevice.Generic
    }
}
