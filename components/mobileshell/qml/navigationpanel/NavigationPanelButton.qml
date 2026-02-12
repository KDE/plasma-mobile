/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.mobileshell as MobileShell

Controls.AbstractButton {
    id: button
    width: Math.min(parent.width, parent.height)
    height: width

    property int shrinkSize: 0
    property alias iconSource: icon.source

    MobileShell.HapticsEffect {
        id: haptics
    }

    onPressed: haptics.buttonVibrate()

    Rectangle {
        id: rect
        radius: height/2
        anchors.fill: parent
        opacity: 0
        color: Kirigami.Theme.textColor

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
            duration: Kirigami.Units.shortDuration
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

    Kirigami.Icon {
        id: icon

        // Workaround for icon colors being grey when button is disabled
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: button.Kirigami.Theme.colorSet

        readonly property real side: Math.min(button.width, button.height)
        anchors.centerIn: parent

        implicitHeight: Kirigami.Units.iconSizes.smallMedium - shrinkSize
        implicitWidth: Kirigami.Units.iconSizes.smallMedium - shrinkSize
        width: implicitWidth
        height: implicitHeight
    }
}
