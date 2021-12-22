/*
 *   SPDX-FileCopyrightText: 2014 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore

import "../../components" as Components
import "../../components/util.js" as Util

/**
 * Quick settings elements layout, change the height to clip.
 */
Item {
    id: root
    clip: true
    
    required property var actionDrawer
    
    readonly property real columns: Math.round(Util.applyMinMaxRange(3, 6, width / intendedColumnWidth))
    readonly property real columnWidth: Math.floor(width / columns)
    readonly property real minimizedColumns: Math.round(Util.applyMinMaxRange(5, 8, width / intendedMinimizedColumnWidth))
    readonly property real minimizedColumnWidth: Math.floor(width / minimizedColumns)
    
    readonly property real rowHeight: columnWidth * 0.7
    readonly property real fullHeight: fullView.implicitHeight
    
    readonly property real intendedColumnWidth: 120
    readonly property real intendedMinimizedColumnWidth: PlasmaCore.Units.gridUnit * 3 + PlasmaCore.Units.largeSpacing
    readonly property real minimizedRowHeight: PlasmaCore.Units.gridUnit * 3 + PlasmaCore.Units.largeSpacing
    
    property real minimizedViewProgress: 0
    property real fullViewProgress: 1
    
    readonly property SettingsModel quickSettingsModel: SettingsModel {
        actionDrawer: root.actionDrawer
    }
    
    // view when fully open
    ColumnLayout {
        id: fullView
        opacity: root.fullViewProgress
        visible: opacity !== 0
        transform: Translate { y: (1 - fullView.opacity) * root.rowHeight }
        
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        
        // TODO add pages
        Flow {
            id: flow
            spacing: 0
            Layout.fillWidth: true
            
            Repeater {
                model: root.quickSettingsModel
                delegate: Components.BaseItem {
                    required property var modelData
                    
                    height: root.rowHeight
                    width: root.columnWidth
                    padding: PlasmaCore.Units.smallSpacing
                    
                    contentItem: QuickSettingsFullDelegate {
                        text: modelData.text
                        status: modelData.status
                        icon: modelData.icon
                        enabled: modelData.enabled
                        settingsCommand: modelData.settingsCommand
                        toggleFunction: modelData.toggle
                    }
                }
            }
        }
        
        BrightnessItem {
            id: brightnessItem
            Layout.topMargin: PlasmaCore.Units.smallSpacing * 2
            Layout.bottomMargin: PlasmaCore.Units.smallSpacing * 2
            Layout.leftMargin: PlasmaCore.Units.smallSpacing
            Layout.rightMargin: PlasmaCore.Units.smallSpacing
            Layout.fillWidth: true
        }
    }
    
    // view when in minimized mode
    RowLayout {
        id: minimizedView
        spacing: 0
        opacity: root.minimizedViewProgress
        visible: opacity !== 0
        transform: Translate { y: (1 - minimizedView.opacity) * -root.rowHeight }
        
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        
        Repeater {
            model: root.quickSettingsModel
            delegate: Components.BaseItem {
                required property var modelData
                required property var index
                
                implicitHeight: root.minimizedRowHeight
                implicitWidth: root.minimizedColumnWidth
                horizontalPadding: (width - PlasmaCore.Units.gridUnit * 3) / 2
                verticalPadding: (height - PlasmaCore.Units.gridUnit * 3) / 2
                visible: index <= root.minimizedColumns
                
                contentItem: QuickSettingsMinimizedDelegate {
                    text: modelData.text
                    status: modelData.status
                    icon: modelData.icon
                    enabled: modelData.enabled
                    settingsCommand: modelData.settingsCommand
                    toggleFunction: modelData.toggle
                }
            }
        }
    }
}
