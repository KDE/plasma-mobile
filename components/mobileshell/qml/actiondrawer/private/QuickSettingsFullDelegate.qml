/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.components 3.0 as PlasmaComponents

QuickSettingsDelegate {
    id: root

    padding: Kirigami.Units.smallSpacing * 2
    iconItem: icon

    // scale animation on press
    zoomScale: (ShellSettings.Settings.animationsEnabled && mouseArea.pressed) ? 0.9 : 1

    background: Item {
        // very simple shadow for performance
        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: 1
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height

            radius: Kirigami.Units.cornerRadius
            color: Qt.rgba(0, 0, 0, 0.075)
        }

        // background color
        Rectangle {
            anchors.fill: parent
            radius: Kirigami.Units.cornerRadius
            border.pixelAligned: false
            border.width: 1
            border.color: root.enabled ? root.enabledButtonBorderColor : root.disabledButtonBorderColor
            color: {
                if (root.enabled) {
                    return mouseArea.pressed ? root.enabledButtonPressedColor : root.enabledButtonColor
                } else {
                    return mouseArea.pressed ? root.disabledButtonPressedColor : root.disabledButtonColor
                }
            }
        }
    }

    MobileShell.HapticsEffect {
        id: haptics
    }

    contentItem: MouseArea {
        id: mouseArea

        onPressed: haptics.buttonVibrate()
        onClicked: root.delegateClick()
        onPressAndHold: {
            haptics.buttonVibrate();
            root.delegatePressAndHold();
        }

        cursorShape: Qt.PointingHandCursor

        Kirigami.Icon {
            id: icon
            anchors.top: parent.top
            anchors.left: parent.left
            implicitWidth: Kirigami.Units.iconSizes.small
            implicitHeight: width
            source: root.icon
        }

        ColumnLayout {
            id: column
            spacing: Kirigami.Units.smallSpacing
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            MobileShell.MarqueeLabel {
                Layout.fillWidth: true
                inputText: root.text
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.75 // TODO base height off of size of delegate
                font.weight: Font.Bold
            }

            MobileShell.MarqueeLabel {
                // if no status is given, just use On/Off
                inputText: root.status ? root.status : (root.enabled ? i18n("On") : i18n("Off"))
                opacity: 0.6

                Layout.fillWidth: true
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.75
            }
        }
    }
}

