// SPDX-FileCopyrightText: 2025 User8395 <therealuser8395@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.quicksetting.flashlight
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.kirigami as Kirigami

AbstractButton {
    id: root

    property int buttonAction

    property bool buttonHeld: false
    property double scale: pressed ? (buttonHeld ? 1.7 : 1.5) : 1
    property real fillAmount: 0.0

    Behavior on scale {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutBack
        }
    }

    MobileShell.HapticsEffect {
        id: haptics
    }

    visible: buttonAction !== ShellSettings.Settings.None
    padding: Math.round(Kirigami.Units.gridUnit * 1.25)

    transform: Scale {
        origin.x: width / 2
        origin.y: height / 2
        xScale: scale
        yScale: scale
    }

    background: Rectangle {
        radius: width
        color: Qt.rgba(255, 255, 255, 0.2)

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * root.fillAmount
            height: parent.height * root.fillAmount
            radius: Math.min(width, height)
            color: Qt.rgba(255, 255, 255, 0.2) // Use the same background rectangle color
        }
    }

    contentItem: Item {
        Kirigami.Icon {
            anchors.centerIn: parent
            width: Kirigami.Units.iconSizes.small
            height: Kirigami.Units.iconSizes.small
            source: {
                switch (buttonAction) {
                    case ShellSettings.Settings.Flashlight:
                        return "flashlight-on-symbolic"
                    case ShellSettings.Settings.Camera:
                        return "camera-photo-symbolic"
                }
            }
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        }
    }

    onPressedChanged: {
        if (pressed) {
            pressedTimer.restart();
            buttonHeld = false;

            // Ensure emptyAnimation is not running
            // And fillAnimation use current fillAmount state before start
            // To avoid "reset" glitch
            emptyAnimation.stop();
            fillAnimation.from = root.fillAmount;
            fillAnimation.start();
        } else {
            pressedTimer.stop();

            // Ensure fillAnimation is not running
            // And emptyAnimation use current fillAmount state before start
            // To avoid "reset" glitch
            fillAnimation.stop();
            emptyAnimation.from = root.fillAmount;
            emptyAnimation.start();
        }
    }

    onReleased: {
        if (!buttonHeld) {
            return
        }
        switch (buttonAction) {
            case ShellSettings.Settings.Flashlight:
                FlashlightUtil.toggleTorch();
                return;
            case ShellSettings.Settings.Camera:
                MobileShell.ShellUtil.launchApp("org.kde.plasma.camera");
                flickable.goToOpenPosition();
                return;
        }
    }

    Timer {
        id: pressedTimer
        interval: Kirigami.Units.longDuration
        repeat: false
        onTriggered: {
            haptics.buttonVibrate();
            buttonHeld = true;
        }
    }

    PropertyAnimation {
        id: fillAnimation
        target: root
        property: "fillAmount"
        duration: Kirigami.Units.longDuration
        to: 1.0
    }

    PropertyAnimation {
        id: emptyAnimation
        target: root
        property: "fillAmount"
        duration: Kirigami.Units.longDuration
        to: 0.0
    }
}
