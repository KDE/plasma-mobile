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
    implicitHeight: background.implicitHeight

    signal expandRequested
    signal closeRequested
    signal closed

    property bool expandedMode: parentSlidingPanel.wideScreen
    readonly property real expandedRatio: expandedMode
                    ? 1
                    // This counts also all spacings in form of Lyout.topMargin that some elements has
                    : Math.max(0, Math.min(1, (parentSlidingPanel.offset - firstRowHeight - indicatorsRow.height - Kirigami.Units.largeSpacing - Kirigami.Units.smallSpacing * 2 - bottomBar.height - background.margins.top -background.fixedMargins.bottom) / otherRowsHeight + 0.05)) // HACK: add 0.05 to prevent jumping since this height isn't exact

    readonly property real topEmptyAreaHeight: parentSlidingPanel.userInteracting
        ? (root.height - collapsedHeight) * (1 - expandedRatio)
        : (expandedMode ? 0 : root.height - collapsedHeight)
     
    readonly property real collapsedHeight: parentSlidingPanel.topPanelHeight + firstRowHeight + bottomBar.height + background.margins.top + background.fixedMargins.bottom
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
    
    
    // bottom "handle bar"
    Item {
        id: bottomBar
        anchors {
            bottom: background.bottom
            left: background.left
            right: background.right
            leftMargin: background.fixedMargins.left
            rightMargin: background.fixedMargins.right
            bottomMargin: background.fixedMargins.bottom
        }
        visible: !parentSlidingPanel.wideScreen
        height: visible ? Math.round(PlasmaCore.Units.gridUnit * 1.3) : 0
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
    
    PlasmaCore.FrameSvgItem {
        id: background
        implicitHeight: column.implicitHeight + bottomBar.height + margins.top + fixedMargins.bottom
        enabledBorders: parentSlidingPanel.wideScreen ? PlasmaCore.FrameSvg.AllBorders : PlasmaCore.FrameSvg.BottomBorder
        anchors.fill: parent
        imagePath: "widgets/background"

        ColumnLayout {
            id: column
            anchors {
                leftMargin: parent.fixedMargins.left
                rightMargin: parent.fixedMargins.right
                bottomMargin: parent.fixedMargins.bottom + bottomBar.height
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
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
                    y: otherRowsHeight * (1 - root.expandedRatio)
                }
            }
            
            Flow {
                id: flow
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.leftMargin: root.expandedRatio < 0.4 ? -background.fixedMargins.left * (1 - root.expandedRatio) : 0
                Layout.rightMargin: root.expandedRatio < 0.4 ? -background.fixedMargins.right * (1 - root.expandedRatio) : 0
                Layout.topMargin: units.largeSpacing
                
                readonly property real cellSizeHint: units.iconSizes.large + units.smallSpacing * 6
                readonly property real columns: Math.floor(width / cellSizeHint)
                readonly property real columnsWhenCollapsed: 1.05 // .05 to account for the fact that we have an overshoot on the panel on first flick, we don't want the movement to be jarring
                readonly property real columnWidth: Math.floor(width / columns)
                
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
