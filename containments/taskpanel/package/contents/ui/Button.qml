/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

Item {
    id: button
    width: Math.min(parent.width, parent.height)
    height: width

    property MouseArea mouseArea
    readonly property bool pressed: mouseArea.pressed && mouseArea.activeButton == button
    property alias iconSource: icon.source
    signal clicked()

    Rectangle {
        id: rect
        radius: height/2
        anchors.fill: parent
        opacity: 0
        color: PlasmaCore.ColorScope.textColor
        
        // this way of calculating animations lets the animation fully complete before switching back (tap runs the full animation)
        property bool buttonHeld: button.pressed && button.enabled
        
        onButtonHeldChanged: showBackground(buttonHeld)
        Component.onCompleted: showBackground(buttonHeld)
        
        function showBackground(show) {
            if (show) {
                if (!opacityAnimator.running && opacityAnimator.to !== 0.1) {
                    opacityAnimator.to = 0.1;
                    opacityAnimator.start();
                }
            } else {
                if (!opacityAnimator.running && opacityAnimator.to !== 0) {
                    opacityAnimator.to = 0;
                    opacityAnimator.start();
                }
            }
        }
        NumberAnimation on opacity {
            id: opacityAnimator
            duration: units.shortDuration
            easing.type: Easing.InOutQuad
            onFinished: {
                // animate the state back
                if (rect.buttonHeld && opacityAnimator.to === 0) {
                    rect.showBackground(true);
                } else if (!rect.buttonHeld && opacityAnimator.to === 0.1) {
                    rect.showBackground(false);
                }
            }
        }
    }
    PlasmaCore.IconItem {
        id: icon
        anchors.fill: parent
        colorGroup: PlasmaCore.ColorScope.colorGroup
        //enabled: button.enabled && button.clickable
    }
}
