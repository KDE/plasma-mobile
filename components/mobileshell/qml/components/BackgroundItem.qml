// SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Effects

Item {
    id: root

    property real border: 1
    property real shadow: 1
    property real translucent: 0
    property real pressed: 0

    property bool forceBorder: false
    property bool complexShadow: false

    property int radius: Kirigami.Units.cornerRadius

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    // very simple shadow for performance
    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: 1
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height

        visible: root.shadow > 0 && !root.complexShadow
        radius: Kirigami.Units.cornerRadius
        color: "black"
        opacity: 0.075 * root.shadow
    }

    Rectangle {
        id: background
        anchors.fill: root

        color: Qt.darker(Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 1 - (0.05 * root.translucent)), 1.0 + (2.5 * root.pressed))
        radius: root.radius

        visible: !root.shadow || !root.complexShadow

        // Only show border when using a dark background and when the border property is set to true
        readonly property color borderColor: Qt.darker(Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.9), 1.0 + (2.5 * root.pressed))
        border.color: Qt.rgba(borderColor.r, borderColor.g, borderColor.b, root.border)
        border.width: root.border > 0 && ((Kirigami.ColorUtils.brightnessForColor(color)) === Kirigami.ColorUtils.Dark || root.forceBorder) ? 1 : 0
        border.pixelAligned: false
    }

    MultiEffect {
        anchors.fill: background
        source: background
        visible: root.shadow > 0 && root.complexShadow
        blurMax: 8

        shadowEnabled: shadow
        shadowVerticalOffset: 1
        shadowOpacity: 0.5 * shadow
        shadowColor: Qt.darker(Kirigami.Theme.backgroundColor, 1.9)
    }
}
