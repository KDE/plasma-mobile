// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.kirigami 2.12 as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings

/**
 * Quick settings panel for landscape view (right sidebar).
 * For the portrait view quicksettings container, see QuickSettingsDrawer.
 */
MobileShell.BaseItem {
    id: root

    required property var actionDrawer

    property QS.QuickSettingsModel quickSettingsModel

    /**
     * The height of the entire screen the panel opens in.
     */
    required property real fullScreenHeight

    /**
     * Implicit height of the contents of the panel.
     */
    readonly property real contentImplicitHeight: column.implicitHeight

    property alias quickSettings: quickSettingsProxy.contentItem
    property alias statusBar: statusBarProxy.contentItem
    readonly property double brightnessPressedValue: quickSettings.brightnessPressedValue

    // we need extra padding since the background side border is enabled
    topPadding: Kirigami.Units.smallSpacing * 4
    leftPadding: Kirigami.Units.smallSpacing * 4
    rightPadding: Kirigami.Units.smallSpacing * 4
    bottomPadding: Kirigami.Units.smallSpacing * 4

    background: MobileShell.PanelBackground {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        panelType: MobileShell.PanelBackground.PanelType.Base
        opacity: brightnessPressedValue
    }

    contentItem: Item {
        id: containerItem

        // use container item so that our column doesn't get stretched if base item is anchored
        ColumnLayout {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: root.fullScreenHeight
            spacing: 0

            MobileShell.BaseItem {
                id: statusBarProxy
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                // Align these to double pixels to aid vertical alignment and sharper icon rendering
                Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 1.5 * ShellSettings.Settings.statusBarScaleFactor / 2) * 2
                Layout.maximumHeight: Math.round(Kirigami.Units.gridUnit * 1.5 * ShellSettings.Settings.statusBarScaleFactor / 2) * 2

                Kirigami.Theme.colorSet: Kirigami.Theme.Window
                Kirigami.Theme.inherit: false
            }

            MobileShell.BaseItem {
                id: quickSettingsProxy
                width: column.width
                implicitHeight: quickSettings.fullHeight

                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.maximumHeight: root.fullScreenHeight - root.topPadding - root.bottomPadding - statusBarProxy.height - Kirigami.Units.smallSpacing
                Layout.maximumWidth: column.width
            }

            // add extra space here to prevent the bottom handle from overlapping with the BrightnessItem
            Item { Layout.fillHeight: true; height: Kirigami.Units.largeSpacing }
        }

        Handle {
            id: handle
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            opacity: brightnessPressedValue
        }
    }
}

