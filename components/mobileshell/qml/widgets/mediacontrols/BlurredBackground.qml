// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

import org.kde.kirigami 2.20 as Kirigami

Item {
    id: root

    property string imageSource
    property bool darken: false
    property bool inActionDrawer: false

    // clip corners so that the image has rounded corners
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Item {
            width: img.width
            height: img.height

            Rectangle {
                anchors.centerIn: parent
                width: img.width
                height: img.height
                radius: Kirigami.Units.cornerRadius
            }
        }
    }

    Image {
        id: img
        source: root.imageSource
        asynchronous: true

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop

        // ensure text is readable
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(Kirigami.Theme.backgroundColor.r * (inActionDrawer ? 0.85 : 0.95), Kirigami.Theme.backgroundColor.g * (inActionDrawer ? 0.85 : 0.95), Kirigami.Theme.backgroundColor.b * (inActionDrawer ? 0.85 : 0.95), root.darken ? 0.95 : 0.85)
        }

        // apply lighten, saturate and blur effect
        layer.enabled: true
        layer.effect: MultiEffect {
            brightness: 0.075

            blurEnabled: true
            blurMax: 32
            blur: 1.0
            blurMultiplier: 2
            autoPaddingEnabled: false
        }
    }
}
