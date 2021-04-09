/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.14
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.12 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.bluezqt 1.0 as BluezQt
import org.kde.colorcorrect 0.1 as CC
import org.kde.plasma.private.nanoshell 2.0 as NanoShell

import org.kde.plasma.components 3.0 as PC3

import "../"

Item {
    id: root
    implicitWidth: column.implicitWidth + PlasmaCore.Units.smallSpacing * 6
    implicitHeight: column.implicitHeight + PlasmaCore.Units.smallSpacing * 2

    signal closeRequested
    signal closed

    property bool expandedMode: parentSlidingPanel.wideScreen
    readonly property real expandedRatio: expandedMode ? 1 : Math.max(0, Math.min(1, (parentSlidingPanel.offset - (parentSlidingPanel.topPanelHeight + firstRowHeight) - parentSlidingPanel.topPanelHeight) / otherRowsHeight + 0.05)) // HACK: add 0.05 to prevent jumping since this height isn't exact

    readonly property real topEmptyAreaHeight: parentSlidingPanel.userInteracting
        ? (root.height - collapsedHeight) * (1 - expandedRatio)
        : (expandedMode ? 0 : root.height - collapsedHeight)
     
    readonly property real collapsedHeight: parentSlidingPanel.topPanelHeight + firstRowHeight + PlasmaCore.Units.smallSpacing * 2
    readonly property real firstRowHeight: flow.children[0].height
    readonly property real otherRowsHeight: column.implicitHeight - firstRowHeight - parentSlidingPanel.topPanelHeight
    
    Connections {
        target: root.parentSlidingPanel
        function onUserInteractingChanged() {
            if (!parentSlidingPanel.userInteracting) {
                if (root.expandedRatio > 0.7) {
                    root.expandedMode = true;
                }
            }
        }
    }

    property NanoShell.FullScreenOverlay parentSlidingPanel

    Connections {
        target: root.Window.window
        function onVisibilityChanged() {
            root.expandedMode = parentSlidingPanel.wideScreen;
        }
    }

    signal plasmoidTriggered(var applet, var id)
    Layout.minimumHeight: flow.implicitHeight + units.largeSpacing*2
    
    onClosed: quickSettingsModel.panelClosed()

    property QuickSettingsModel quickSettingsModel: QuickSettingsModel {}
    
    // shadow below panel (only if not widescreen)
    Rectangle {
        visible: !parentSlidingPanel.wideScreen
        anchors.bottom: background.bottom
        anchors.left: background.left
        anchors.right: background.right
        height: PlasmaCore.Units.gridUnit
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Qt.rgba(0, 0, 0, 0.05)
            }
            GradientStop {
                position: 1.0
                color: "transparent"
            }
        }
    }
    // shadow for bottom bar
    RectangularGlow {
        z: 1
        anchors.topMargin: 1
        anchors.fill: bottomBar
        cached: true
        glowRadius: 4
        spread: 0.2
        color: Qt.rgba(0, 0, 0, 0.1)
    }
    // shadow for whole panel (only if widescreen)
    RectangularGlow {
        visible: parentSlidingPanel.wideScreen
        anchors.topMargin: 1
        anchors.top: background.top
        anchors.left: background.left
        anchors.right: background.right
        anchors.bottom: bottomBar.bottom
        cached: true
        glowRadius: 4
        spread: 0.2
        color: Qt.rgba(0, 0, 0, 0.1)
    }
    
    // bottom "handle bar"
    Rectangle {
        id: bottomBar
        anchors.top: background.bottom
        anchors.left: background.left
        anchors.right: background.right
        color: PlasmaCore.Theme.backgroundColor
        height: Math.round(PlasmaCore.Units.gridUnit * 1.3)
        z: 1
        
        Kirigami.Icon {
            visible: !parentSlidingPanel.wideScreen
            color: PlasmaCore.Theme.disabledTextColor
            source: expandedRatio >= 1 ? "go-up-symbolic" : "go-down-symbolic"
            implicitWidth: PlasmaCore.Units.gridUnit
            implicitHeight: width
            anchors.centerIn: parent
        }
    }
    
    Rectangle {
        id: background
        color: PlasmaCore.Theme.backgroundColor
        anchors.fill: parent
        
        ColumnLayout {
            id: column
            anchors.leftMargin: PlasmaCore.Units.smallSpacing
            anchors.rightMargin: PlasmaCore.Units.smallSpacing
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 0
            clip: expandedRatio > 0 && expandedRatio < 1 // only clip when necessary to improve performance
            
            readonly property real cellSizeHint: units.iconSizes.large + units.smallSpacing * 6
            readonly property real columnWidth: Math.floor(width / Math.floor(width / cellSizeHint))
            
            IndicatorsRow {
                id: indicatorsRow
                z: 1
                Layout.fillWidth: true
                Layout.preferredHeight: parentSlidingPanel.topPanelHeight
                colorGroup: PlasmaCore.Theme.NormalColorGroup
                backgroundColor: "transparent"
                showGradientBackground: false
                showDropShadow: false
                transform: Translate {
                    y: otherRowsHeight * (1 - root.expandedRatio) - PlasmaCore.Units.smallSpacing
                }
            }
            
            Flow {
                id: flow
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.leftMargin: units.smallSpacing + (units.largeSpacing - units.smallSpacing) * root.expandedRatio
                Layout.rightMargin: units.smallSpacing + (units.largeSpacing - units.smallSpacing) * root.expandedRatio
                Layout.topMargin: units.largeSpacing
                
                readonly property real cellSizeHint: units.iconSizes.large + units.smallSpacing * 6
                readonly property real columns: Math.floor(width / cellSizeHint)
                readonly property real columnsWhenCollapsed: 1.05 // .05 to account for the fact that we have an overshoot on the panel on first flick, we don't want the movement to be jarring
                readonly property real columnWidth: Math.floor(width / (columns + (columnsWhenCollapsed - columnsWhenCollapsed * root.expandedRatio)))
                
                spacing: 0
                Repeater {
                    model: quickSettingsModel.model
                    delegate: Delegate {
                        id: delegateItem
                        settingsModel: quickSettingsModel
                        width: flow.columnWidth
                        
                        labelOpacity: y > 0  ? 1 : root.expandedRatio
                        opacity: y <= 0 ? 1 : root.expandedRatio
                        transform: Translate {
                            y: otherRowsHeight * (1 - root.expandedRatio) - PlasmaCore.Units.smallSpacing * 2
                        }

                        Connections {
                            target: delegateItem
                            onCloseRequested: root.closeRequested();
                        }
                        Connections {
                            target: root
                            onClosed: delegateItem.panelClosed();
                        }
                    }
                }

                move: Transition {
                    NumberAnimation {
                        duration: units.shortDuration
                        easing.type: Easing.Linear
                        properties: "x,y"
                    }
                }
            }
            BrightnessItem {
                id: brightnessSlider
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: units.smallSpacing
                Layout.bottomMargin: units.smallSpacing
                Layout.leftMargin: units.largeSpacing
                Layout.rightMargin: units.largeSpacing
                Layout.fillWidth: true
                
                opacity: root.expandedRatio
                transform: Translate {
                    y: otherRowsHeight * (1 - root.expandedRatio) - PlasmaCore.Units.smallSpacing * 2
                }
            }
        }
    }
}
