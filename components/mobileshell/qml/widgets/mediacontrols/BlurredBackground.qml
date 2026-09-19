// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Effects

import org.kde.kirigami as Kirigami

Item {
    id: root

    property string imageSource
    property bool darken: false

    Rectangle {
        id: cornerMask
        anchors.fill: parent
        radius: Kirigami.Units.cornerRadius
        color: "white"
        visible: false
        layer.enabled: true
    }

    // darken background when pressed
    Rectangle {
        anchors.fill: parent
        color: "black"
        radius: Kirigami.Units.cornerRadius
        opacity: root.darken ? 0.05 : 0
    }

    Image {
        id: img
        source: root.imageSource
        asynchronous: true

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        // Bound decoding to the displayed size, in steps to avoid reloading on every resize pixel.
        sourceSize: Qt.size(Math.max(64, Math.ceil(width * Screen.devicePixelRatio / 64) * 64),
                            Math.max(64, Math.ceil(height * Screen.devicePixelRatio / 64) * 64))

        // ensure text is readable
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.2)
            visible: img.progress
        }

        opacity: 0.1

        // apply lighten, saturate and blur effect
        layer.enabled: true
        layer.effect: MultiEffect {
            brightness: 0.075
            maskEnabled: true
            maskSource: cornerMask

            blurEnabled: true
            blurMax: 32
            blur: 1.0
            blurMultiplier: 2
            autoPaddingEnabled: false
        }
    }
}
