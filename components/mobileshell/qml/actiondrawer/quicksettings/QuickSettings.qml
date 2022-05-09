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
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

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
    readonly property int minimizedColumns: Math.round(Util.applyMinMaxRange(5, 8, width / intendedMinimizedColumnWidth))
    readonly property real minimizedColumnWidth: Math.floor(width / minimizedColumns)
    
    readonly property real rowHeight: columnWidth * 0.7
    readonly property real fullHeight: fullView.implicitHeight
    
    readonly property real intendedColumnWidth: 120
    readonly property real intendedMinimizedColumnWidth: PlasmaCore.Units.gridUnit * 3 + PlasmaCore.Units.largeSpacing
    readonly property real minimizedRowHeight: PlasmaCore.Units.gridUnit * 3 + PlasmaCore.Units.largeSpacing
    
    property real minimizedViewProgress: 0
    property real fullViewProgress: 1

    readonly property MobileShell.QuickSettingsModel quickSettingsModel: MobileShell.QuickSettingsModel {}
    
    readonly property real pageHeight: (Window.height * 60/100)
    readonly property int rowCount: Math.floor(pageHeight / rowHeight)
    readonly property int columnCount: Math.floor(width/columnWidth)
    readonly property int pageSize: rowCount * columnCount
    readonly property int quickSettingsCount: quickSettingsModel.count
        
    function resetSwipeView() {
        if (MobileShell.Shell.orientation === MobileShell.Shell.Portrait) {
            pageLoader.item.view.currentIndex = 0;
        }
    }

    // return to the first page when the action drawer is closed
    Connections {
        target: actionDrawer

        onOpenedChanged: {
            if(!actionDrawer.opened) {
                resetSwipeView();
            }
        }
    }
    
    // view when fully open
    ColumnLayout {
        id: fullView
        height: 1
        opacity: root.fullViewProgress
        visible: opacity !== 0
        transform: Translate { y: (1 - fullView.opacity) * root.rowHeight }
        
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        
        // Dynamically loads the appropriate view
        Loader {
            id: pageLoader
            
            Layout.fillWidth: true
            
            asynchronous: true
            sourceComponent: MobileShell.Shell.orientation === MobileShell.Shell.Portrait ? swipeViewComponent : scrollViewComponent
        }
        
        BrightnessItem {
            id: brightnessItem
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
            model: MobileShell.PaginateModel {
                sourceModel: quickSettingsModel
                pageSize: minimizedColumns
            }
            delegate: Components.BaseItem {
                required property var modelData
                
                implicitHeight: root.minimizedRowHeight
                implicitWidth: root.minimizedColumnWidth
                horizontalPadding: (width - PlasmaCore.Units.gridUnit * 3) / 2
                verticalPadding: (height - PlasmaCore.Units.gridUnit * 3) / 2
                
                contentItem: QuickSettingsMinimizedDelegate {
                    restrictedPermissions: actionDrawer.restrictedPermissions
                    
                    text: modelData.text
                    status: modelData.status
                    icon: modelData.icon
                    enabled: modelData.enabled
                    settingsCommand: modelData.settingsCommand
                    toggleFunction: modelData.toggle
                    
                    onCloseRequested: {
                        actionDrawer.close();
                    }
                }
            }
        }
    }
    
    // Loaded when in portrait mode
    Component {
        id: swipeViewComponent
        
        ColumnLayout {
            readonly property var view: swipeView
            
            SwipeView {
                id: swipeView
                
                Layout.fillWidth: true
                Layout.preferredHeight: rowCount * rowHeight
                
                Repeater {
                    model: Math.ceil(quickSettingsCount / pageSize)
                    delegate: Flow {
                        id: flow
                        spacing: 0
                        
                        required property int index
                        
                        Repeater {
                            model: MobileShell.PaginateModel {
                                sourceModel: quickSettingsModel
                                pageSize: root.pageSize
                                firstItem: pageSize * flow.index
                            }
                            delegate: Loader {
                                required property var modelData
                                
                                asynchronous: true
                                
                                sourceComponent: quickSettingComponent
                            }
                        }
                    }
                }
            }
            
            Loader {
                id: indicatorLoader
                
                Layout.alignment: Qt.AlignCenter
                Layout.topMargin: PlasmaCore.Units.smallSpacing
                Layout.leftMargin: PlasmaCore.Units.smallSpacing
                Layout.rightMargin: PlasmaCore.Units.smallSpacing
                
                // Avoid wasting space when not loaded
                Layout.maximumHeight: active ? item.implicitHeight : 0
                
                active: swipeView.count > 1 ? true: false
                asynchronous: true
                
                sourceComponent: PageIndicator {
                    count: swipeView.count
                    currentIndex: swipeView.currentIndex
                        
                    delegate: Rectangle {
                        implicitWidth: 8
                        implicitHeight: count > 1 ? 8 : 0

                        radius: parent.width / 2
                        color: PlasmaCore.Theme.disabledTextColor

                        opacity: index === currentIndex ? 0.95 : 0.45
                    }
                }
            }
        }
    }
    
    // Loaded when in landscape mode
    Component {
        id: scrollViewComponent
        
        Flickable {
            clip: true
            height: pageHeight
            
            contentWidth: parent.width
            contentHeight: quickSettingsCount / columnCount * rowHeight
            
            Flow {                
                width: parent.width
                
                height: quickSettingsCount / columnCount * rowHeight
                
                spacing: 0
                                    
                Repeater {
                    model: quickSettingsModel
                    delegate: Loader {
                        required property var modelData
                        
                        asynchronous: true
                        
                        sourceComponent: quickSettingComponent
                    }
                }
            }
        }
    }
    
    // Quick setting component
    Component {
        id: quickSettingComponent
        
        Components.BaseItem {
                                                
            height: root.rowHeight
            width: root.columnWidth
            padding: PlasmaCore.Units.smallSpacing

            contentItem: QuickSettingsFullDelegate {
                restrictedPermissions: actionDrawer.restrictedPermissions
                
                text: modelData.text
                status: modelData.status
                icon: modelData.icon
                enabled: modelData.enabled
                settingsCommand: modelData.settingsCommand
                toggleFunction: modelData.toggle
                
                onCloseRequested: {
                    actionDrawer.close();
                }
            }
        }
    }
}
