// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls as QQC2

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.private.mobileshell as MobileShell
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio

import "./private"
import "./delegate"

Folio.DelegateTouchArea {
    id: root
    property Folio.HomeScreen folio

    property var homeScreen

    // the position on the screen for animations to start from
    property real folderPositionX
    property real folderPositionY

    property Folio.FolioApplicationFolder folder: folio.HomeScreenState.currentFolder

    MobileShell.HapticsEffect {
        id: haptics
    }

    onClicked: close();

    function close() {
        folio.HomeScreenState.closeFolder();
    }

    Connections {
        target: folio.HomeScreenState

        function onFolderAboutToOpen(x, y) {
            root.folderPositionX = x - folio.HomeScreenState.viewLeftPadding;
            root.folderPositionY = y - folio.HomeScreenState.viewTopPadding;
        }
    }

    FolderViewTitle {
        id: titleText
        folio: root.folio
        width: root.width

        // have to use y instead of anchors to avoid animations
        y: Math.round(((root.height / 2) - (folderBackground.height / 2)) * 0.9 - height)
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
        folio.HomeScreenState.folderPageContentWidth = (folderBackground.width - margin * 2);
    }

    function updateContentHeight() {
        let margin = folderBackground.margin;
        folio.HomeScreenState.folderPageContentHeight = (folderBackground.height - margin * 2);
    }

    Connections {
        target: folio.HomeScreenState

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

        readonly property int gridLength: folio.HomeScreenState.folderGridLength

        readonly property int margin: Kirigami.Units.largeSpacing
        readonly property int maxLength: Math.min(root.width - Kirigami.Units.gridUnit * 4, root.height - Kirigami.Units.gridUnit * 2)

        readonly property int pageSize: Math.min(maxLength, (folio.FolioSettings.delegateIconSize + Kirigami.Units.gridUnit * 3) * gridLength + Kirigami.Units.gridUnit * 2)

        width: pageSize - margin * 2
        height: pageSize

        QQC2.PageIndicator {
            visible: count > 1
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            currentIndex: folio.HomeScreenState.currentFolderPage
            count: folio.HomeScreenState.currentFolder ? folio.HomeScreenState.currentFolder.applications.numberOfPages : 0
        }

        onWidthChanged: {
            folio.HomeScreenState.folderPageWidth = width;
            root.updateContentWidth();
            root.updateContentHeight();
        }
        onHeightChanged: {
            folio.HomeScreenState.folderPageHeight = height;
            root.updateContentWidth();
            root.updateContentHeight();
        }

        x: {
            const folderPos = root.folderPositionX;
            const centerX = (root.width / 2) - (width / 2);
            return Math.round(folderPos + (centerX - folderPos) * folio.HomeScreenState.folderOpenProgress);
        }
        y: {
            const folderPos = root.folderPositionY;
            const centerY = (root.height / 2) - (height / 2);
            return Math.round(folderPos + (centerY - folderPos) * folio.HomeScreenState.folderOpenProgress);
        }

        transform: [
            Scale {
                origin.x: 0
                origin.y: 0

                xScale: {
                    const iconSize = folio.FolioSettings.delegateIconSize;
                    const fullWidth = folderBackground.width;
                    const candidate = iconSize + (fullWidth - iconSize) * folio.HomeScreenState.folderOpenProgress;
                    return Math.max(0, Math.min(1, candidate / fullWidth));
                }
                yScale: {
                    const iconSize = folio.FolioSettings.delegateIconSize;
                    const fullHeight = folderBackground.height;
                    const candidate = iconSize + (fullHeight - iconSize) * folio.HomeScreenState.folderOpenProgress;
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
                x: folio.HomeScreenState.folderViewX

                Repeater {
                    model: root.folder ? root.folder.applications : []

                    delegate: Item {
                        id: delegate

                        readonly property var delegateModel: model.delegate
                        readonly property int index: model.index

                        readonly property int folderCellSize: folio.HomeScreenState.folderPageContentWidth / folderBackground.gridLength
                        readonly property int cellWidth: folio.HomeScreenState.pageCellWidth
                        readonly property int cellHeight: folio.HomeScreenState.pageCellHeight

                        readonly property bool outsideView: {
                            const appPosition = x + (cellWidth - folderCellSize) / 2 + folio.HomeScreenState.folderViewX;
                            return (appPosition <= -folderCellSize || appPosition >= folderBackground.width);
                        }

                        readonly property var dragState: folio.HomeScreenState.dragState
                        readonly property bool isDropPositionThis: dragState.candidateDropPosition.location === Folio.DelegateDragPosition.Folder &&
                        dragState.candidateDropPosition.folderPosition === index

                        // get the index position value so we can animate them
                        property double columnValue: model.columnIndex
                        property double rowValue: model.rowIndex
                        property double pageValue: model.pageIndex
                        Behavior on columnValue {
                            NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }
                        }
                        Behavior on rowValue {
                            NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }
                        }
                        Behavior on pageValue {
                            NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad }
                        }

                        // multiply the index values by the cell size to get the actual position
                        readonly property int positionColumn: folderCellSize * columnValue
                        readonly property int positionRow: folderCellSize * rowValue

                        x: (folderCellSize - cellWidth) / 2 + folderBackground.margin + pageValue * folderBackground.width + positionColumn
                        y: (folderCellSize - cellHeight) / 2 + folderBackground.margin + positionRow

                        implicitWidth: cellWidth
                        implicitHeight: cellHeight
                        width: cellWidth
                        height: cellHeight

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
                                folio: root.folio
                                application: delegate.delegateModel.application

                                // do not show if the drop animation is running to this delegate
                                visible: !(root.homeScreen.dropAnimationRunning && delegate.isDropPositionThis)
                                enabled: !delegate.outsideView

                                // don't show label in drag and drop mode
                                labelOpacity: delegate.opacity

                                onPressAndHold: {
                                    // prevent editing if lock layout is enabled
                                    if (folio.FolioSettings.lockLayout) return;

                                    let mappedCoords = root.homeScreen.prepareStartDelegateDrag(delegate.delegateModel, appDelegate.delegateItem);
                                    folio.HomeScreenState.startDelegateFolderDrag(
                                        mappedCoords.x,
                                        mappedCoords.y,
                                        appDelegate.pressPosition.x,
                                        appDelegate.pressPosition.y,
                                        root.folder,
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
                                            onTriggered: root.folder.removeDelegate(delegate.index)
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
}
