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
    property alias cursorShape: mouseArea.cursorShape
    
    /**
     * This property holds the elapsed time in milliseconds before pressAndHold is emitted.
     */
    property real pressAndHoldInterval: 1000
    
    /**
     * Signal that is emitted when the button has been held for a certain amount of time.
     */
    signal pressAndHold()
    
    /**
     * Signal that is emitted when the right click button is pressed.
     */
    signal rightClickPressed()
    
    Timer {
        id: timer
        interval: pressAndHoldInterval
        repeat: false
        running: false
        onTriggered: root.pressAndHold()
    }
    
    onPressedChanged: {
        if (pressed) {
            timer.restart();
        } else {
            timer.stop();
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: {
            if (mouse.button === Qt.RightButton) {
                root.rightClickPressed();
            } else {
                mouse.accepted = false;
            }
        }
    }
}
