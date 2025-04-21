// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.private.mobile.homescreen.folio 1.0 as Folio
import org.kde.kirigami as Kirigami

import "./delegate"
import "./private"

Item {
    id: root
    property Folio.HomeScreen folio

    property int pageNum

    property var pageModel
    property var homeScreen

    // background when in settings view (for rearranging pages)
    Rectangle {
        id: settingsViewBackground
        anchors.fill: parent
        color: Qt.rgba(255, 255, 255, 0.2)
        opacity: folio.HomeScreenState.settingsOpenProgress
        radius: Kirigami.Units.largeSpacing
    }

    // square that shows when hovering over a spot to drop a delegate on
    PlaceholderDelegate {
        id: dragDropFeedback
        folio: root.folio
        width: folio.HomeScreenState.pageCellWidth
        height: folio.HomeScreenState.pageCellHeight

        property var dropPosition: folio.HomeScreenState.dragState.candidateDropPosition
        property var dropDelegate: folio.HomeScreenState.dragState.dropDelegate
        property bool dropDelegateIsWidget: dropDelegate && dropDelegate.type === Folio.FolioDelegate.Widget

        // only show if it is an empty spot on this page
        visible: folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate &&
                    dropPosition.location === Folio.DelegateDragPosition.Pages &&
                    dropPosition.page === root.pageNum &&
                    !dropDelegateIsWidget &&
                    folio.HomeScreenState.getPageDelegateAt(root.pageNum, dropPosition.pageRow, dropPosition.pageColumn) === null

        x: dropPosition.pageColumn * folio.HomeScreenState.pageCellWidth
        y: dropPosition.pageRow * folio.HomeScreenState.pageCellHeight
    }

    // square that shows when a widget hovers over a spot to drop a delegate on
    Rectangle {
        id: widgetDragDropFeedback
        width: (dropDelegateIsWidget ? dropDelegate.widget.gridWidth : 0) * folio.HomeScreenState.pageCellWidth
        height: (dropDelegateIsWidget ? dropDelegate.widget.gridHeight : 0) * folio.HomeScreenState.pageCellHeight

        property var dropPosition: folio.HomeScreenState.dragState.candidateDropPosition
        property var dropDelegate: folio.HomeScreenState.dragState.dropDelegate
        property bool dropDelegateIsWidget: dropDelegate && dropDelegate.type === Folio.FolioDelegate.Widget

        // only show if the widget can be placed here
        visible: folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate &&
                    dropPosition.location === Folio.DelegateDragPosition.Pages &&
                    dropPosition.page === root.pageNum &&
                    dropDelegateIsWidget &&
                    pageModel.canAddDelegate(dropPosition.pageRow, dropPosition.pageColumn, dropDelegate)

        radius: Kirigami.Units.cornerRadius
        color: Qt.rgba(255, 255, 255, 0.3)

        x: dropPosition.pageColumn * folio.HomeScreenState.pageCellWidth
        y: dropPosition.pageRow * folio.HomeScreenState.pageCellHeight

        layer.enabled: true
        layer.effect: DelegateShadow {}
    }

    // repeater of all delegates in the page
    Repeater {
        model: root.pageModel

        delegate: Item {
            id: delegate

            property Folio.FolioPageDelegate pageDelegate: model.delegate
            property int row: pageDelegate.row
            property int column: pageDelegate.column

            property var dragState: folio.HomeScreenState.dragState

            property bool isDropPositionThis: dragState.candidateDropPosition.location === Folio.DelegateDragPosition.Pages &&
                                              dragState.candidateDropPosition.page === root.pageNum &&
                                              dragState.candidateDropPosition.pageRow === delegate.pageDelegate.row &&
                                              dragState.candidateDropPosition.pageColumn === delegate.pageDelegate.column

            property bool isAppHoveredOver: folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate &&
                                            dragState.dropDelegate &&
                                            dragState.dropDelegate.type === Folio.FolioDelegate.Application &&
                                            isDropPositionThis

            implicitWidth: loader.item ? loader.item.implicitWidth : 0
            implicitHeight: loader.item ? loader.item.implicitHeight : 0
            width: loader.item ? loader.item.width : 0
            height: loader.item ? loader.item.height : 0

            x: column * folio.HomeScreenState.pageCellWidth
            y: row * folio.HomeScreenState.pageCellHeight

            visible: row >= 0 && row < folio.HomeScreenState.pageRows &&
                     column >= 0 && column < folio.HomeScreenState.pageColumns

            // called when we want to delete this delegate
            function removeSelf() {
                // remove from model
                root.pageModel.removeDelegate(delegate.row, delegate.column);

                // TODO: this doesn't work, because the removeDelegate calls removes this entire object and the calls fail
                // // delete empty pages at the end, and snap position to page that exists
                // folio.PageListModel.deleteEmptyPagesAtEnd();
                // folio.HomeScreenState.snapPage();
            }

            Loader {
                id: loader
                anchors.top: parent.top
                anchors.left: parent.left

                sourceComponent: {
                    if (delegate.pageDelegate.type === Folio.FolioDelegate.Application) {
                        return appComponent;
                    } else if (delegate.pageDelegate.type === Folio.FolioDelegate.Folder) {
                        return folderComponent;
                    } else if (delegate.pageDelegate.type === Folio.FolioDelegate.Widget) {
                        return widgetComponent;
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
                    folio: root.folio
                    name: folio.FolioSettings.showPagesAppLabels ? delegate.pageDelegate.application.name : ""
                    application: delegate.pageDelegate.application
                    turnToFolder: delegate.isAppHoveredOver
                    turnToFolderAnimEnabled: folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate

                    implicitWidth: folio.HomeScreenState.pageCellWidth
                    implicitHeight: folio.HomeScreenState.pageCellHeight
                    width: folio.HomeScreenState.pageCellWidth
                    height: folio.HomeScreenState.pageCellHeight

                    // do not show if the drop animation is running to this delegate
                    visible: !(root.homeScreen.dropAnimationRunning && delegate.isDropPositionThis)

                    // don't show label in drag and drop mode
                    labelOpacity: delegate.opacity

                    onPressAndHold: {
                        // prevent editing if lock layout is enabled
                        if (folio.FolioSettings.lockLayout) return;

                        let mappedCoords = root.homeScreen.prepareStartDelegateDrag(delegate.pageDelegate, appDelegate.delegateItem);
                        folio.HomeScreenState.startDelegatePageDrag(
                            mappedCoords.x,
                            mappedCoords.y,
                            appDelegate.pressPosition.x,
                            appDelegate.pressPosition.y,
                            root.pageNum,
                            delegate.pageDelegate.row,
                            delegate.pageDelegate.column
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
                                enabled: !folio.FolioSettings.lockLayout
                                onTriggered: delegate.removeSelf()
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
                    name: folio.FolioSettings.showPagesAppLabels ? delegate.pageDelegate.folder.name : ""
                    folder: delegate.pageDelegate.folder

                    implicitWidth: folio.HomeScreenState.pageCellWidth
                    implicitHeight: folio.HomeScreenState.pageCellHeight
                    width: folio.HomeScreenState.pageCellWidth
                    height: folio.HomeScreenState.pageCellHeight

                    // do not show if the drop animation is running to this delegate, and the drop delegate is a folder
                    visible: !(root.homeScreen.dropAnimationRunning &&
                               delegate.isDropPositionThis &&
                               delegate.dragState.dropDelegate.type === Folio.FolioDelegate.Folder)

                    // don't show label in drag and drop mode
                    labelOpacity: delegate.opacity

                    appHoveredOver: delegate.isAppHoveredOver

                    onAfterClickAnimation: {
                        const pos = homeScreen.prepareFolderOpen(appFolderDelegate.contentItem);
                        folio.HomeScreenState.openFolder(pos.x, pos.y, folder);
                    }

                    onPressAndHold: {
                        // prevent editing if lock layout is enabled
                        if (folio.FolioSettings.lockLayout) return;

                        let mappedCoords = root.homeScreen.prepareStartDelegateDrag(delegate.pageDelegate, appFolderDelegate.delegateItem);
                        folio.HomeScreenState.startDelegatePageDrag(
                            mappedCoords.x,
                            mappedCoords.y,
                            appFolderDelegate.pressPosition.x,
                            appFolderDelegate.pressPosition.y,
                            root.pageNum,
                            delegate.pageDelegate.row,
                            delegate.pageDelegate.column
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
                                enabled: !folio.FolioSettings.lockLayout
                                onTriggered: deleteDialog.open()
                            }
                        ]

                        ConfirmDeleteFolderDialogLoader {
                            id: deleteDialog
                            parent: root.homeScreen
                            onAccepted: delegate.removeSelf()
                        }
                    }
                }
            }

            Component {
                id: widgetComponent

                WidgetDelegate {
                    id: widgetDelegate
                    folio: root.folio

                    // don't reparent applet if the drop animation is running to this delegate
                    // background: there is only one "visual" instance of the widget, once this delegate loads
                    //             it will reparent it to here (but we don't want it to happen while the drop animation is running)
                    property bool suppressAppletReparent: (root.homeScreen.currentlyDraggedWidget === delegate.pageDelegate.widget)
                                                            && delegate.isDropPositionThis

                    visible: !suppressAppletReparent
                    widget: suppressAppletReparent ? null : delegate.pageDelegate.widget

                    onStartEditMode: (pressPoint) => {
                        // prevent editing if lock layout is enabled
                        if (folio.FolioSettings.lockLayout) return;

                        let mappedCoords = root.homeScreen.prepareStartDelegateDrag(delegate.pageDelegate, widgetDelegate);
                        folio.HomeScreenState.startDelegatePageDrag(
                            mappedCoords.x,
                            mappedCoords.y,
                            pressPoint.x - mappedCoords.x,
                            pressPoint.y - mappedCoords.y,
                            root.pageNum,
                            delegate.pageDelegate.row,
                            delegate.pageDelegate.column
                        );

                        widgetConfig.startOpen();
                    }

                    onPressReleased: {
                        // cancel the event if the delegate is not dragged
                        if (folio.HomeScreenState.swipeState === Folio.HomeScreenState.AwaitingDraggingDelegate) {
                            folio.HomeScreenState.cancelDelegateDrag();
                            widgetConfig.fullyOpen();
                        }
                    }

                    layer.enabled: widgetDelegate.editMode && folio.FolioSettings.lockLayout === false
                    layer.effect: DarkenEffect {}

                    PC3.ToolTip {
                        visible: widgetDelegate.editMode && pressed
                        text: i18n('Release to configure, drag to move')
                    }

                    WidgetDelegateConfig {
                        id: widgetConfig
                        folio: root.folio
                        homeScreen: root.homeScreen

                        pageModel: root.pageModel
                        pageDelegate: delegate.pageDelegate
                        widget: delegate.pageDelegate.widget

                        pageNum: root.pageNum
                        row: delegate.row
                        column: delegate.column

                        widgetWidth: widgetDelegate.widgetWidth
                        widgetHeight: widgetDelegate.widgetHeight
                        widgetX: delegate.x + root.anchors.leftMargin + root.homeScreen.leftMargin
                        widgetY: delegate.y + root.anchors.topMargin + root.homeScreen.topMargin

                        topWidgetBackgroundPadding: widgetDelegate.topWidgetBackgroundPadding
                        bottomWidgetBackgroundPadding: widgetDelegate.bottomWidgetBackgroundPadding
                        leftWidgetBackgroundPadding: widgetDelegate.leftWidgetBackgroundPadding
                        rightWidgetBackgroundPadding: widgetDelegate.rightWidgetBackgroundPadding

                        anchors.fill: parent

                        onRemoveRequested: {
                            if (widget.applet) {
                                widget.destroyApplet();
                            }
                            delegate.removeSelf();
                        }

                        onClosed: widgetDelegate.editMode = false
                    }
                }
            }
        }
    }
}
