// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick

import org.kde.kirigami as Kirigami

import '../delegate'

MouseArea {
    id: root
    height: 10 + touchPadding * 2
    width: 10 + touchPadding * 2

    readonly property real touchPadding: 20

    property int orientation

    signal dragEvent(real leftEdgeDelta, real rightEdgeDelta, real topEdgeDelta, real bottomEdgeDelta)

    cursorShape: Qt.PointingHandCursor

    drag {
        target: root
        axis: {
            switch (orientation) {
                case WidgetHandlePosition.TopCenter:
                    return Drag.YAxis;
                case WidgetHandlePosition.LeftCenter:
                    return Drag.XAxis;
                case WidgetHandlePosition.RightCenter:
                    return Drag.XAxis;
                case WidgetHandlePosition.BottomCenter:
                    return Drag.YAxis;
            }
            return Drag.XAndYAxis;
        }
    }

    property real pressX
    property real pressY

    onPressed: {
        pressX = mouseX;
        pressY = mouseY;
    }

    onPositionChanged: {
        // HACK: need to call it twice to work
        updateDrag();
        updateDrag();
    }

    drag { target: root; axis: Drag.XAndYAxis }

    function updateDrag() {
        if (!drag.active) return;

        const dx = mouseX;
        const dy = mouseY;

        switch (orientation) {
            case WidgetHandlePosition.TopCenter:
                root.dragEvent(0, 0, -dy, 0);
                break;
            case WidgetHandlePosition.LeftCenter:
                root.dragEvent(-dx, 0, 0, 0);
                break;
            case WidgetHandlePosition.RightCenter:
                root.dragEvent(0, dx, 0, 0);
                break;
            case WidgetHandlePosition.BottomCenter:
                root.dragEvent(0, 0, 0, dy);
                break;
        }
    }

    Rectangle {
        id: rect
        anchors.fill: parent
        anchors.margins: root.touchPadding
        color: 'white'
        radius: width / 2

        transform: Scale {
            property real scaleFactor: root.pressed ? 1.2 : 1.0

            Behavior on scaleFactor {
                NumberAnimation { duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutExpo }
            }

            xScale: scaleFactor
            yScale: scaleFactor
            origin.x: rect.width / 2
            origin.y: rect.height / 2
        }
    }
}
