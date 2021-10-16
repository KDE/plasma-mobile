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
    implicitHeight: expandedHeight

    signal expandRequested
    signal closeRequested
    signal closed

    property bool expandedMode: parentSlidingPanel.wideScreen

    readonly property real expandedRatio: expandedMode
                    ? 1
                    : Math.max(0, Math.min(1, (parentSlidingPanel.offset - collapsedHeight) /(expandedHeight-collapsedHeight)))

    readonly property real topEmptyAreaHeight: parentSlidingPanel.userInteracting
        ? (root.height - collapsedHeight) * (1 - expandedRatio)
        : (expandedMode ? 0 : root.height - collapsedHeight)


    readonly property real collapsedHeight: column.Layout.minimumHeight + background.margins.top + background.fixedMargins.bottom

    readonly property real expandedHeight: column.Layout.maximumHeight + background.margins.top + background.fixedMargins.bottom

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
    Layout.minimumHeight: flow.implicitHeight + PlasmaCore.Units.largeSpacing*2
    
    onClosed: quickSettingsModel.panelClosed()

    readonly property SettingsModel quickSettingsModel: SettingsModel {}
    
    PlasmaCore.FrameSvgItem {
        id: background
        implicitHeight: root.expandedHeight
        enabledBorders: parentSlidingPanel.wideScreen ? PlasmaCore.FrameSvg.AllBorders : PlasmaCore.FrameSvg.BottomBorder
        anchors.fill: parent
        imagePath: "widgets/background"

        ColumnLayout {
            id: column
            
            anchors {
                leftMargin: parent.fixedMargins.left
                rightMargin: parent.fixedMargins.right
                bottomMargin: parent.fixedMargins.bottom * (parentSlidingPanel.wideScreen ? 1 : 0.5) // HACK: fix the bottom arrow not being centered, bottom margins aren't properly calculated it seems
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            
            spacing: 0
            height: Layout.minimumHeight * (1 - root.expandedRatio) + (Layout.maximumHeight * root.expandedRatio)
            
            readonly property real cellSizeHint: PlasmaCore.Units.iconSizes.large + PlasmaCore.Units.smallSpacing * 6
            readonly property real columnWidth: Math.floor(width / Math.floor(width / cellSizeHint))
            
            // top indicators (clock, widgets, etc.)
            IndicatorsRow {
                id: indicatorsRow
                z: 1
                Layout.fillWidth: true
                Layout.preferredHeight: parentSlidingPanel.topPanelHeight
                colorGroup: PlasmaCore.Theme.NormalColorGroup
                backgroundColor: "transparent"
                showGradientBackground: false
                showDropShadow: false
            }
            
            // quicksettings list
            ColumnLayout {
                clip: expandedRatio > 0 && expandedRatio < 1 // only clip when necessary to improve performance
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: flow.Layout.minimumHeight

                spacing: 0
                Layout.topMargin: PlasmaCore.Units.largeSpacing
                Flow {
                    id: flow
                    Layout.fillWidth: true
                    Layout.minimumHeight: cellSizeHint
                    Layout.preferredHeight: implicitHeight
                    Layout.maximumHeight: (flow.cellSizeHint * Math.ceil((flow.children.length - 1) / flow.columns))

                    readonly property real cellSizeHint: PlasmaCore.Units.iconSizes.large + PlasmaCore.Units.smallSpacing * 6
                    readonly property real columns: Math.floor(width / cellSizeHint)
                    readonly property real columnWidth: Math.floor(width / columns)

                    spacing: 0

                    Repeater {
                        model: quickSettingsModel
                        delegate: Delegate {
                            id: delegateItem
                            required property var modelData
                            width: Math.max(implicitWidth + PlasmaCore.Units.smallSpacing * 2, boundingWidth)                                    
                            boundingWidth: root.expandedRatio < 0.4 
                                            ? flow.width / (flow.columns + 1)
                                            : (flow.width / (flow.columns + 1)) * (1 - root.expandedRatio) + (flow.width / flow.columns) * root.expandedRatio

                            labelOpacity: y > 0  ? 1 : root.expandedRatio
                            opacity: y <= 0 ? 1 : root.expandedRatio
                            text: modelData.text
                            icon: modelData.icon
                            enabled: modelData.enabled
                            settingsCommand: modelData.settingsCommand
                            toggleFunction: modelData.toggle

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
                            duration: PlasmaCore.Units.shortDuration
                            easing.type: Easing.Linear
                            properties: "x,y"
                        }
                    }
                }
                BrightnessItem {
                    id: brightnessSlider
                    Layout.topMargin: PlasmaCore.Units.largeSpacing
                    Layout.bottomMargin: PlasmaCore.Units.smallSpacing
                    Layout.leftMargin: PlasmaCore.Units.largeSpacing
                    Layout.rightMargin: PlasmaCore.Units.largeSpacing
                    Layout.fillWidth: true
                    
                    opacity: root.expandedRatio
                }
            }

            // bottom "handle bar"
            ColumnLayout {
                id: bottomBar
                spacing: 0
                visible: !parentSlidingPanel.wideScreen
                
                Layout.fillWidth: true
                implicitHeight: visible ? Math.round(PlasmaCore.Units.gridUnit * 1.3) : 0
                
                Kirigami.Separator {
                    Layout.fillWidth: true
                    color: PlasmaCore.Theme.disabledTextColor
                    opacity: 0.3
                }
                
                Kirigami.Icon {
                    color: PlasmaCore.Theme.disabledTextColor
                    source: expandedRatio >= 0.5 ? "go-up-symbolic" : "go-down-symbolic"
                    implicitWidth: PlasmaCore.Units.gridUnit
                    implicitHeight: width
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: Kirigami.Units.smallSpacing
                    Layout.bottomMargin: Kirigami.Units.smallSpacing
                }
                
                TapHandler {
                    onTapped: {
                        if (root.expandedMode) {
                            root.closeRequested();
                        } else {
                            root.expandRequested();
                            root.expandedMode = true;
                        }
                    }
                }
            }
        }
    }
}
