// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.workspace.keyboardlayout 1.0
import org.kde.notificationmanager as Notifications
import org.kde.plasma.private.mobileshell as MobileShell

Item {
    id: root

    readonly property int topMargin: verticalLayout.height + verticalLayout.anchors.topMargin + anchors.topMargin
    readonly property int leftMargin: leftLayout.width + leftLayout.anchors.leftMargin

    required property bool isVertical

    // Vertical layout
    ColumnLayout {
        id: verticalLayout
        visible: root.isVertical
        spacing: 0

        anchors {
            topMargin: Kirigami.Units.gridUnit * 3.5
            top: parent.top
            left: parent.left
            right: parent.right
        }

        LayoutItemProxy { target: clockAndMediaWidget }
    }

    // Horizontal layout (landscape on smaller devices)
    Item {
        id: horizontalLayout
        anchors.fill: parent
        visible: !root.isVertical

        ColumnLayout {
            id: leftLayout
            width: parent.width / 2
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                leftMargin: Kirigami.Units.gridUnit * 3
            }

            LayoutItemProxy { target: clockAndMediaWidget }
        }
    }

    // Clock and media widget column
    ColumnLayout {
        id: clockAndMediaWidget
        Layout.fillWidth: true
        Layout.fillHeight: root.isVertical
        spacing: Kirigami.Units.gridUnit

        Clock {
            layoutAlignment: root.isVertical ? Qt.AlignHCenter : Qt.AlignLeft
            Layout.alignment: root.isVertical ? Qt.AlignHCenter : Qt.AlignLeft
            Layout.fillWidth: true
        }

        MobileShell.MediaControlsWidget {
            Layout.alignment: root.isVertical ? Qt.AlignHCenter : Qt.AlignLeft
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 25
            Layout.leftMargin: root.isVertical ? Kirigami.Units.gridUnit : 0
            Layout.rightMargin: root.isVertical ? Kirigami.Units.gridUnit : 0
        }
    }
}
