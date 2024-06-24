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

    // use to account for x-y positioning, because delegate x and y will include the screen margins
    property real leftMargin
    property real topMargin

    signal delegateDragRequested(var item)

    onPressAndHold: folio.HomeScreenState.openSettingsView()

    Repeater {
        model: folio.FavouritesModel

        delegate: Item {
            id: delegate

            property var delegateModel: model.delegate
            property int index: model.index

            property var dragState: folio.HomeScreenState.dragState
            property bool isDropPositionThis: dragState.candidateDropPosition.location === Folio.DelegateDragPosition.Favourites &&
                                              dragState.candidateDropPosition.favouritesPosition === delegate.index
            property bool isAppHoveredOver: folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate &&
                                            dragState.dropDelegate &&
                                            dragState.dropDelegate.type === Folio.FolioDelegate.Application &&
                                            isDropPositionThis

            // only one of them will be used, because of the anchors below
            // this is used due to the ability for the favourites bar to be in multiple locations
            x: model.xPosition - leftMargin
            y: model.xPosition - topMargin

            anchors.verticalCenter: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom ? parent.verticalCenter : undefined
            anchors.horizontalCenter: folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom ? undefined : parent.horizontalCenter

            Behavior on x {
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }
            Behavior on y {
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }

            implicitWidth: folio.HomeScreenState.pageCellWidth
            implicitHeight: folio.HomeScreenState.pageCellHeight
            width: folio.HomeScreenState.pageCellWidth
            height: folio.HomeScreenState.pageCellHeight

            Loader {
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

                Item {}
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
                        let mappedCoords = root.homeScreen.prepareStartDelegateDrag(delegate.delegateModel, appDelegate.delegateItem);
                        folio.HomeScreenState.startDelegateFavouritesDrag(
                            mappedCoords.x,
                            mappedCoords.y,
                            appDelegate.pressPosition.x,
                            appDelegate.pressPosition.y,
                            delegate.index
                        );

                        contextMenu.open();
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
