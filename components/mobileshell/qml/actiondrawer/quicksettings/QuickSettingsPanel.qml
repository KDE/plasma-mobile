/*
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami 2.12 as Kirigami
import org.kde.ksvg 1.0 as KSvg

import org.kde.plasma.core as PlasmaCore

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
    topPadding: Kirigami.Units.smallSpacing * 4
    leftPadding: Kirigami.Units.smallSpacing * 4
    rightPadding: Kirigami.Units.smallSpacing * 4
    bottomPadding: Kirigami.Units.smallSpacing * 4
    
    background: KSvg.FrameSvgItem {
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
                
                Kirigami.Theme.colorSet: Kirigami.Theme.Window
                Kirigami.Theme.inherit: false

                backgroundColor: "transparent"
                showSecondRow: false
                showDropShadow: false
                showTime: false
                
                // security reasons, system tray also doesn't work on lockscreen
                disableSystemTray: actionDrawer.restrictedPermissions
            }
            
            QuickSettings {
                id: quickSettings
                
                mode: QuickSettings.ScrollView
                width: column.width
                implicitHeight: quickSettings.fullHeight
                
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.maximumHeight: root.fullScreenHeight - root.topPadding - root.bottomPadding - statusBar.height - Kirigami.Units.smallSpacing
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

