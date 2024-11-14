// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami 2.12 as Kirigami
import org.kde.ksvg 1.0 as KSvg

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

/**
 * Quick settings drawer pulled down from the top (for portrait mode).
 * For the landscape view quicksettings container, see QuickSettingsPanel.
 */
MobileShell.BaseItem {
    id: root

    required property var actionDrawer

    /**
     * The amount of height to add to the panel (increasing the height of the quick settings area).
     */
    property real addedHeight: 0

    /**
     * The maximum amount of added height to snap to the full height of the quick settings panel.
     */
    readonly property real maxAddedHeight: quickSettings.fullHeight - minimizedQuickSettingsHeight // first row is part of minimized height

    /**
     * Height of panel when in minimized mode.
     */
    readonly property real minimizedHeight: bottomPadding + topPadding + statusBarProxy.height + minimizedQuickSettingsHeight + mediaControlsWidgetProxy.height + handle.fullHeight

    /**
     * Height of just the QuickSettings component in minimized mode.
     */
    readonly property real minimizedQuickSettingsHeight: quickSettings.minimizedRowHeight + Kirigami.Units.gridUnit

    /**
     * Progress of showing the full quick settings view from pinned.
     */
    property real minimizedToFullProgress: 1

    property alias quickSettings: quickSettingsProxy.contentItem
    property alias statusBar: statusBarProxy.contentItem
    property alias mediaControlsWidget: mediaControlsWidgetProxy.contentItem
    readonly property double brightnessPressedValue: quickSettings.brightnessPressedValue

    // we need extra padding if the background side border is enabled
    topPadding: Kirigami.Units.smallSpacing
    leftPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing * 4

    background: KSvg.FrameSvgItem {
        enabledBorders: KSvg.FrameSvgItem.BottomBorder
        imagePath: "widgets/background"
        opacity: brightnessPressedValue
    }

    contentItem: Item {
        id: containerItem
        implicitHeight: column.implicitHeight

        // use container item so that our column doesn't get stretched if base item is anchored
        ColumnLayout {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 0

            MobileShell.BaseItem {
                id: statusBarProxy
                Layout.fillWidth: true
                Layout.preferredHeight: MobileShell.Constants.topPanelHeight + Kirigami.Units.gridUnit * 0.8
            }

            MobileShell.BaseItem {
                id: quickSettingsProxy
                Layout.preferredHeight: root.minimizedQuickSettingsHeight + root.addedHeight
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.fillWidth: true

                height: root.minimizedQuickSettingsHeight + root.addedHeight
                width: parent.width
            }

            MobileShell.BaseItem {
                id: mediaControlsWidgetProxy
                property real fullHeight: height + Layout.topMargin
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.leftMargin: Kirigami.Units.largeSpacing
                Layout.rightMargin: Kirigami.Units.largeSpacing
            }

            Handle {
                id: handle
                property real fullHeight: height + Layout.topMargin
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Kirigami.Units.smallSpacing * 2
                opacity: brightnessPressedValue

                onTapped: {
                    if (root.minimizedToFullProgress < 0.5) {
                        root.actionDrawer.expand();
                    } else {
                        root.actionDrawer.open();
                    }
                }
            }
        }
    }
}
