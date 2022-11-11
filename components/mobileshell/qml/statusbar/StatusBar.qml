/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */


import QtQuick 2.12
import QtQuick.Controls 2.12 as Controls
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState

import "indicators" as Indicators

Item {
    id: root
    
    /**
     * The color group used for status bar elements.
     */
    required property var colorGroup
    
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
    
    property alias colorScopeColor: icons.backgroundColor
    property alias applets: appletIconsRow
    
    readonly property real textPixelSize: 11
    readonly property real smallerTextPixelSize: 9
    readonly property real elementSpacing: PlasmaCore.Units.smallSpacing * 1.5
    
    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
        intervalAlignment: PlasmaCore.Types.AlignToMinute
    }
    
    property alias statusNotifierSource: statusNotifierSourceLoader.item
    
    Loader {
        id: statusNotifierSourceLoader
        active: !disableSystemTray
        sourceComponent: PlasmaCore.DataSource {
            id: statusNotifierSource
            engine: "statusnotifieritem"
            interval: 0
            onSourceAdded: {
                connectSource(source)
            }
            Component.onCompleted: {
                connectedSources = sources
            }
        }
    }

    DropShadow {
        anchors.fill: icons
        visible: showDropShadow
        cached: true
        horizontalOffset: 0
        verticalOffset: 1
        radius: 6.0
        samples: 17
        color: Qt.rgba(0,0,0,0.6)
        source: icons
    }

    // screen top panel
    PlasmaCore.ColorScope {
        id: icons
        z: 1
        colorGroup: root.colorGroup
        anchors.fill: parent
        
        Controls.Control {
            id: control
            topPadding: PlasmaCore.Units.smallSpacing
            bottomPadding: PlasmaCore.Units.smallSpacing
            rightPadding: PlasmaCore.Units.smallSpacing * 3
            leftPadding: PlasmaCore.Units.smallSpacing * 3
            
            anchors.fill: parent
            background: Rectangle {
                color: backgroundColor
            }
            
            contentItem: ColumnLayout {
                spacing: PlasmaCore.Units.smallSpacing / 2
                
                RowLayout {
                    id: row
                    Layout.fillWidth: true
                    Layout.maximumHeight: MobileShellState.TopPanelControls.panelHeight - control.topPadding - control.bottomPadding
                    spacing: 0
                    
                    // clock
                    ClockText {
                        visible: root.showTime
                        Layout.fillHeight: true
                        font.pixelSize: textPixelSize
                        source: timeSource
                    }
                    
                    Indicators.SignalStrengthIndicator {
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
                        model: PlasmaCore.SortFilterModel {
                            id: filteredStatusNotifiers
                            filterRole: "Title"
                            sourceModel: PlasmaCore.DataModel {
                                dataSource: statusNotifierSource ? statusNotifierSource : null
                            }
                        }

                        delegate: TaskWidget {
                            Layout.leftMargin: root.elementSpacing
                        }
                    }
                    
                    // applet indicators
                    RowLayout {
                        id: appletIconsRow
                        Layout.leftMargin: root.elementSpacing
                        Layout.fillHeight: true
                        spacing: root.elementSpacing
                        visible: children.length > 0
                    }
                    
                    // system indicators
                    RowLayout {
                        id: indicators
                        Layout.leftMargin: PlasmaCore.Units.smallSpacing // applets have different spacing needs
                        Layout.fillHeight: true
                        spacing: root.elementSpacing

                        Indicators.SignalStrengthIndicator {
                            Layout.fillHeight: true
                            showLabel: false
                            visible: root.showTime
                            internetIndicator: internetIndicatorItem
                        }
                        Indicators.BluetoothIndicator { 
                            Layout.fillHeight: true
                        }
                        Indicators.InternetIndicator {
                            id: internetIndicatorItem
                            Layout.fillHeight: true
                        }
                        Indicators.VolumeIndicator { 
                            Layout.fillHeight: true
                        }
                        Indicators.BatteryIndicator {
                            spacing: root.elementSpacing
                            textPixelSize: root.textPixelSize
                            Layout.fillHeight: true
                        }
                    }
                }
                
                // extra row with date and mobile provider (for quicksettings panel)
                RowLayout {
                    spacing: 0
                    visible: root.showSecondRow
                    Layout.fillWidth: true
                    
                    PlasmaComponents.Label {
                        text: Qt.formatDate(timeSource.data.Local.DateTime, "ddd. MMMM d")
                        color: PlasmaCore.ColorScope.disabledTextColor
                        font.pixelSize: root.smallerTextPixelSize
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    PlasmaComponents.Label {
                        property var signalStrengthInfo: MobileShell.SignalStrengthInfo {}
                        
                        visible: root.showTime
                        text: signalStrengthInfo.label
                        color: PlasmaCore.ColorScope.disabledTextColor
                        font.pixelSize: root.smallerTextPixelSize
                        horizontalAlignment: Qt.AlignRight
                    }
                }
            }
        }
    }
}
