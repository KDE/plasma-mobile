// SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    anchors.fill: parent

    // whether the blur layer is active or not
    property bool active: true
    // this value is used to switch between blurring the whole wallpaper or just behind the mask areas
    property real fullBlur: 1

    // gets multiplied against the screen size to set the texture size
    readonly property real blurTextureQuality: 0.2
    readonly property int fastBlurRadius: 30

    property var sourceComponent
    property Component maskSourceComponent

    // only take samples from wallpaper when we need the blur for performance
    ShaderEffectSource {
        id: controlledWallpaperSource
        anchors.fill: parent

        // this layer will be blurred, so it looks fine to have a lower texture quality to help with performance
        textureSize: Qt.size(Math.round(root.width * root.blurTextureQuality), Math.round(root.height * root.blurTextureQuality))

        live: root.active
        hideSource: false
        opacity: root.fullBlur
        visible: opacity > 0 && root.active

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

                sourceItem: root.sourceComponent
                live: root.active
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
            active: root.maskSourceComponent && root.fullBlur != 1 && root.active
            anchors.fill: parent

            sourceComponent: root.maskSourceComponent
        }
    }

    // here we utilize the mask on the blur layer so we can blur behind the some homescreen items
    OpacityMask {
        anchors.fill: parent
        source: controlledWallpaperSource
        maskSource: blurMask
        opacity: root.maskSourceComponent ? 1 - root.fullBlur : 0
        visible: opacity > 0 && root.active
    }
}
