/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls
import QtGraphicalEffects 1.6

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState
import org.kde.phone.homescreen.default 1.0 as HomeScreenLib

import "private" as Private

ContainmentLayoutManager.ItemContainer {
    id: delegate

    enabled: homeScreenState.currentView === HomeScreenState.PageView || homeScreenState.currentSwipeState === HomeScreenState.SwipingAppDrawerVisibility
    
    property var homeScreenState
    
    z: dragActive ? 1 : 0

    property var modelData: typeof model !== "undefined" ? model : null

    Layout.minimumWidth: appletsLayout.cellWidth
    Layout.minimumHeight: appletsLayout.cellHeight

    key: model.applicationUniqueId
    property ContainmentLayoutManager.AppletsLayout appletsLayout
    property int reservedSpaceForLabel
    property real dragCenterX
    property real dragCenterY
    property alias iconItem: icon

    editModeCondition: ContainmentLayoutManager.ItemContainer.AfterPressAndHold

    signal launch(int x, int y, var source, string title)

    function syncDelegateGeometry() {
        if (!applicationRunning) {
            return;
        }

        if (!MobileShellState.Shell.taskSwitcherVisible) {
            HomeScreenLib.DesktopModel.setMinimizedDelegate(index, delegate);
        } else {
            HomeScreenLib.DesktopModel.unsetMinimizedDelegate(index, delegate);
        }
    }
    
    function launchApp() {
        if (modelData.applicationRunning) {
            delegate.launch(0, 0, "", modelData.applicationName);
        } else {
            delegate.launch(delegate.x + (PlasmaCore.Units.smallSpacing * 2), delegate.y + (PlasmaCore.Units.smallSpacing * 2), icon.source, modelData.applicationName);
        }

        HomeScreenLib.DesktopModel.setMinimizedDelegate(index, delegate);
        MobileShell.ShellUtil.launchApp(modelData.applicationStorageId);
    }

    readonly property bool applicationRunning: model.applicationRunning
    onApplicationRunningChanged: {
        syncDelegateGeometry();
    }
    onDragActiveChanged: {
        if (dragActive) {
            removeButton.show();
            mouseArea.enabled = true;
        }
    }
    Connections {
        target: homeScreenState
        function onCancelEditModeForItemsRequested() {
            cancelEdit()
        }
        function onXPositionChanged() {
            syncDelegateGeometry()
        }
    }
    Connections {
        target: MobileShellState.Shell
        function onTaskSwitcherVisibleChanged() {
            syncDelegateGeometry();
        }
    }
    Connections {
        target: appletsLayout
        function onAppletsLayoutInteracted() {
            removeButton.hide();
        }
    }

    contentItem: MouseArea {
        id: mouseArea
        
        // grow/shrink animation
        property real zoomScale: 1
        transform: Scale { 
            origin.x: mouseArea.width / 2; 
            origin.y: mouseArea.height / 2; 
            xScale: mouseArea.zoomScale
            yScale: mouseArea.zoomScale
        }
        
        property bool launchAppRequested: false
        
        NumberAnimation on zoomScale {
            id: shrinkAnim
            running: false
            duration: MobileShell.MobileShellSettings.animationsEnabled ? 80 : 1
            to: MobileShell.MobileShellSettings.animationsEnabled ? 0.8 : 1
            onFinished: {
                if (!mouseArea.pressed) {
                    growAnim.restart();
                }
            }
        }
        
        NumberAnimation on zoomScale {
            id: growAnim
            running: false
            duration: MobileShell.MobileShellSettings.animationsEnabled ? 80 : 1
            to: 1
            onFinished: {
                if (mouseArea.launchAppRequested) {
                    delegate.launchApp();
                    mouseArea.launchAppRequested = false;
                }
            }
        }
        
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onPressedChanged: {
            if (pressed) {
                growAnim.stop();
                shrinkAnim.restart();
            } else if (!pressed && !shrinkAnim.running) {
                growAnim.restart();
            }
        }
        // launch app handled by press animation
        onClicked: launchAppRequested = true;

        ColumnLayout {
            anchors {
                fill: parent
                leftMargin: PlasmaCore.Units.smallSpacing * 2
                topMargin: PlasmaCore.Units.smallSpacing * 2
                rightMargin: PlasmaCore.Units.smallSpacing * 2
                bottomMargin: PlasmaCore.Units.smallSpacing * 2
            }
            spacing: 0

            PlasmaCore.IconItem {
                id: icon

                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.fillWidth: true
                Layout.minimumHeight: Math.min(PlasmaCore.Units.iconSizes.large, parent.height - delegate.reservedSpaceForLabel)
                Layout.preferredHeight: Layout.minimumHeight

                usesPlasmaTheme: false
                source: modelData ? modelData.applicationIcon : ""

                Rectangle {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                    }
                    visible: model.applicationRunning
                    radius: width
                    width: PlasmaCore.Units.smallSpacing
                    height: width
                    color: PlasmaCore.Theme.highlightColor
                }
                
                // darken effect when hovered/pressed
                layer {
                    enabled: mouseArea.pressed || mouseArea.containsMouse
                    effect: ColorOverlay {
                        color: Qt.rgba(0, 0, 0, 0.3)
                    }
                }
                
                //TODO: in loader?
                Private.DelegateRemoveButton {
                    id: removeButton
                }
            }

            PC3.Label {
                id: label
                visible: text.length > 0

                Layout.fillWidth: true
                Layout.preferredHeight: delegate.reservedSpaceForLabel
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: PlasmaCore.Units.smallSpacing
                Layout.leftMargin: -parent.anchors.leftMargin + PlasmaCore.Units.smallSpacing * 2
                Layout.rightMargin: -parent.anchors.rightMargin + PlasmaCore.Units.smallSpacing * 2
                
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignTop
                maximumLineCount: 2
                elide: Text.ElideRight

                text: model.applicationName

                font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 0.8
                font.weight: Font.Bold
                color: "white"

                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 2
                    radius: 6.0
                    samples: 10
                    cached: true
                    color: Qt.rgba(0, 0, 0, 0.3)
                }
            }
            Item { Layout.fillHeight: true }
        }
    }
}
