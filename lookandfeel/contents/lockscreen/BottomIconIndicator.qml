// SPDX-FileCopyrightText: 2023 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami

Loader {
    id: root
    asynchronous: true

    property var lockScreenState

    property real animationY: 0
    readonly property real fullYOffset: Kirigami.Units.largeSpacing

    // animate it going up and down
    NumberAnimation on animationY {
        id: animateUpAndDown
        duration: 800
        easing.type: Easing.InCubic
        to: root.fullYOffset

        // only bounce icon if we are showing the scroll up icon
        running: !lockScreenState.isFingerprintSupported

        onFinished: {
            if (root.animationY === root.fullYOffset) {
                to = 0;
                easing.type = Easing.OutCubic;
            } else {
                to = root.fullYOffset;
                easing.type = Easing.InCubic;
            }
            restart();
        }

        onStopped: {
            if (lockScreenState.isFingerprintSupported) {
                root.animationY = 0;
            }
        }
    }

    sourceComponent: {
        if (lockScreenState.isFingerprintSupported) {
            return fingerprintIcon;
        } else {
            return scrollUpIcon;
        }
    }

    Component {
        id: scrollUpIcon

        Kirigami.Icon {
            implicitWidth: Kirigami.Units.iconSizes.small
            implicitHeight: Kirigami.Units.iconSizes.small
            opacity: 1 - flickable.openFactor

            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
            source: "arrow-up"
        }
    }

    Component {
        id: fingerprintIcon

        Kirigami.Icon {
            source: 'fingerprint-symbolic'
            opacity: 1 - flickable.openFactor
            implicitWidth: Kirigami.Units.iconSizes.medium
            implicitHeight: Kirigami.Units.iconSizes.medium

            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Kirigami.Units.gridUnit * 2 + flickable.position * 0.5
        }
    }
}
