// SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
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

    required property var lockScreenState
    required property bool isVertical
    required property int topMargin
    required property int leftMargin

    property var notificationsModel: []
    property bool notificationsShown: false

    signal passwordRequested()

    // Vertical layout
    ColumnLayout {
        id: verticalLayout
        visible: root.isVertical
        spacing: 0

        anchors.topMargin: root.topMargin
        anchors.bottomMargin: Kirigami.Units.gridUnit * 2
        anchors.fill: parent

        LayoutItemProxy { target: notificationComponent }
    }

    // Horizontal layout (landscape on smaller devices)
    Item {
        id: horizontalLayout
        anchors.fill: parent
        visible: !root.isVertical

        ColumnLayout {
            id: rightLayout
            anchors {
                fill: parent
                leftMargin: root.leftMargin
                rightMargin: Kirigami.Units.gridUnit
            }

            LayoutItemProxy { target: notificationComponent }
        }
    }

    NotificationsComponent {
        id: notificationComponent
        lockScreenState: root.lockScreenState
        notificationsModel: root.notificationsModel

        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * (25 + 2) // clip margins

        leftMargin: root.isVertical ? 0 : Kirigami.Units.gridUnit
        rightMargin: root.isVertical ? 0 : Kirigami.Units.gridUnit
        bottomMargin: root.isVertical ? 0 : Kirigami.Units.gridUnit
        topMargin: Kirigami.Units.gridUnit
        maxHeight: root.isVertical ? verticalLayout.height : rightLayout.height

        onPasswordRequested: root.passwordRequested()
        onNotificationsShownChanged: root.notificationsShown = notificationsShown
    }
}
