// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.workspace.keyboardlayout 1.0
import org.kde.notificationmanager as Notifications
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

Item {
    id: root

    required property bool isVertical
    required property var lockScreenState

    readonly property bool listOverflowing: notificationComponent.listOverflowing

    property var notificationsModel: []
    property bool notificationsShown: false

    property bool scrollLock: false

    signal passwordRequested()

    // Vertical layout
    ColumnLayout {
        id: verticalLayout
        visible: root.isVertical
        spacing: 0

        anchors.topMargin: Kirigami.Units.gridUnit * 3.5
        anchors.bottomMargin: Kirigami.Units.gridUnit * 2
        anchors.fill: parent

        LayoutItemProxy { target: clockAndMediaWidget }
        LayoutItemProxy { target: notificationComponent }
        LayoutItemProxy { target: actionButtons }
    }

    // Horizontal layout (landscape on smaller devices)
    Item {
        id: horizontalLayout
        anchors.fill: parent
        visible: !root.isVertical

        ColumnLayout {
            id: leftLayout
            width: Math.round(parent.width / 2.15)
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                leftMargin: Kirigami.Units.gridUnit * 3
                bottomMargin: Kirigami.Units.gridUnit * 3
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

        ColumnLayout {
            anchors.bottomMargin: Kirigami.Units.gridUnit
            anchors.leftMargin: Kirigami.Units.gridUnit
            anchors.rightMargin: Kirigami.Units.gridUnit
            anchors.fill: parent

            LayoutItemProxy { target: actionButtons }
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
            id: mediaControlsWidget
            Layout.alignment: root.isVertical ? Qt.AlignHCenter : Qt.AlignLeft
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 25
            Layout.leftMargin: root.isVertical ? Kirigami.Units.gridUnit : 0
            Layout.rightMargin: root.isVertical ? Kirigami.Units.gridUnit : 0
            panelType: MobileShell.PanelBackground.PanelType.Wallpaper
        }
    }

    // notification widget column
    NotificationsComponent {
        id: notificationComponent
        lockScreenState: root.lockScreenState
        notificationsModel: root.notificationsModel

        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * (25 + 2) // clip margins

        topPadding: root.isVertical ? (mediaControlsWidget.visible ? Kirigami.Units.smallSpacing : Kirigami.Units.gridUnit) : Kirigami.Units.gridUnit

        leftMargin: root.isVertical ? 0 : Kirigami.Units.gridUnit
        rightMargin: root.isVertical ? 0 : Kirigami.Units.gridUnit
        topMargin: root.isVertical ? 0 : MobileShell.Constants.topPanelHeight
        bottomMargin: root.isVertical && (Kirigami.Units.gridUnit * 35 < root.width) && actionButtons.isVisible ? 0 : Kirigami.Units.gridUnit
        scrollLock: root.scrollLock

        onPasswordRequested: root.passwordRequested()
        onNotificationsShownChanged: root.notificationsShown = notificationsShown
    }

    RowLayout {
        id: actionButtons

        readonly property int sideMargin: Kirigami.Units.gridUnit * 2
        readonly property bool isVisible: leftButton.visible || rightButton.visible

        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
        Layout.leftMargin: actionButtons.sideMargin
        Layout.rightMargin: actionButtons.sideMargin

        // Left quick action button.
        QuickActionButton {
            id: leftButton
            buttonAction: ShellSettings.Settings.lockscreenLeftButtonAction
            opacity: Math.max(0, 1 - flickable.openFactor * 2)

            Layout.alignment: Qt.AlignVCenter
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // Right quick action button.
        QuickActionButton {
            id: rightButton
            buttonAction: ShellSettings.Settings.lockscreenRightButtonAction
            opacity: Math.max(0, 1 - flickable.openFactor * 2)

            Layout.alignment: Qt.AlignVCenter
        }
    }
}
