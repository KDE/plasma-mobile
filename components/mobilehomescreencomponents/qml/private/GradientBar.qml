/*
 *  SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    Behavior on opacity {
        OpacityAnimator {
            duration: PlasmaCore.Units.longDuration * 2
            easing.type: Easing.InOutQuad
        }
    }
    
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: PlasmaCore.Units.gridUnit + root.leftPadding
            rightMargin: PlasmaCore.Units.gridUnit + root.rightPadding
        }
        height: 1
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0) }
            GradientStop { position: 0.15; color: Qt.rgba(1, 1, 1, 0.5) }
            GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 1) }
            GradientStop { position: 0.85; color: Qt.rgba(1, 1, 1, 0.5) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0) }
        }
    }
}
