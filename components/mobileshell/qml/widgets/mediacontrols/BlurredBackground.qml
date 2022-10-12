/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: root
    
    property string imageSource
    property bool darken: false
    
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
                radius: PlasmaCore.Units.smallSpacing
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
            color: Qt.rgba(0, 0, 0, root.darken ? 0.8 : 0.6)
        }
        
        // apply lighten, saturate and blur effect
        layer.enabled: true
        layer.effect: HueSaturation {
            cached: true

            lightness: 0.2
            saturation: 1.5

            layer.enabled: true
            layer.effect: FastBlur {
                cached: true
                radius: 64
                transparentBorder: false
            }
        }
    }
}
