// SPDX-FileCopyrightText: 2023-2025 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Loader {
    id: root

    property Item sourceLayer
    property Item maskSourceLayer
    // this value is used to switch between blurring the whole wallpaper or just behind the mask areas
    property real fullBlur: 1
    // gets multiplied against the screen size to set the texture size
    readonly property real blurTextureQuality: 0.5
    readonly property var textureSize: Qt.size(Math.round(root.width * root.blurTextureQuality), Math.round(root.height * root.blurTextureQuality))
    readonly property int fastBlurRadius: 42

    sourceComponent: Item {
        // only take samples from wallpaper when we need the blur for performance
        ShaderEffectSource {
            id: controlledWallpaperSource
            anchors.fill: parent

            // this layer will be blurred, so it looks fine to have a lower texture quality to help with performance
            textureSize: root.textureSize

            hideSource: false
            opacity: root.fullBlur
            visible: opacity > 0

            // wallpaper blur
            // we attempted to use MultiEffect in the past, but it had very poor performance on the PinePhone
            sourceItem: FastBlur {
                height: controlledWallpaperSource.textureSize.height
                width: controlledWallpaperSource.textureSize.width

                cached: true
                radius: root.fastBlurRadius

                source: ShaderEffectSource {
                    anchors.fill: parent

                    textureSize: controlledWallpaperSource.textureSize

                    sourceItem: root.sourceLayer
                    hideSource: false
                }
            }
        }

        // load in the layer mask so we can utilize it with the OpacityMask
        Item {
            id: blurMask
            anchors.fill: parent
            layer.enabled: true
            layer.smooth: true
            opacity: 0

            Loader {
                asynchronous: true
                active: root.maskSourceLayer != null && root.fullBlur != 1
                anchors.fill: parent

                sourceComponent: maskSource

                property Component maskSource: Item {
                    ShaderEffectSource {
                        anchors.fill: parent

                        sourceItem: root.maskSourceLayer
                        hideSource: false
                        live: true
                    }
                }

            }
        }

        // here we utilize the mask on the blur layer so we can blur behind the some homescreen items
        OpacityMask {
            anchors.fill: parent
            source: controlledWallpaperSource
            maskSource: blurMask
            visible: opacity > 0 && root.maskSourceLayer != null
        }
    }
}
