// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts

import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.private.mobile.homescreen.folio 1.0 as Folio
import org.kde.kirigami 2.10 as Kirigami

import "./delegate"

Item {
    id: root

    property int pageNum

    property var pageModel
    property var homeScreen

    // background when in settings view (for rearranging pages)
    Rectangle {
        id: settingsViewBackground
        anchors.fill: parent
        color: Qt.rgba(255, 255, 255, 0.2)
        opacity: Folio.HomeScreenState.settingsOpenProgress
        radius: Kirigami.Units.largeSpacing
    }

    // square that shows when hovering over a spot to drop a delegate on
    PlaceholderDelegate {
        id: dragDropFeedback
        width: Folio.HomeScreenState.pageCellWidth
        height: Folio.HomeScreenState.pageCellHeight

        property var dropPosition: Folio.HomeScreenState.dragState.candidateDropPosition

        // only show if it is an empty spot on this page
        visible: Folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate &&
                    dropPosition.location === Folio.DelegateDragPosition.Pages &&
                    dropPosition.page === root.pageNum &&
                    Folio.HomeScreenState.getPageDelegateAt(root.pageNum, dropPosition.pageRow, dropPosition.pageColumn) === null

        x: dropPosition.pageColumn * Folio.HomeScreenState.pageCellWidth
        y: dropPosition.pageRow * Folio.HomeScreenState.pageCellHeight
    }

    Repeater {
        model: root.pageModel

        delegate: Item {
            id: delegate

            property Folio.FolioPageDelegate pageDelegate: model.delegate
            property int row: pageDelegate.row
            property int column: pageDelegate.column

            property var dragState: Folio.HomeScreenState.dragState

            property bool isDropPositionThis: dragState.candidateDropPosition.location === Folio.DelegateDragPosition.Pages &&
                                              dragState.candidateDropPosition.page === root.pageNum &&
                                              dragState.candidateDropPosition.pageRow === delegate.pageDelegate.row &&
                                              dragState.candidateDropPosition.pageColumn === delegate.pageDelegate.column

            property bool isAppHoveredOver: Folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate &&
                                            dragState.dropDelegate &&
                                            dragState.dropDelegate.type === Folio.FolioDelegate.Application &&
                                            isDropPositionThis

            implicitWidth: Folio.HomeScreenState.pageCellWidth
            implicitHeight: Folio.HomeScreenState.pageCellHeight
            width: Folio.HomeScreenState.pageCellWidth
            height: Folio.HomeScreenState.pageCellHeight

            x: column * Folio.HomeScreenState.pageCellWidth
            y: row * Folio.HomeScreenState.pageCellHeight

            visible: row >= 0 && row < Folio.HomeScreenState.pageRows &&
                     column >= 0 && column < Folio.HomeScreenState.pageColumns

            Loader {
                anchors.fill: parent

                sourceComponent: {
                    if (delegate.pageDelegate.type === Folio.FolioDelegate.Application) {
                        return appComponent;
                    } else if (delegate.pageDelegate.type === Folio.FolioDelegate.Folder) {
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

            Component {
                id: appComponent

                AppDelegate {
                    id: appDelegate
                    name: Folio.FolioSettings.showPagesAppLabels ? delegate.pageDelegate.application.name : ""
                    application: delegate.pageDelegate.application
                    turnToFolder: delegate.isAppHoveredOver
                    turnToFolderAnimEnabled: Folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate

                    // do not show if the drop animation is running to this delegate
                    visible: !(root.homeScreen.dropAnimationRunning && delegate.isDropPositionThis)

                    // don't show label in drag and drop mode
                    labelOpacity: delegate.opacity

                    onPressAndHold: {
                        let mappedCoords = root.homeScreen.prepareStartDelegateDrag(delegate.pageDelegate, appDelegate.delegateItem);
                        Folio.HomeScreenState.startDelegatePageDrag(
                            mappedCoords.x,
                            mappedCoords.y,
                            root.pageNum,
                            delegate.pageDelegate.row,
                            delegate.pageDelegate.column
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
                                onTriggered: root.pageModel.removeDelegate(delegate.row, delegate.column)
                            }
                        ]
                    }
                }
            }

            Component {
                id: folderComponent

                AppFolderDelegate {
                    id: appFolderDelegate
                    name: Folio.FolioSettings.showPagesAppLabels ? delegate.pageDelegate.folder.name : ""
                    folder: delegate.pageDelegate.folder

                    // do not show if the drop animation is running to this delegate, and the drop delegate is a folder
                    visible: !(root.homeScreen.dropAnimationRunning &&
                               delegate.isDropPositionThis &&
                               delegate.dragState.dropDelegate.type === Folio.FolioDelegate.Folder)

                    // don't show label in drag and drop mode
                    labelOpacity: delegate.opacity

                    appHoveredOver: delegate.isAppHoveredOver

                    onAfterClickAnimation: {
                        const pos = homeScreen.prepareFolderOpen(appFolderDelegate.contentItem);
                        Folio.HomeScreenState.openFolder(pos.x, pos.y, folder);
                    }

                    onPressAndHold: {
                        let mappedCoords = root.homeScreen.prepareStartDelegateDrag(delegate.pageDelegate, appFolderDelegate.delegateItem);
                        Folio.HomeScreenState.startDelegatePageDrag(
                            mappedCoords.x,
                            mappedCoords.y,
                            root.pageNum,
                            delegate.pageDelegate.row,
                            delegate.pageDelegate.column
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
                                onTriggered: root.pageModel.removeDelegate(delegate.row, delegate.column)
                            }
                        ]
                    }
                }
            }
        }
    }
}
