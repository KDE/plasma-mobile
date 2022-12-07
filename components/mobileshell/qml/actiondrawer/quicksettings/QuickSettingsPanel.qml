/*
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtGraphicalEffects 1.12

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import "../../statusbar" as StatusBar
import "../../components" as Components
import "../"

/**
 * Quick settings panel for landscape view (right sidebar).
 * For the portrait view quicksettings container, see QuickSettingsDrawer.
 */
Components.BaseItem {
    id: root
    
    required property var actionDrawer
    
    required property real fullScreenHeight
    
    /**
     * Implicit height of the contents of the panel.
     */
    readonly property real contentImplicitHeight: column.implicitHeight
    
    // we need extra padding since the background side border is enabled
    topPadding: PlasmaCore.Units.smallSpacing * 4
    leftPadding: PlasmaCore.Units.smallSpacing * 4
    rightPadding: PlasmaCore.Units.smallSpacing * 4
    bottomPadding: PlasmaCore.Units.smallSpacing * 4
    
    background: PlasmaCore.FrameSvgItem {
        enabledBorders: PlasmaCore.FrameSvg.AllBorders
        imagePath: "widgets/background"
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
            
            StatusBar.StatusBar {
                id: statusBar
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5
                Layout.maximumHeight: Kirigami.Units.gridUnit * 1.5
                
                colorGroup: PlasmaCore.Theme.NormalColorGroup
                backgroundColor: "transparent"
                showSecondRow: false
                showDropShadow: false
                showTime: false
                
                // security reasons, system tray also doesn't work on lockscreen
                disableSystemTray: actionDrawer.restrictedPermissions
            }
            
            QuickSettings {
                id: quickSettings
                
                width: column.width
                implicitHeight: quickSettings.fullHeight
                
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.maximumHeight: root.fullScreenHeight - root.topPadding - root.bottomPadding - statusBar.height - PlasmaCore.Units.smallSpacing
                Layout.maximumWidth: column.width
                
                actionDrawer: root.actionDrawer
                minimizedViewProgress: 0
                fullViewProgress: 1
            }
            
            Item { Layout.fillHeight: true }
        }
        
        Handle {
            id: handle
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
        }
    }
}

