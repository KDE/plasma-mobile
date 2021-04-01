/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls
import QtGraphicalEffects 1.6

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.phone.homescreen 1.0

import "private" as Private

ContainmentLayoutManager.ItemContainer {
    id: delegate

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

        if (!MobileShell.HomeScreenControls.taskSwitcherVisible) {
            plasmoid.nativeInterface.applicationListModel.setMinimizedDelegate(index, delegate);
        } else {
            plasmoid.nativeInterface.applicationListModel.unsetMinimizedDelegate(index, delegate);
        }
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
        target: mainFlickable
        function onCancelEditModeForItemsRequested() {
            cancelEdit()
        }
        function onContentYChanged() {
            syncDelegateGeometry()
        }
    }
    Connections {
        target: MobileShell.HomeScreenControls
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
        onClicked: {
            if (modelData.applicationRunning) {
                delegate.launch(0, 0, "", modelData.applicationName);
            } else {
                delegate.launch(delegate.x + (PlasmaCore.Units.smallSpacing * 2), delegate.y + (PlasmaCore.Units.smallSpacing * 2), icon.source, modelData.applicationName);
            }

            plasmoid.nativeInterface.applicationListModel.setMinimizedDelegate(index, delegate);
            plasmoid.nativeInterface.applicationListModel.runApplication(modelData.applicationStorageId);
        }

        //preventStealing: true
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
                    color: theme.highlightColor
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
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignTop
                Layout.leftMargin: -parent.anchors.leftMargin + PlasmaCore.Units.smallSpacing
                Layout.rightMargin: -parent.anchors.rightMargin + PlasmaCore.Units.smallSpacing
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignTop
                maximumLineCount: 2
                elide: Text.ElideRight

                text:  model.applicationName

                //FIXME: export smallestReadableFont
                font.pointSize: theme.defaultFont.pointSize * 0.9
                color: "white"//model.applicationLocation == ApplicationListModel.Desktop ? "white" : theme.textColor

                layer.enabled: true//model.applicationLocation == ApplicationListModel.Desktop
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 2
                    radius: 8.0
                    samples: 16
                    cached: true
                    color: Qt.rgba(0, 0, 0, 1)
                }
            }
            Item {Layout.fillHeight:true}
        }
    }
}
