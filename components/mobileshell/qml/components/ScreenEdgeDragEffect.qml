// SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.15
import QtQuick.Shapes 1.8

import org.kde.kirigami 2.20 as Kirigami

Item {
    id: root

    property bool isHorizontal: false
    property real length: Kirigami.Units.gridUnit * 10
    property real offsetLimit: Kirigami.Units.gridUnit * 2

    property real startPoint: 0
    property real sidePoint: 0
    property real offsetPoint: 0

    visible: offsetPoint != 0

    Shape {
        id: shape

        readonly property int flip: root.offsetPoint > 0 ? -1 : 1
        readonly property real position:  root.startPoint - root.length / 2
        readonly property real sp: Math.max(Math.min(root.sidePoint, root.length), -Kirigami.Units.gridUnit * 10)
        readonly property real op: Math.max(Math.min(-shape.calculateResistance(-root.offsetPoint, 0), 0), -root.offsetLimit + 3)

        transform: [
            Translate {
                x: root.isHorizontal ? 0 : shape.position
                y: root.isHorizontal ? shape.position : 0
            }
        ]

        function calculateResistance(value : double, threshold : int) : double {
            if (value > threshold) {
                return threshold + Math.pow(value - threshold + 1, Math.max(0.8 - (value - threshold) / ((root.isHorizontal ? Screen.width : Screen.height - threshold) * 2), 0.65));
            } else {
                return value;
            }
        }

        readonly property var shapPath: [
            Qt.point(3 * shape.flip, 0),
            Qt.point(2 * shape.flip, 0),
            Qt.point(0, root.length * 0.2 + shape.sp * 0.16),
            Qt.point(shape.op, root.length * 0.5 + shape.sp * 0.35),
            Qt.point(0, root.length * 0.8 + shape.sp * 0.16),
            Qt.point(2 * shape.flip, root.length),
            Qt.point(3 * shape.flip, root.length),
        ]

        ShapePath {
            id: shapeVertical
            fillColor: "black"
            strokeColor: "black"

            startX: shape.shapPath[0].x; startY: shape.shapPath[0].y
            PathCurve { x: root.isHorizontal ? shape.shapPath[1].x : shape.shapPath[1].y; y: root.isHorizontal ? shape.shapPath[1].y : shape.shapPath[1].x}
            PathCurve { x: root.isHorizontal ? shape.shapPath[2].x : shape.shapPath[2].y; y: root.isHorizontal ? shape.shapPath[2].y : shape.shapPath[2].x}
            PathCurve { x: root.isHorizontal ? shape.shapPath[3].x : shape.shapPath[3].y; y: root.isHorizontal ? shape.shapPath[3].y : shape.shapPath[3].x}
            PathCurve { x: root.isHorizontal ? shape.shapPath[4].x : shape.shapPath[4].y; y: root.isHorizontal ? shape.shapPath[4].y : shape.shapPath[4].x}
            PathCurve { x: root.isHorizontal ? shape.shapPath[5].x : shape.shapPath[5].y; y: root.isHorizontal ? shape.shapPath[5].y : shape.shapPath[5].x}
            PathCurve { x: root.isHorizontal ? shape.shapPath[6].x : shape.shapPath[6].y; y: root.isHorizontal ? shape.shapPath[6].y : shape.shapPath[6].x}
        }
    }
}
