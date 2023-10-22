// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1

import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState
import org.kde.private.mobile.homescreen.folio 1.0 as Folio
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.kirigami 2.10 as Kirigami

import "./delegate"

Item {
    id: root

    property var homeScreen

    // use to account for x-y positioning, because delegate x and y will include the screen margins
    property real leftMargin
    property real topMargin

    signal delegateDragRequested(var item)

    Repeater {
        model: Folio.FavouritesModel

        delegate: Item {
            id: delegate

            property var delegateModel: model.delegate
            property int index: model.index

            property var dragState: Folio.HomeScreenState.dragState
            property bool isDropPositionThis: dragState.candidateDropPosition.location === Folio.DelegateDragPosition.Favourites &&
                                              dragState.candidateDropPosition.favouritesPosition === delegate.index
            property bool isAppHoveredOver: Folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate &&
                                            dragState.dropDelegate &&
                                            dragState.dropDelegate.type === Folio.FolioDelegate.Application &&
                                            isDropPositionThis

            // only one of them will be used, because of the anchors below
            // this is used due to the ability for the favourites bar to be in multiple locations
            x: model.xPosition - leftMargin
            y: model.xPosition - topMargin

            anchors.verticalCenter: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom ? parent.verticalCenter : undefined
            anchors.horizontalCenter: Folio.HomeScreenState.favouritesBarLocation === Folio.HomeScreenState.Bottom ? undefined : parent.horizontalCenter

            Behavior on x {
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }
            Behavior on y {
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }

            implicitWidth: Folio.HomeScreenState.pageCellWidth
            implicitHeight: Folio.HomeScreenState.pageCellHeight
            width: Folio.HomeScreenState.pageCellWidth
            height: Folio.HomeScreenState.pageCellHeight

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
                    application: delegate.delegateModel.application
                    name: Folio.FolioSettings.showFavouritesAppLabels ? delegate.delegateModel.application.name : ""
                    shadow: true

                    turnToFolder: delegate.isAppHoveredOver
                    turnToFolderAnimEnabled: Folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate

                    // do not show if the drop animation is running to this delegate
                    visible: !(root.homeScreen.dropAnimationRunning && delegate.isDropPositionThis)

                    // don't show label in drag and drop mode
                    labelOpacity: delegate.opacity

                    onPressAndHold: {
                        let mappedCoords = root.homeScreen.prepareStartDelegateDrag(delegate.delegateModel, appDelegate.delegateItem);
                        Folio.HomeScreenState.startDelegateFavouritesDrag(
                            mappedCoords.x,
                            mappedCoords.y,
                            delegate.index
                        );

                        contextMenu.open();
                    }

                    onPressAndHoldReleased: {
                        // cancel the event if the delegate is not dragged
                        if (Folio.HomeScreenState.swipeState === Folio.HomeScreenState.AwaitingDraggingDelegate) {
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
                            target: Folio.HomeScreenState

                            function onSwipeStateChanged() {
                                if (Folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate) {
                                    contextMenu.close();
                                }
                            }
                        }

                        actions: [
                            Kirigami.Action {
                                icon.name: "emblem-favorite"
                                text: i18n("Remove")
                                onTriggered: Folio.FavouritesModel.removeEntry(delegate.index)
                            }
                        ]
                    }
                }
            }

            Component {
                id: folderComponent

                AppFolderDelegate {
                    id: appFolderDelegate
                    shadow: true
                    folder: delegate.delegateModel.folder
                    name: Folio.FolioSettings.showFavouritesAppLabels ? delegate.delegateModel.folder.name : ""

                    // do not show if the drop animation is running to this delegate, and the drop delegate is a folder
                    visible: !(root.homeScreen.dropAnimationRunning &&
                               delegate.isDropPositionThis &&
                               delegate.dragState.dropDelegate.type === Folio.FolioDelegate.Folder)

                    appHoveredOver: delegate.isAppHoveredOver

                    // don't show label in drag and drop mode
                    labelOpacity: delegate.opacity

                    onAfterClickAnimation: {
                        const pos = homeScreen.prepareFolderOpen(appFolderDelegate.contentItem);
                        Folio.HomeScreenState.openFolder(pos.x, pos.y, delegate.delegateModel.folder);
                    }

                    onPressAndHold: {
                        let mappedCoords = root.homeScreen.prepareStartDelegateDrag(delegate.delegateModel, appFolderDelegate.delegateItem);
                        Folio.HomeScreenState.startDelegateFavouritesDrag(
                            mappedCoords.x,
                            mappedCoords.y,
                            delegate.index
                        );

                        contextMenu.open();
                    }

                    onPressAndHoldReleased: {
                        // cancel the event if the delegate is not dragged
                        if (Folio.HomeScreenState.swipeState === Folio.HomeScreenState.AwaitingDraggingDelegate) {
                            root.homeScreen.cancelDelegateDrag();
                        }
                    }

                    onRightMousePress: {
                        contextMenu.open();
                    }

                    // TODO don't use loader, and move outside to a page to make it more performant
                    ContextMenuLoader {
                        id: contextMenu

                        // close menu when drag starts
                        Connections {
                            target: Folio.HomeScreenState

                            function onSwipeStateChanged() {
                                if (Folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate) {
                                    contextMenu.close();
                                }
                            }
                        }

                        actions: [
                            Kirigami.Action {
                                icon.name: "emblem-favorite"
                                text: i18n("Remove")
                                onTriggered: Folio.FavouritesModel.removeEntry(delegate.index)
                            }
                        ]
                    }
                }
            }
        }
    }
}
