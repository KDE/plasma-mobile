// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Window

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

/**
 * Root element that contains all the ActionDrawer's contents, and is anchored to the screen.
 */
Item {
    id: root

    required property var actionDrawer

    property alias quickSettings: quickSettingsPanel.quickSettings
    property alias statusBar: quickSettingsPanel.statusBar
    property alias mediaControlsWidget: mediaControlsWidgetProxy.contentItem
    property alias notificationsWidget: notificationWidgetProxy.contentItem

    readonly property real minimizedQuickSettingsOffset: height
    readonly property real maximizedQuickSettingsOffset: height
    readonly property bool isOnLargeScreen: width > quickSettingsPanel.width * 2.5
    readonly property real minWidthHeight: Math.min(root.width, root.height)
    readonly property real opacityValue: Math.max(0, Math.min(1, actionDrawer.offset / root.minimizedQuickSettingsOffset))
    readonly property double brightnessPressedValue: quickSettings.brightnessPressedValue

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    P5Support.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
    }

    MouseArea {
        anchors.fill: parent

        // dismiss drawer when background is clicked
        onClicked: root.actionDrawer.close();

        // left side
        ColumnLayout {
            id: columnLayout

            opacity: opacityValue
            spacing: 0

            anchors {
                top: mediaControlsWidgetProxy.bottom
                topMargin: 0
                bottom: parent.bottom
                bottomMargin: 0
                right: quickSettingsPanel.left
                left: parent.left
            }
            anchors.margins: minWidthHeight * 0.06

            MobileShell.BaseItem {
                id: notificationWidgetProxy

                // don't allow notifications widget to get too wide
                Layout.maximumWidth: Kirigami.Units.gridUnit * 25
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.topMargin: minWidthHeight * 0.02
            }
        }

        PlasmaComponents.Label {
            id: clock
            text: Qt.formatTime(timeSource.data.Local.DateTime, MobileShell.ShellUtil.isSystem24HourFormat ? "h:mm" : "h:mm ap")
            verticalAlignment: Qt.AlignVCenter
            opacity: Math.min(brightnessPressedValue, columnLayout.opacity)

            anchors {
                left: parent.left
                top: parent.top
                topMargin: columnLayout.anchors.margins / 2
                leftMargin: columnLayout.anchors.margins
            }

            font.pixelSize: Math.min(40, minWidthHeight * 0.1)
            font.weight: Font.ExtraLight
            elide: Text.ElideRight
        }

        PlasmaComponents.Label {
            id: date
            text: Qt.formatDate(timeSource.data.Local.DateTime, "ddd MMMM d")
            verticalAlignment: Qt.AlignTop
            color: Kirigami.Theme.disabledTextColor
            opacity: Math.min(brightnessPressedValue, columnLayout.opacity)

            anchors {
                left: parent.left
                top: clock.bottom
                bottom: isOnLargeScreen ? columnLayout.top : mediaControlsWidgetProxy.top
                topMargin: Kirigami.Units.smallSpacing
                leftMargin: columnLayout.anchors.margins
            }

            font.pixelSize: Math.min(20, minWidthHeight * 0.05)
            font.weight: Font.Light
        }

        MobileShell.BaseItem {
            id: mediaControlsWidgetProxy
            property real fullHeight: visible ? height + Kirigami.Units.smallSpacing * 6 : 0

            y: isOnLargeScreen ? date.y - height + date.implicitHeight : date.y + date.implicitHeight + columnLayout.anchors.margins / 2
            opacity: columnLayout.opacity

            anchors {
                right: quickSettingsPanel.left
                left: isOnLargeScreen ? date.right : parent.left
                leftMargin: columnLayout.anchors.margins
                rightMargin: columnLayout.anchors.margins - quickSettingsPanel.leftPadding
            }
        }

        // right sidebar
        MobileShell.QuickSettingsPanel {
            id: quickSettingsPanel
            height: quickSettingsPanel.contentImplicitHeight + quickSettingsPanel.topPadding + quickSettingsPanel.bottomPadding
            width: intendedWidth

            readonly property real intendedWidth: 360

            property real offsetRatio: quickSettingsPanel.height / root.height
            anchors.topMargin: Math.min(root.actionDrawer.offset * offsetRatio - quickSettingsPanel.height, 0)
            anchors.top: parent.top
            anchors.right: parent.right

            actionDrawer: root.actionDrawer
            fullScreenHeight: root.height
        }
    }
}
