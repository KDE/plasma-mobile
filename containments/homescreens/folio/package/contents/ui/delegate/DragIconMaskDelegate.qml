// SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick

import org.kde.kirigami as Kirigami

/**
 * Drag icon mask template component.
 */

IconMaskDelegate {
    id: root

    width: item ? item.width : 0
    height: item ? item.height : 0

    function setXBinding() {
        x = Qt.binding(() => item.x);
    }
    function setYBinding() {
        y = Qt.binding(() => item.y);
    }

    // animate drop x
    XAnimator on x {
        id: dragXAnim
        running: false
        duration: Kirigami.Units.longDuration
        easing.type: Easing.OutCubic
        onFinished: {
            root.setXBinding();
        }
    }

    // animate drop y
    YAnimator on y {
        id: dragYAnim
        running: false
        duration: Kirigami.Units.longDuration
        easing.type: Easing.OutCubic
        onFinished: {
            root.setYBinding();
        }
    }

    Connections {
        target: item

        function onAnimateDrop() {
            dragXAnim.to = item.snapPositionX;
            dragYAnim.to = item.snapPositionY;
            dragXAnim.restart();
            dragYAnim.restart();
        }
    }
}
