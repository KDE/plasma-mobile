// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1

import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.private.mobile.homescreen.folio 1.0 as Folio
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.kirigami 2.10 as Kirigami

import "./private"
import "./delegate"

MouseArea {
    id: root
    property Folio.HomeScreen folio

    property var homeScreen

    signal delegateDragRequested(var item)

    onPressAndHold: {
        folio.HomeScreenState.openSettingsView();
        haptics.buttonVibrate();
    }

    MobileShell.HapticsEffect {
        id: haptics
    }

    // creates the favourites bar mask layer for the folder icons
    // only in use when the favourites bar background in trunned off
    property Component maskComponent: Item {
        id: maskComponent
        anchors.fill: parent

        // icon mask template component
        component IconMask : ColumnLayout {
            id: icon
            required property Item item
            property bool widget: false
            property bool turnToFolder: false
            spacing: 0

            implicitWidth: item ? item.implicitWidth : 0
            implicitHeight: item ? item.implicitHeight : 0
            width: item ? item.width : 0
            height: item ? item.height : 0

            x: item ? item.x : 0
            y: item ? item.y : 0

            property real scaleAmount: icon.turnToFolder ? 1.2 : 1.0

            Behavior on scaleAmount { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad } }

            Item {
                Layout.minimumWidth: widget ? parent.width : folio.FolioSettings.delegateIconSize
                Layout.minimumHeight: widget ? parent.height : folio.FolioSettings.delegateIconSize

                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                Layout.preferredHeight: Layout.minimumHeight

                Rectangle {
                    id: rect
                    radius: Kirigami.Units.cornerRadius
                    anchors.fill: parent

                    transform: Scale {
                        origin.x: rect.width / 2
                        origin.y: rect.height / 2
                        xScale: icon.scaleAmount
                        yScale: icon.scaleAmount
                    }
                }
            }

            Item {
                Layout.preferredHeight: folio.HomeScreenState.pageDelegateLabelHeight
                Layout.topMargin: folio.HomeScreenState.pageDelegateLabelSpacing
                visible: !widget
            }
        }

        // loop though and create a layer mask for all the icons in the favourites bar
        Repeater {
            model: folio.FavouritesModel
            delegate: Item {
                property var maskDelegate: repeater.itemAt(index)

                Loader {
                    id: maskLoader
                    active: folio.FolioSettings.wallpaperBlurEffect > 1
                    asynchronous: true
                    anchors.top: parent.top
                    anchors.left: parent.left

                    sourceComponent: {
                        if (!maskDelegate) {
                            return noneComponent;
                        } else if (maskDelegate.delegateModel.type === Folio.FolioDelegate.Application) {
                            return appComponent;
                        } else if (maskDelegate.delegateModel.type === Folio.FolioDelegate.Folder) {
                            return folderComponent;
                        } else {
                            return noneComponent;
                        }
                    }
                }

                Component {
                    id: noneComponent

                    Item {}
                }

                // blur mask for behind icons when a app is hovered over it and it is turning into a folder
                Component {
                    id: appComponent

                    IconMask {
                        id: folder
                        item: maskDelegate
                        visible: item.visible && item.componentItem.visible && scaleAmount > 1

                        turnToFolder: item.isAppHoveredOver
                    }
                }

                // blur mask for folders
                Component {
                    id: folderComponent

                    IconMask {
                        id: folder
                        item: maskDelegate
                        visible: item.visible && item.componentItem.visible

                        turnToFolder: item.isAppHoveredOver

                        transform: Scale {
                            origin.x: maskDelegate.width / 2;
                            origin.y: maskDelegate.height / 2;
                            xScale: maskDelegate.componentItem.zoomScale;
                            yScale: maskDelegate.componentItem.zoomScale;
                        }
                    }
                }
            }
        }
    }

    Repeater {
        id: repeater
        model: folio.FavouritesModel

        delegate: Item {
            id: delegate

            readonly property var delegateModel: model.delegate
            readonly property int index: model.index

            readonly property var dragState: folio.HomeScreenState.dragState
            readonly property bool isDropPositionThis: dragState.candidateDropPosition.location === Folio.DelegateDragPosition.Favourites &&
                                              dragState.candidateDropPosition.favouritesPosition === delegate.index
            readonly property bool isAppHoveredOver: folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate &&
                                            dragState.dropDelegate &&
                                            dragState.dropDelegate.type === Folio.FolioDelegate.Application &&
                                            isDropPositionThis

            readonly property bool isLocationBottom: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom

            // get the normalized index position value from the center so we can animate it
            property double fromCenterValue: model.index - (repeater.count / 2)
            Behavior on fromCenterValue {
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad; }
            }

            // multiply the 'fromCenterValue' by the cell size to get the actual position
            readonly property int centerPosition: (isLocationBottom ? folio.HomeScreenState.pageCellWidth : folio.HomeScreenState.pageCellHeight) * fromCenterValue

            x: isLocationBottom ? centerPosition + parent.width / 2 : (parent.width - width) / 2
            y: isLocationBottom ? (parent.height - height) / 2 : parent.height / 2 - centerPosition - folio.HomeScreenState.pageCellHeight

            implicitWidth: folio.HomeScreenState.pageCellWidth
            implicitHeight: folio.HomeScreenState.pageCellHeight
            width: folio.HomeScreenState.pageCellWidth
            height: folio.HomeScreenState.pageCellHeight

            property var componentItem: loader.item

            Loader {
                id: loader
                anchors.fill: parent

                sourceComponent: {
                    if (delegate.delegateModel.type === Folio.FolioDelegate.Application) {
                        return appComponent;
                    } else if (delegate.delegateModel.type === Folio.FolioDelegate.Folder) {
                        return folderComponent;
                    } else {
                        // ghost entry
                        return placeholderComponent;
                    }
                }
            }

            Component {
                id: placeholderComponent

                // square that shows when hovering over a spot to drop a delegate on (ghost entry)
                PlaceholderDelegate {
                    id: dragDropFeedback
                    folio: root.folio
                    width: folio.HomeScreenState.pageCellWidth
                    height: folio.HomeScreenState.pageCellHeight
                }
            }

            Component {
                id: appComponent

                AppDelegate {
                    id: appDelegate
                    folio: root.folio
                    application: delegate.delegateModel.application
                    name: folio.FolioSettings.showFavouritesAppLabels ? delegate.delegateModel.application.name : ""
                    shadow: true

                    turnToFolder: delegate.isAppHoveredOver
                    turnToFolderAnimEnabled: folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate

                    // do not show if the drop animation is running to this delegate
                    visible: !(root.homeScreen.dropAnimationRunning && delegate.isDropPositionThis)

                    // don't show label in drag and drop mode
                    labelOpacity: delegate.opacity

                    onPressAndHold: {
                        // prevent editing if lock layout is enabled
                        if (folio.FolioSettings.lockLayout) return;

                        let mappedCoords = root.homeScreen.prepareStartDelegateDrag(delegate.delegateModel, appDelegate.delegateItem);
                        folio.HomeScreenState.startDelegateFavouritesDrag(
                            mappedCoords.x,
                            mappedCoords.y,
                            appDelegate.pressPosition.x,
                            appDelegate.pressPosition.y,
                            delegate.index
                        );

                        contextMenu.open();
                        haptics.buttonVibrate();
                    }

                    onPressAndHoldReleased: {
                        // cancel the event if the delegate is not dragged
                        if (folio.HomeScreenState.swipeState === Folio.HomeScreenState.AwaitingDraggingDelegate) {
                            homeScreen.cancelDelegateDrag();
                        }
                    }

                    onRightMousePress: {
                        contextMenu.open();
                    }

                    ContextMenuLoader {
                        id: contextMenu

                        // close menu when drag starts
                        Connections {
                            target: folio.HomeScreenState

                            function onSwipeStateChanged() {
                                if (folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate) {
                                    contextMenu.close();
                                }
                            }
                        }

                        actions: [
                            Kirigami.Action {
                                icon.name: "emblem-favorite"
                                text: i18n("Remove")
                                enabled: !folio.FolioSettings.lockLayout
                                onTriggered: folio.FavouritesModel.removeEntry(delegate.index)
                            }
                        ]
                    }
                }
            }

            Component {
                id: folderComponent

                AppFolderDelegate {
                    id: appFolderDelegate
                    folio: root.folio
                    shadow: true
                    folder: delegate.delegateModel.folder
                    name: folio.FolioSettings.showFavouritesAppLabels ? delegate.delegateModel.folder.name : ""

                    // do not show if the drop animation is running to this delegate, and the drop delegate is a folder
                    visible: !(root.homeScreen.dropAnimationRunning &&
                               delegate.isDropPositionThis &&
                               delegate.dragState.dropDelegate.type === Folio.FolioDelegate.Folder)

                    appHoveredOver: delegate.isAppHoveredOver

                    // don't show label in drag and drop mode
                    labelOpacity: delegate.opacity

                    onAfterClickAnimation: {
                        const pos = homeScreen.prepareFolderOpen(appFolderDelegate.contentItem);
                        folio.HomeScreenState.openFolder(pos.x, pos.y, delegate.delegateModel.folder);
                    }

                    onPressAndHold: {
                        let mappedCoords = root.homeScreen.prepareStartDelegateDrag(delegate.delegateModel, appFolderDelegate.delegateItem);
                        folio.HomeScreenState.startDelegateFavouritesDrag(
                            mappedCoords.x,
                            mappedCoords.y,
                            appFolderDelegate.pressPosition.x,
                            appFolderDelegate.pressPosition.y,
                            delegate.index
                        );

                        contextMenu.open();
                        haptics.buttonVibrate();
                    }

                    onPressAndHoldReleased: {
                        // cancel the event if the delegate is not dragged
                        if (folio.HomeScreenState.swipeState === Folio.HomeScreenState.AwaitingDraggingDelegate) {
                            root.homeScreen.cancelDelegateDrag();
                        }
                    }

                    onRightMousePress: {
                        contextMenu.open();
                    }

                    ContextMenuLoader {
                        id: contextMenu

                        // close menu when drag starts
                        Connections {
                            target: folio.HomeScreenState

                            function onSwipeStateChanged() {
                                if (folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate) {
                                    contextMenu.close();
                                }
                            }
                        }

                        actions: [
                            Kirigami.Action {
                                icon.name: "emblem-favorite"
                                text: i18n("Remove")
                                onTriggered: deleteDialog.open()
                            }
                        ]

                        ConfirmDeleteFolderDialogLoader {
                            id: deleteDialog
                            parent: root.homeScreen
                            onAccepted: folio.FavouritesModel.removeEntry(delegate.index)
                        }
                    }
                }
            }
        }
    }
}
