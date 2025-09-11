// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQml.Models

import org.kde.plasma.components 3.0 as PC3
import org.kde.draganddrop as DragDrop
import org.kde.plasma.plasmoid

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell
import plasma.applet.org.kde.plasma.mobile.homescreen.halcyon as Halcyon

MobileShell.GridView {
    id: root
    property MobileShell.MaskManager maskManager
    required property var searchWidget

    // don't set anchors.margins since we want everywhere to be draggable
    required property bool twoColumn

    signal openConfigureRequested()
    signal requestOpenFolder(Halcyon.ApplicationFolder folder)

    // search widget open gesture
    property bool openingSearchWidget: false
    property bool canOpenSearchWidget: false
    property real oldVerticalOvershoot: verticalOvershoot

    onVerticalOvershootChanged: {
        if (dragging && canOpenSearchWidget && verticalOvershoot < 0) {
            if (!openingSearchWidget) {
                if (oldVerticalOvershoot === 0) {
                    openingSearchWidget = true;
                    root.searchWidget.startGesture();
                }
            } else {
                let offset = -(verticalOvershoot - oldVerticalOvershoot);
                root.searchWidget.updateGestureOffset(-offset);
            }
        }
        oldVerticalOvershoot = verticalOvershoot;
    }
    onDraggingChanged: {
        if (dragging) {
            canOpenSearchWidget = root.contentY <= 0;
        } else if (!dragging && openingSearchWidget) {
            openingSearchWidget = false;
            root.searchWidget.endGesture();
        }
    }

    // open wallpaper menu when held on click
    TapHandler {
        onLongPressed: root.openConfigureRequested()
    }

    header: MobileShell.BaseItem {
        topPadding: Math.round(root.height * 0.2)
        bottomPadding: Kirigami.Units.gridUnit
        // leftPadding: root.leftMargin
        // rightPadding: root.rightMargin
        implicitWidth: root.width

        background: Rectangle {
            color: 'transparent'
            TapHandler { onLongPressed: root.openConfigureRequested() } // open wallpaper menu when held on click
        }
        contentItem: Clock {}
    }

    Keys.onReturnPressed: currentItem.appDelegate.launch()
    model: DelegateModel {
        id: visualModel
        model: Plasmoid.pinnedModel

        delegate: Item {
            id: delegateRoot
            property int visualIndex: DelegateModel.itemsIndex
            property alias appDelegate: appDelegate

            width: root.cellWidth
            height: root.cellHeight

            function moveDragToCurrentPos(from, to) {
                if (from !== to) {
                    visualModel.items.move(from, to);
                    Plasmoid.pinnedModel.moveEntry(from, to);
                }
            }

            function topDragEnter(drag) {
                if (transitionAnim.running || appDelegate.drag.active) return; // don't do anything when reordering

                let fromIndex = drag.source.visualIndex;
                let delegateVisualIndex = appDelegate.visualIndex;
                let reorderIndex = -1;

                if (fromIndex < delegateVisualIndex) { // dragged item from above
                    // move to spot above
                    reorderIndex = delegateVisualIndex - (root.twoColumn ? 2 : 1);
                } else { // dragged item from below
                    // move to current spot
                    reorderIndex = delegateVisualIndex;
                }

                if (reorderIndex >= 0 && reorderIndex < root.count) {
                    delegateRoot.moveDragToCurrentPos(fromIndex, reorderIndex)
                }
            }

            function bottomDragEnter(drag) {
                if (transitionAnim.running || appDelegate.drag.active) return; // don't do anything when reordering

                let fromIndex = drag.source.visualIndex;
                let delegateVisualIndex = appDelegate.visualIndex;
                let reorderIndex = -1;

                if (fromIndex < delegateVisualIndex) { // dragged item from above
                    // move to current spot
                    reorderIndex = delegateVisualIndex;
                } else { // dragged item from below
                    // move to spot below
                    reorderIndex = delegateVisualIndex + (root.twoColumn ? 2 : 1);
                }

                if (reorderIndex >= 0 && reorderIndex < root.count) {
                    delegateRoot.moveDragToCurrentPos(fromIndex, reorderIndex);
                }
            }

            // top drop area
            DropArea {
                id: topDropArea
                anchors.top: parent.top
                anchors.left: leftDropArea.right
                anchors.right: rightDropArea.left
                height: delegateRoot.height * 0.2
                onEntered: (drag) => delegateRoot.topDragEnter(drag)
            }

            // bottom drop area
            DropArea {
                id: bottomDropArea
                anchors.bottom: parent.bottom
                anchors.left: leftDropArea.right
                anchors.right: rightDropArea.left
                height: delegateRoot.height * 0.2
                onEntered: (drag) => delegateRoot.bottomDragEnter(drag)
            }

            // left drop area
            DropArea {
                id: leftDropArea
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                anchors.left: parent.left
                width: root.twoColumn ? Math.max(appDelegate.leftPadding, delegateRoot.width * 0.1) : 0
                onEntered: (drag) => delegateRoot.topDragEnter(drag)
            }

            // right drop area
            DropArea {
                id: rightDropArea
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                anchors.right: parent.right
                width: root.twoColumn ? Math.max(appDelegate.rightPadding, delegateRoot.width * 0.1) : 0
                onEntered: (drag) => delegateRoot.bottomDragEnter(drag)
            }

            // folder drop area
            DropArea {
                anchors.top: topDropArea.bottom
                anchors.bottom: bottomDropArea.top
                anchors.left: leftDropArea.right
                anchors.right: rightDropArea.left
                onEntered: (drag) => {
                    if (transitionAnim.running || appDelegate.drag.active || drag.source.isFolder) return; // don't do anything when reordering
                    folderAnim.to = 1;
                    folderAnim.restart();
                }
                onExited: () => {
                    folderAnim.to = 0;
                    folderAnim.restart();
                }
                onDropped: (drop) => {
                    if (transitionAnim.running || appDelegate.drag.active || drag.source.isFolder) return; // don't do anything when reordering
                    if (appDelegate.isFolder) {
                        Plasmoid.pinnedModel.addAppToFolder(drop.source.visualIndex, appDelegate.visualIndex);
                    } else {
                        Plasmoid.pinnedModel.createFolderFromApps(drop.source.visualIndex, appDelegate.visualIndex);
                    }
                    folderAnim.to = 0;
                    folderAnim.restart();
                }

                NumberAnimation {
                    id: folderAnim
                    target: appDelegate
                    properties: "dragFolderAnimationProgress"
                    duration: Kirigami.Units.shortDuration
                }
            }

            // actual visual delegate
            FavoritesAppDelegate {
                id: appDelegate
                maskManager: root.maskManager
                visualIndex: delegateRoot.visualIndex

                isFolder: model.isFolder
                folder: model.folder
                application: model.application

                onFolderOpenRequested: root.requestOpenFolder(model.folder)

                menuActions: [
                    Kirigami.Action {
                        icon.name: "emblem-favorite"
                        text: i18n("Remove from favourites")
                        onTriggered: Plasmoid.pinnedModel.removeEntry(model.index)
                    }
                ]

                implicitWidth: root.cellWidth
                implicitHeight: visible ? root.cellHeight : 0

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                states: [
                    State {
                        when: appDelegate.drag.active
                        ParentChange {
                            target: appDelegate
                            parent: root
                        }

                        AnchorChanges {
                            target: appDelegate
                            anchors.horizontalCenter: undefined
                            anchors.verticalCenter: undefined
                        }
                    }
                ]
            }
        }
    }

    // animations
    displaced: Transition {
        NumberAnimation {
            id: transitionAnim
            properties: "x,y"
            easing.type: Easing.OutQuad
        }
    }

    ColumnLayout {
        id: placeholder
        spacing: Kirigami.Units.gridUnit
        visible: root.count == 0
        opacity: 0.9

        anchors.fill: parent
        anchors.topMargin: Math.round(swipeView.height * 0.2) - (root.contentY - root.originY)
        anchors.leftMargin: root.leftMargin
        anchors.rightMargin: root.rightMargin

        layer.enabled: true
        layer.effect: MobileShell.TextDropShadow {}

        Kirigami.Icon {
            id: icon
            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
            implicitWidth: Kirigami.Units.iconSizes.large
            implicitHeight: width
            source: "arrow-left"
            color: "white"
        }

        Kirigami.Heading {
            Layout.fillWidth: true
            Layout.maximumWidth: placeholder.width * 0.75
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            color: "white"
            level: 3
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            text: i18n("Add applications to your favourites so they show up here.")
        }

        TapHandler {
            onLongPressed: root.openConfigureRequested()
        }
    }
}
