/*
 *   SPDX-FileCopyrightText: 2012-2013 Daniel Nicoletti <dantti12@gmail.com>
 *   SPDX-FileCopyrightText: 2013, 2015 Kai Uwe Broulik <kde@privat.broulik.de>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell.screenbrightnessplugin as ScreenBrightness

Item {
    id: root
    implicitHeight: brightnessRow.implicitHeight
    visible: screenBrightness.brightnessAvailable

    property double brightnessPressedValue: 1
    Behavior on brightnessPressedValue {
        NumberAnimation {
            duration: Kirigami.Units.longDuration * 2
            easing.type: Easing.InOutQuad
        }
    }

    ScreenBrightness.ScreenBrightnessUtil {
        id: screenBrightness
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: -Kirigami.Units.smallSpacing
        anchors.rightMargin: -Kirigami.Units.smallSpacing
        anchors.topMargin: -Kirigami.Units.smallSpacing * 2
        anchors.bottomMargin: -Kirigami.Units.smallSpacing * 2

        color: Kirigami.Theme.backgroundColor
        radius: Kirigami.Units.cornerRadius
    }

    RowLayout {
        id: brightnessRow
        spacing: Kirigami.Units.smallSpacing * 2

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        Kirigami.Icon {
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: width
            source: "low-brightness"
        }

        PC3.Slider {
            id: brightnessSlider
            Layout.fillWidth: true
            from: 1
            to: screenBrightness.maxBrightness
            value: screenBrightness.brightness
            onMoved: screenBrightness.brightness = value;

            onPressedChanged: {
                if (pressed) {
                    brightnessPressedTimer.restart();
                } else{
                    brightnessPressedTimer.stop();
                    brightnessPressedValue = 1;
                }
            }

            Timer {
                id: brightnessPressedTimer
                interval: 100
                repeat: false
                onTriggered: {
                    if (brightnessSlider.pressed) {
                        brightnessPressedValue = 0;
                    }
                }
            }

            // HACK: for some reason, the slider initial value doesn't set without being done after the component completes loading
            Timer {
                interval: 0
                running: true
                repeat: false
                onTriggered: brightnessSlider.value = Qt.binding(() => screenBrightness.brightness)
            }
        }

        Kirigami.Icon {
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: width
            source: "high-brightness"
        }
    }
}
