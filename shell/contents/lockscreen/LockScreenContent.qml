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

    required property var lockScreenState
    required property bool isVertical

    property var notificationsModel: []
    property bool notificationsShown: false

    property real fullHeight

    signal passwordRequested()

    // Vertical layout
    ColumnLayout {
        id: verticalLayout
        visible: root.isVertical
        spacing: 0

        // Center clock when no notifications are shown, otherwise move the clock upward
        anchors.topMargin: root.notificationsShown ? Kirigami.Units.gridUnit * 5 : Math.round(root.fullHeight / 2 - (verticalLayout.implicitHeight / 2))
        anchors.bottomMargin: Kirigami.Units.gridUnit
        anchors.fill: parent

        // Animate clock centering change when notifications come in
        Behavior on anchors.topMargin {
            id: topMarginAnim
            enabled: false

            NumberAnimation {
                duration: Kirigami.Units.veryLongDuration
                easing.type: Easing.InOutExpo
            }
        }

        LayoutItemProxy { target: clockAndMediaWidget }
        LayoutItemProxy { target: notificationComponent }
    }

    // HACK: don't animate top margin at beginning, while notification model figures itself out
    Timer {
        running: true
        repeat: false
        onTriggered: topMarginAnim.enabled = true
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

        ColumnLayout {
            id: rightLayout
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: leftLayout.right
                right: parent.right
                rightMargin: Kirigami.Units.gridUnit
            }

            LayoutItemProxy { target: notificationComponent }
        }
    }

    // Clock and media widget column
    ColumnLayout {
        id: clockAndMediaWidget
        Layout.fillWidth: true
        Layout.fillHeight: root.isVertical
        spacing: Kirigami.Units.gridUnit * 2

        Clock {
            layoutAlignment: root.isVertical ? Qt.AlignHCenter : Qt.AlignLeft
            Layout.alignment: root.isVertical ? Qt.AlignHCenter : Qt.AlignLeft
            Layout.fillWidth: true
            Layout.bottomMargin: root.isVertical ? Kirigami.Units.gridUnit * 2 : 0
        }

        MobileShell.MediaControlsWidget {
            Layout.alignment: root.isVertical ? Qt.AlignHCenter : Qt.AlignLeft
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 25
            Layout.leftMargin: root.isVertical ? Kirigami.Units.gridUnit : 0
            Layout.rightMargin: root.isVertical ? Kirigami.Units.gridUnit : 0

            layer.enabled: true
            layer.effect: MultiEffect {
                blurMax: 16
                shadowEnabled: true
                shadowVerticalOffset: 1
                shadowOpacity: 0.5
                shadowColor: Qt.lighter(Kirigami.Theme.backgroundColor, 0.1)
            }
        }
    }

    NotificationsComponent {
        id: notificationComponent
        lockScreenState: root.lockScreenState
        notificationsModel: root.notificationsModel

        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * (25 + 2) // clip margins

        leftMargin: root.isVertical ? 0 : Kirigami.Units.gridUnit
        rightMargin: root.isVertical ? 0 : Kirigami.Units.gridUnit
        bottomMargin: root.isVertical ? 0 : Kirigami.Units.gridUnit
        topMargin: Kirigami.Units.gridUnit

        onPasswordRequested: root.passwordRequested()
        onNotificationsShownChanged: root.notificationsShown = notificationsShown
    }
}