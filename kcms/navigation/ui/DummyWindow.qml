/*
    SPDX-FileCopyrightText: 2025 Luis Büchi <luis.buechi@kdemail.net>
    SPDX-FileCopyrightText: 2026 Micah Stanley <stanleymicah@proton.me>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kirigami as Kirigami

Rectangle {
    id: root

    property real windowScale: 1
    property real offset: 0
    property string imageSource: ""

    property real baseWidth: 0
    property real baseHeight: 0
    property real phoneRadius: 0
    property real phoneBorderWidth: 0

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Window

    color: Kirigami.Theme.backgroundColor
    width: Math.round(baseWidth * windowScale)
    height: Math.round(baseHeight * windowScale)
    radius: Math.max(0, phoneRadius - phoneBorderWidth)

    Image {
        source: root.imageSource

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        width: {
            if (root.width > root.height * 0.8) {
                return Math.round(root.height * 0.6)
            }
            return Math.round(root.width * 0.75)
        }
        fillMode: Image.PreserveAspectFit
    }
}
