/*
    SPDX-FileCopyrightText: 2026 Micah Stanley <stanleymicah@proton.me>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Effects

import org.kde.kirigami as Kirigami

import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio
import org.kde.plasma.private.mobileshell as MobileShell

FocusScope {
    id: root

    property int delegateIndex: index

    property Folio.HomeScreen folio
    property string category: ""

    property var homeScreen
    property var categoryAppGrid

    readonly property var __categoryModel: Folio.ApplicationListSearchModel {
        sourceModel: root.folio.ApplicationListModel
        categoryFilter: root.category
    }

    property real folderOutsideMargin: Kirigami.Units.gridUnit
    property real folderRadius: Kirigami.Units.cornerRadius // placeholder, final value gets set within `AppDrawerCategoryGrid.qml`
    property real folderSize: root.width - root.folderOutsideMargin

    signal expandCategory(expandCategoryLayout: var, categoryTitle: string)

    MobileShell.HapticsEffect {
        id: haptics
    }

    function keyboardFocus(idx = 0) {
        focusChild(idx);
    }

    // handles focusing a specific app slot within the 2x2 category delegate folder grid
    function focusChild(idx) {
        let total = Math.min(root.__categoryModel.count, 4);
        if (total === 0) return;

        idx = Math.max(0, Math.min(idx, 3));

        // fallback when the requested index is not available,
        // route focus to the nearest available neighbor.
        if (idx >= total) {
            if (total === 1) {
                idx = 0;
            } else if (total === 2) {
                // if items are only on the top row, map down presses to the top row
                idx = (idx === 2) ? 0 : 1;
            } else if (total === 3) {
                // if bottom right is missing, map to bottom left
                idx = 2;
            }
        }

        // slot 3 becomes the "Expand Category" button if there are more than 4 apps
        if (idx === 3 && root.__categoryModel.count > 4) {
            expandButtonLoader.item.forceActiveFocus(Qt.TabFocusReason);
        } else {
            let wrapper = mainGridRepeater.itemAt(idx);
            if (wrapper && wrapper.appItem) {
                wrapper.appItem.keyboardFocus();
            }
        }
    }

    // handles moving focus to the adjacent folder in the parent GridView
    function navigateToNeighbor(direction, targetChildIdx) {
        let grid = root.GridView.view;
        if (!grid) return false;

        let cols = grid.columns || 1;
        let current = root.delegateIndex;
        let target = -1;

        // calculate the parent GridView index of the neighbor
        switch (direction) {
            case "right":
                if ((current + 1) % cols !== 0 && current + 1 < grid.count) target = current + 1;
                break;
            case "left":
                if (current % cols !== 0 && current - 1 >= 0) target = current - 1;
                break;
            case "down":
                if (current + cols < grid.count) target = current + cols;
                break;
            case "up":
                if (current - cols >= 0) target = current - cols;
                break;
        }

        if (target !== -1) {
            grid.currentIndex = target;
            let neighbor = grid.currentItem;

            // map focus into the target slot of the neighbor folder
            if (neighbor && typeof neighbor.focusChild === "function") {
                neighbor.focusChild(targetChildIdx);
                return true;
            }
        }
        return false;
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        height: folderSize + folio.HomeScreenState.pageDelegateLabelHeight
        width: folderSize

        Rectangle {
            id: categoryFolder
            anchors.horizontalCenter: parent.horizontalCenter
            height: folderSize
            width: folderSize
            radius: categoryFolderRadius

            property color backgroundColor: "white"
            color: Qt.rgba(backgroundColor.r, backgroundColor.g, backgroundColor.b, 0.15)

            GridLayout {
                id: mainGrid
                anchors.fill: parent
                anchors.margins: categoryFolderRadius * 0.85
                columns: 2
                rows: 2

                uniformCellHeights: true
                uniformCellWidths: true

                // the first few apps in a category
                Repeater {
                    id: mainGridRepeater
                    model: root.__categoryModel.count <= 4 ? 4 : 3

                    delegate: Item {
                        id: appGirdItem
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        property var appDelegate: index < root.__categoryModel.count ? root.__categoryModel.get(index, "delegate") : null
                        property alias appItem: appButtonLoader.item

                        Component {
                            id: appButtonComponent

                            AppDelegate {
                                id: app
                                height: folio.FolioSettings.delegateIconSize + Kirigami.Units.smallSpacing * 2
                                width: folio.FolioSettings.delegateIconSize + Kirigami.Units.smallSpacing * 2
                                scale: Math.min(folio.FolioSettings.delegateIconSize, appGirdItem.height) / folio.FolioSettings.delegateIconSize

                                folio: root.folio
                                shadow: false
                                application: appDelegate ? appDelegate.application : null
                                name: ""

                                enabled: appDelegate !== null
                                visible: enabled

                                onPressAndHold: {
                                    if (folio.FolioSettings.lockLayout) return;

                                    const mappedCoords = root.homeScreen.prepareStartDelegateDrag(appDelegate, app, true, false);
                                    folio.HomeScreenState.closeAppDrawer();
                                    haptics.buttonVibrate();

                                    const centerX = mappedCoords.x + app.width / 2;
                                    const centerY = mappedCoords.y + app.height / 2;

                                    folio.HomeScreenState.startDelegateAppDrawerDrag(
                                        centerX - folio.HomeScreenState.pageCellWidth / 2,
                                        centerY - folio.HomeScreenState.pageCellHeight / 2,
                                        app.pressPosition.x * (folio.HomeScreenState.pageCellWidth / app.width * app.scale),
                                        app.pressPosition.y * (folio.HomeScreenState.pageCellHeight / app.height * app.scale),
                                        app.application.storageId
                                    );
                                }

                                // keyboard navigation
                                Keys.onRightPressed: (event) => {
                                    // if on the left column and the right item exists, move right
                                    if (index % 2 === 0 && root.__categoryModel.count > index + 1) {
                                        root.focusChild(index + 1);
                                        event.accepted = true;
                                    } else {
                                        // otherwise jump to the neighbor folder on the right
                                        let targetChild = (index < 2) ? 0 : 2;
                                        event.accepted = root.navigateToNeighbor("right", targetChild);
                                    }
                                }

                                Keys.onLeftPressed: (event) => {
                                    // if on the right column, move left
                                    if (index % 2 !== 0) {
                                        root.focusChild(index - 1);
                                        event.accepted = true;
                                    } else {
                                        let targetChild = (index < 2) ? 1 : 3;
                                        let handled = root.navigateToNeighbor("left", targetChild);
                                        if (!handled) {
                                            let grid = root.GridView.view;
                                            if (grid && typeof grid.pageLeftRequested === "function") {
                                                grid.pageLeftRequested();
                                            }
                                        }
                                        event.accepted = true;
                                    }
                                }

                                Keys.onDownPressed: (event) => {
                                    // if on the top row and the bottom item exists, move down
                                    if (index < 2 && root.__categoryModel.count > index + 2) {
                                        root.focusChild(index + 2);
                                        event.accepted = true;
                                    } else {
                                        let targetChild = (index % 2 === 0) ? 0 : 1;
                                        event.accepted = root.navigateToNeighbor("down", targetChild);
                                    }
                                }

                                Keys.onUpPressed: (event) => {
                                    // if on the bottom row, move up
                                    if (index >= 2) {
                                        root.focusChild(index - 2);
                                        event.accepted = true;
                                    } else {
                                        let targetChild = (index % 2 === 0) ? 2 : 3;
                                        event.accepted = root.navigateToNeighbor("up", targetChild);
                                    }
                                }
                            }
                        }

                        Loader {
                            id: appButtonLoader
                            anchors.centerIn: parent

                            active: appDelegate !== null

                            sourceComponent: appButtonComponent
                        }
                    }
                }

                // expand category button
                Component {
                    id: expandButtonComponent

                    Controls.Button {
                        id: expandCategoryButton
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        background: Item {}
                        focusPolicy: Qt.StrongFocus

                        KeyboardHighlight {
                            anchors.centerIn: parent
                            height: folio.FolioSettings.delegateIconSize + Kirigami.Units.smallSpacing * 2
                            width: folio.FolioSettings.delegateIconSize + Kirigami.Units.smallSpacing * 2
                            scale: Math.min(folio.FolioSettings.delegateIconSize, expandCategoryButton.height) / folio.FolioSettings.delegateIconSize

                            z: -10
                            visible: expandCategoryButton.visualFocus && expandCategoryButton.focusReason !== Qt.MouseFocusReason
                        }

                        contentItem: Item {
                            anchors.fill: parent

                            GridLayout {
                                id: expandCategoryLayout

                                anchors.centerIn: parent
                                height: folio.FolioSettings.delegateIconSize
                                width: folio.FolioSettings.delegateIconSize
                                scale: Math.min(folio.FolioSettings.delegateIconSize, parent.height) / height

                                visible: categoryAppGrid.__category != root.category || !categoryAppGrid.visible

                                columnSpacing: Math.ceil(height * 0.06)
                                rowSpacing: Math.ceil(height * 0.06)
                                columns: 2
                                rows: 2

                                uniformCellHeights: true
                                uniformCellWidths: true

                                Repeater {
                                    // exactly 4 slots to maintain 2x2 shape inside the mini-grid
                                    model: 4

                                    delegate: Item {
                                        id: appIcon
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        // offset by 3 to get apps at index after the first few apps in a category
                                        property int appIndex: index + 3
                                        property var appDelegate: appIndex < root.__categoryModel.count ? root.__categoryModel.get(appIndex, "delegate") : null

                                        Component {
                                            id: appIconComponent

                                            DelegateAppIcon {
                                                anchors.centerIn: parent
                                                folio: root.folio
                                                scale: 0.5

                                                source: appIcon.appDelegate && appIcon.appDelegate.application ? appIcon.appDelegate.application.icon : "unknown"
                                            }
                                        }

                                        Loader {
                                            id: appIconLoader
                                            anchors.centerIn: parent

                                            active: appIcon.appDelegate !== null

                                            sourceComponent: appIconComponent
                                        }
                                    }
                                }
                            }
                        }

                        // expand app category button pressed
                        onClicked: {
                            root.expandCategory(expandCategoryLayout, root.category)
                        }

                        // keyboard navigation
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return || Qt.Key_Space) {
                                expandCategoryButton.clicked();
                                event.accepted = true;
                            }
                        }

                        // due to the position of the expand app category button being fixed,
                        // left and up button presses will always move within the category delegate
                        Keys.onLeftPressed: (event) => {
                            root.focusChild(2);
                            event.accepted = true;
                        }

                        Keys.onUpPressed: (event) => {
                            root.focusChild(1);
                            event.accepted = true;
                        }

                        // due to the position of the expand app category button being fixed,
                        // right and down button presses will always navigate to a neighboring category delegate
                        Keys.onRightPressed: (event) => {
                            event.accepted = root.navigateToNeighbor("right", 2);
                        }

                        Keys.onDownPressed: (event) => {
                            event.accepted = root.navigateToNeighbor("down", 1);
                        }
                    }
                }

                Loader {
                    id: expandButtonLoader
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // if the category has more then 4 apps, show the mini-grid for the rest of the category
                    active: root.__categoryModel.count > 4
                    visible: active

                    sourceComponent: expandButtonComponent
                }
            }
        }

        DelegateLabel {
            anchors.topMargin: folio.HomeScreenState.pageDelegateLabelSpacing
            anchors.top: categoryFolder.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            text: root.category
            color: "white"
        }
    }
}
