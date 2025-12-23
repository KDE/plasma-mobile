/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */


import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls as Controls
import QtQml.Models

import org.kde.kirigami as Kirigami

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.clock
import org.kde.plasma.private.systemtray as SystemTray
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.plasma.private.mobileshell.state as MobileShellState

Item {
    id: root

    /**
     * Whether to show a drop shadow under the status bar.
     */
    property bool showDropShadow: false

    /**
     * The background color of the status bar.
     */
    property color backgroundColor: "transparent"

    /**
     * Whether to show a second row of the status bar, with more information.
     */
    property bool showSecondRow: false // show extra row with date and mobile provider

    /**
     * Whether to show time. If set to false, the signal strength indicator is moved in its place.
     */
    property bool showTime: true

    /**
     * Disables showing system tray indicators, preventing SIGABRT when used on the lockscreen.
     */
    property bool disableSystemTray: false

    readonly property real textPixelSize: Math.round(11 * ShellSettings.Settings.statusBarScaleFactor)
    readonly property real smallerTextPixelSize: Math.round(9 * ShellSettings.Settings.statusBarScaleFactor)
    readonly property real elementSpacing: Math.round(Kirigami.Units.smallSpacing * 1.5)

    Clock {
        id: clockSource
    }

    property alias statusNotifierSource: statusNotifierSourceLoader.item

    Loader {
        id: statusNotifierSourceLoader
        active: !disableSystemTray
        sourceComponent: SystemTray.StatusNotifierModel { }
    }

    MobileShellState.PanelSettingsDBusClient {
        id: panelSettings
        screenName: Screen.name
    }

    // drop shadow for icons
    MultiEffect {
        anchors.fill: control
        visible: showDropShadow
        source: control
        blurMax: 16
        shadowEnabled: true
        shadowVerticalOffset: 1
        shadowOpacity: 0.8
    }

    // screen top panel
    Controls.Control {
        id: control
        z: 1
        topPadding: Kirigami.Units.smallSpacing
        bottomPadding: Kirigami.Units.smallSpacing
        rightPadding: Kirigami.Units.smallSpacing * 3 + panelSettings.statusBarLeftPadding
        leftPadding: Kirigami.Units.smallSpacing * 3 + panelSettings.statusBarRightPadding

        anchors.fill: parent
        background: Rectangle {
            id: panelBackground
            color: backgroundColor
        }

        contentItem: ColumnLayout {
            spacing: Kirigami.Units.smallSpacing / 2

            RowLayout {
                id: mainRow
                readonly property real rowHeight: MobileShell.Constants.defaultTopPanelHeight - Kirigami.Units.smallSpacing * 2

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: rowHeight

                spacing: 0

                // clock
                ClockText {
                    visible: root.showTime
                    Layout.fillHeight: true
                    fontPixelSize: textPixelSize
                    clockSource: clockSource
                }

                MobileShell.SignalStrengthIndicator {
                    Layout.fillHeight: true
                    showLabel: true
                    visible: !root.showTime
                    textPixelSize: root.textPixelSize
                }

                // spacing in the middle
                Item {
                    Layout.fillWidth: true
                }

                // system tray
                Repeater {
                    id: statusNotifierRepeater
                    model: root.statusNotifierSource

                    delegate: TaskWidget {
                        Layout.leftMargin: root.elementSpacing
                    }
                }

                // system indicators
                // using Layout.fillHeight here seems to cause polish loops, instead just define the height of the row
                RowLayout {
                    id: indicators
                    Layout.leftMargin: Kirigami.Units.smallSpacing // applets have different spacing needs
                    Layout.maximumHeight: mainRow.rowHeight

                    spacing: root.elementSpacing

                    MobileShell.SignalStrengthIndicator {
                        showLabel: false
                        visible: root.showTime
                        internetIndicator: internetIndicatorItem
                        implicitHeight: mainRow.rowHeight
                        Layout.preferredWidth: height
                    }
                    MobileShell.BluetoothIndicator {
                        implicitHeight: mainRow.rowHeight
                        Layout.preferredWidth: height
                    }
                    MobileShell.InternetIndicator {
                        id: internetIndicatorItem
                        implicitHeight: mainRow.rowHeight
                        Layout.preferredWidth: height
                    }
                    MobileShell.VolumeIndicator {
                        implicitHeight: mainRow.rowHeight
                        Layout.preferredWidth: height
                    }
                    MobileShell.BatteryIndicator {
                        spacing: root.elementSpacing
                        textPixelSize: root.textPixelSize
                        implicitHeight: mainRow.rowHeight
                        Layout.preferredWidth: height
                    }
                }
            }

            // extra row with date and mobile provider (for quicksettings panel)
            RowLayout {
                spacing: 0
                visible: root.showSecondRow
                Layout.fillWidth: true

                PlasmaComponents.Label {
                    text: Qt.formatDate(clockSource.dateTime, "ddd. MMMM d")
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: root.smallerTextPixelSize
                }

                Item { Layout.fillWidth: true }

                PlasmaComponents.Label {
                    visible: root.showTime
                    text: MobileShell.SignalStrengthInfo.label
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: root.smallerTextPixelSize
                    horizontalAlignment: Qt.AlignRight
                }
            }
        }
    }
}
