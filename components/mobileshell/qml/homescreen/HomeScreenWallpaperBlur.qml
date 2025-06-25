// SPDX-FileCopyrightText: 2023-2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Loader {
    id: root
    property real blurOpacity
    property Item wallpaperItem

    sourceComponent: Item {
        id: wallpaper
        anchors.fill: parent

        // only take samples from wallpaper when we need the blur for performance
        ShaderEffectSource {
            id: controlledWallpaperSource
            anchors.fill: parent

            live: blur.visible
            hideSource: false
            visible: false
            sourceItem: root.wallpaperItem
        }

        // wallpaper blur
        // we attempted to use MultiEffect in the past, but it had very poor performance on the PinePhone
        FastBlur {
            id: blur
            radius: 50
            cached: true
            source: controlledWallpaperSource
            anchors.fill: parent
            visible: opacity > 0
            opacity: root.blurOpacity
        }
    }
}