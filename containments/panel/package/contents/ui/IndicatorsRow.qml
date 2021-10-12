/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */


import QtQuick 2.12
import QtQuick.Controls 2.12 as Controls
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.workspace.components 2.0 as PlasmaWorkspace
import org.kde.taskmanager 0.1 as TaskManager

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import "LayoutManager.js" as LayoutManager

import "indicators" as Indicators

Item {
    id: indicatorsRow
    required property var colorGroup
    required property bool showDropShadow
    required property color backgroundColor
    
    property bool showSecondRow: false // show extra row with date and mobile provider
    
    property alias colorScopeColor: icons.backgroundColor
    property alias applets: appletIconsRow
    
    property real textPixelSize: PlasmaCore.Units.gridUnit * 0.6
    property real elementSpacing: PlasmaCore.Units.smallSpacing * 1.5
    
    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
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
        colorGroup: indicatorsRow.colorGroup
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
                    Layout.maximumHeight: MobileShell.TopPanelControls.panelHeight - control.topPadding - control.bottomPadding
                    spacing: 0
                    
                    // clock
                    PlasmaComponents.Label {
                        id: clock
                        property bool is24HourTime: plasmoid.nativeInterface.isSystem24HourFormat
                        Layout.fillHeight: true
                        
                        text: Qt.formatTime(timeSource.data.Local.DateTime, is24HourTime ? "h:mm" : "h:mm ap")
                        color: PlasmaCore.ColorScope.textColor
                        verticalAlignment: Qt.AlignVCenter
                        font.pixelSize: textPixelSize

                        TapHandler {
                            onTapped: {
                                plasmoid.nativeInterface.launchApp("org.kde.kclock");
                            }
                        }
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
                                dataSource: statusNotifierSource
                            }
                        }

                        delegate: TaskWidget {
                            Layout.leftMargin: indicatorsRow.elementSpacing
                        }
                    }
                    
                    // applet indicators
                    RowLayout {
                        id: appletIconsRow
                        Layout.leftMargin: indicatorsRow.elementSpacing
                        Layout.fillHeight: true
                        spacing: indicatorsRow.elementSpacing
                        visible: children.length > 0
                    }
                    
                    // system indicators
                    RowLayout {
                        id: indicators
                        Layout.leftMargin: PlasmaCore.Units.smallSpacing // applets have different spacing needs
                        Layout.fillHeight: true
                        spacing: indicatorsRow.elementSpacing

                        Indicators.SignalStrength {
                            provider: signalStrengthProvider
                            Layout.fillHeight: true
                        }
                        Indicators.Bluetooth { 
                            provider: bluetoothProvider 
                            Layout.fillHeight: true
                        }
                        Indicators.Wifi { 
                            provider: wifiProvider 
                            Layout.fillHeight: true
                        }
                        Indicators.Volume { 
                            provider: volumeProvider 
                            Layout.fillHeight: true
                        }
                        Indicators.Battery {
                            provider: batteryProvider
                            spacing: indicatorsRow.elementSpacing
                            labelHeight: textPixelSize
                            Layout.fillHeight: true
                        }
                    }
                }
                
                // extra row with date and mobile provider (for quicksettings panel)
                RowLayout {
                    spacing: 0
                    visible: indicatorsRow.showSecondRow
                    Layout.fillWidth: true
                    
                    PlasmaComponents.Label {
                        text: Qt.formatDate(timeSource.data.Local.DateTime, "ddd. MMMM d")
                        color: PlasmaCore.ColorScope.disabledTextColor
                        font.pixelSize: indicatorsRow.textPixelSize * 0.8
                    }
                    Item { Layout.fillWidth: true }
                    PlasmaComponents.Label {
                        text: signalStrengthProvider.label
                        color: PlasmaCore.ColorScope.disabledTextColor
                        font.pixelSize: indicatorsRow.textPixelSize * 0.8
                        horizontalAlignment: Qt.AlignRight
                    }
                }
            }
        }
    }
}
