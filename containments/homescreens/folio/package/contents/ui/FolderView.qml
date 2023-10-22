// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls as QQC2

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.private.mobile.homescreen.folio 1.0 as Folio

import "./delegate"

Folio.DelegateTouchArea {
    id: root

    property var homeScreen

    // the position on the screen for animations to start from
    property real folderPositionX
    property real folderPositionY

    property Folio.FolioApplicationFolder folder: Folio.HomeScreenState.currentFolder

    onClicked: close();

    function close() {
        Folio.HomeScreenState.closeFolder();
    }

    Connections {
        target: Folio.HomeScreenState

        function onFolderAboutToOpen(x, y) {
            root.folderPositionX = x - Folio.HomeScreenState.viewLeftPadding;
            root.folderPositionY = y - Folio.HomeScreenState.viewRightPadding;
        }
    }

    FolderViewTitle {
        id: titleText
        width: root.width

        // have to use y instead of anchors to avoid animations
        y: Math.round((root.height / 2) - (folderBackground.height / 2) - Kirigami.Units.gridUnit - height)
        anchors.left: parent.left
        anchors.right: parent.right

        folder: root.folder

        opacity: (root.opacity === 1) ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: Kirigami.Units.shortDuration }
        }
    }

    function updateContentWidth() {
        let margin = folderBackground.margin;
        let columns = Math.floor((folderBackground.width - margin * 2) / Folio.HomeScreenState.pageCellWidth);
        Folio.HomeScreenState.folderPageContentWidth = columns * Folio.HomeScreenState.pageCellWidth;
    }

    function updateContentHeight() {
        let margin = folderBackground.margin;
        let rows = Math.floor((folderBackground.height - margin * 2) / Folio.HomeScreenState.pageCellHeight);
        Folio.HomeScreenState.folderPageContentHeight = rows * Folio.HomeScreenState.pageCellHeight;
    }

    Connections {
        target: Folio.HomeScreenState

        function onPageCellWidthChanged() {
            root.updateContentWidth();
            root.updateContentHeight();
        }

        function onPageCellHeightChanged() {
            root.updateContentWidth();
            root.updateContentHeight();
        }
    }

    Rectangle {
        id: folderBackground
        color: Qt.rgba(255, 255, 255, 0.3)
        radius: Kirigami.Units.gridUnit

        readonly property real margin: Kirigami.Units.largeSpacing
        readonly property real maxLength: Math.min(root.width * 0.9, root.height * 0.9)

        width: {
            let perRow = 0;
            if (root.width < root.height) {
                perRow = Math.floor((maxLength - margin * 2) / Folio.HomeScreenState.pageCellWidth);
            } else {
                // try to get the same number of rows as columns
                perRow = Math.floor((maxLength - margin * 2) / Folio.HomeScreenState.pageCellHeight);
            }
            return Math.min(root.width * 0.9, perRow * Folio.HomeScreenState.pageCellWidth + margin * 2);
        }
        height: {
            let perRow = 0;
            if (root.width < root.height) {
                // try to get the same number of rows as columns
                perRow = Math.floor((maxLength - margin * 2) / Folio.HomeScreenState.pageCellWidth);
            } else {
                perRow = Math.floor((maxLength - margin * 2) / Folio.HomeScreenState.pageCellHeight);
            }
            return Math.min(root.height * 0.9, perRow * Folio.HomeScreenState.pageCellHeight + margin * 2);
        }

        onWidthChanged: {
            Folio.HomeScreenState.folderPageWidth = width;
            root.updateContentHeight();
            root.updateContentHeight();
        }
        onHeightChanged: {
            Folio.HomeScreenState.folderPageHeight = height;
            root.updateContentWidth();
            root.updateContentHeight();
        }

        x: {
            const folderPos = root.folderPositionX;
            const centerX = (root.width / 2) - (width / 2);
            return Math.round(folderPos + (centerX - folderPos) * Folio.HomeScreenState.folderOpenProgress);
        }
        y: {
            const folderPos = root.folderPositionY;
            const centerY = (root.height / 2) - (height / 2);
            return Math.round(folderPos + (centerY - folderPos) * Folio.HomeScreenState.folderOpenProgress);
        }

        transform: [
            Scale {
                origin.x: 0
                origin.y: 0

                xScale: {
                    const iconSize = Folio.FolioSettings.delegateIconSize;
                    const fullWidth = folderBackground.width;
                    const candidate = iconSize + (fullWidth - iconSize) * Folio.HomeScreenState.folderOpenProgress;
                    return Math.max(0, Math.min(1, candidate / fullWidth));
                }
                yScale: {
                    const iconSize = Folio.FolioSettings.delegateIconSize;
                    const fullHeight = folderBackground.height;
                    const candidate = iconSize + (fullHeight - iconSize) * Folio.HomeScreenState.folderOpenProgress;
                    return Math.max(0, Math.min(1, candidate / fullHeight));
                }
            }
        ]

        MouseArea {
            id: captureTouches
            anchors.fill: parent

            // clip the pages
            layer.enabled: true

            Item {
                id: contentContainer
                x: Folio.HomeScreenState.folderViewX

                Repeater {
                    model: root.folder ? root.folder.applications : []

                    delegate: Item {
                        id: delegate

                        property var delegateModel: model.delegate
                        property int index: model.index

                        property var dragState: Folio.HomeScreenState.dragState
                        property bool isDropPositionThis: dragState.candidateDropPosition.location === Folio.DelegateDragPosition.Folder &&
                                                          dragState.candidateDropPosition.folderPosition === index

                        x: model.xPosition
                        y: model.yPosition

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
                            id: delegateLoader
                            anchors.fill: parent

                            sourceComponent: {
                                if (delegate.delegateModel.type === Folio.FolioDelegate.Application) {
                                    return appComponent;
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
                                application: delegate.delegateModel.application

                                // do not show if the drop animation is running to this delegate
                                visible: !(root.homeScreen.dropAnimationRunning && delegate.isDropPositionThis)

                                // don't show label in drag and drop mode
                                labelOpacity: delegate.opacity

                                onPressAndHold: {
                                    let mappedCoords = root.homeScreen.prepareStartDelegateDrag(delegate.delegateModel, appDelegate.delegateItem);
                                    Folio.HomeScreenState.startDelegateFolderDrag(
                                        mappedCoords.x,
                                        mappedCoords.y,
                                        root.folder,
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
                                            onTriggered: root.folder.removeApp(delegate.index)
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    QQC2.PageIndicator {
        visible: count > 1
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

        // have to use y instead of anchors to avoid animations
        y: Math.round((root.height / 2) + (folderBackground.height / 2) + Kirigami.Units.largeSpacing)
        anchors.horizontalCenter: parent.horizontalCenter

        currentIndex: Folio.HomeScreenState.currentFolderPage
        count: Folio.HomeScreenState.currentFolder ? Folio.HomeScreenState.currentFolder.applications.numberOfPages : 0

        opacity: (root.opacity === 1) ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: Kirigami.Units.shortDuration }
        }
    }
}
