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
