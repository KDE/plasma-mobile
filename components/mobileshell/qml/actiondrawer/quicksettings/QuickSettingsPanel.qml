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
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import "../../statusbar" as StatusBar
import "../../components" as Components
import "../../widgets" as Widgets
import "../"

/**
 * Quick settings panel for landscape view (right sidebar).
 * For the portrait view quicksettings container, see QuickSettingsDrawer.
 */
Components.BaseItem {
    id: root
    
    required property var actionDrawer
    
    required property real fullHeight
    
    /**
     * Height of panel when first pulled down.
     */
    readonly property real minimizedHeight: bottomPadding + topPadding + statusBar.height + quickSettings.rowHeight
    
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
        clip: true
        
        // use container item so that our column doesn't get stretched if base item is anchored
        ColumnLayout {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: root.fullHeight
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
            }
            
            PlasmaComponents.ScrollView {
                id: scrollView
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.maximumHeight: root.fullHeight - root.topPadding - root.bottomPadding - statusBar.height - mediaWidget.fullHeight - PlasmaCore.Units.smallSpacing
                Layout.maximumWidth: column.width
                
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                clip: true
                
                QuickSettings {
                    id: quickSettings
                    width: column.width
                    implicitHeight: quickSettings.fullHeight
                    
                    actionDrawer: root.actionDrawer
                    minimizedViewProgress: 0
                    fullViewProgress: 1
                }
            }
            
            Item { Layout.fillHeight: true }
        }
        
        Widgets.MediaControlsWidget {
            id: mediaWidget
            property real fullHeight: visible ? height + PlasmaCore.Units.smallSpacing * 6 : 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: column.bottom
            anchors.bottomMargin: root.bottomPadding * 2 + PlasmaCore.Units.smallSpacing * 2 // HACK: can't figure out a cleaner way to position
        }
        
        Handle {
            id: handle
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
        }
    }
}

