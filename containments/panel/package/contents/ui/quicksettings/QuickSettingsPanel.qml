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


    readonly property real collapsedHeight: column.Layout.minimumHeight + background.fixedMargins.top + background.fixedMargins.bottom

    readonly property real expandedHeight: column.Layout.maximumHeight + background.fixedMargins.top + background.fixedMargins.bottom

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
                bottomMargin: parent.fixedMargins.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            spacing: 0
            height: Layout.minimumHeight * (1 - root.expandedRatio) + (Layout.maximumHeight * root.expandedRatio)
           // clip: expandedRatio > 0 && expandedRatio < 1 // only clip when necessary to improve performance
            
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
            }
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

                    readonly property real cellSizeHint: units.iconSizes.large + units.smallSpacing * 6
                    readonly property real columns: Math.floor(width / cellSizeHint)
                    readonly property real columnWidth: Math.floor(width / columns)

                    spacing: 0

                    Repeater {
                        model: quickSettingsModel.model
                        delegate: Delegate {
                            id: delegateItem
                            settingsModel: quickSettingsModel
                            width: root.expandedRatio < 0.4
                                    ? Math.max(implicitWidth + PlasmaCore.Units.smallSpacing * 2, flow.width / (flow.columns + 1))
                                    : Math.max(implicitWidth + PlasmaCore.Units.smallSpacing * 2,
                                            (flow.width / (flow.columns + 1)) * (1 - root.expandedRatio) + (flow.width / flow.columns) * root.expandedRatio)

                            labelOpacity: y > 0  ? 1 : root.expandedRatio
                            opacity: y <= 0 ? 1 : root.expandedRatio

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
                    Layout.topMargin: units.largeSpacing
                    Layout.bottomMargin: units.smallSpacing
                    Layout.leftMargin: units.largeSpacing
                    Layout.rightMargin: units.largeSpacing
                    Layout.fillWidth: true
                    
                    opacity: root.expandedRatio
                }
            }

            // bottom "handle bar"
            Item {
                id: bottomBar
                Layout.fillWidth: true
                visible: !parentSlidingPanel.wideScreen
                implicitHeight: visible ? Math.round(PlasmaCore.Units.gridUnit * 1.3) : 0
                z: 1
                Kirigami.Separator {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    color: PlasmaCore.Theme.disabledTextColor
                    opacity: 0.3
                }
                Kirigami.Icon {
                    color: PlasmaCore.Theme.disabledTextColor
                    source: expandedRatio >= 0.5 ? "go-up-symbolic" : "go-down-symbolic"
                    implicitWidth: PlasmaCore.Units.gridUnit
                    implicitHeight: width
                    anchors.centerIn: parent
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
