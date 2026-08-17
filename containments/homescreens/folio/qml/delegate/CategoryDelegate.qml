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

    property real categoryFolderSize: folio.FolioSettings.delegateIconSize * 2 + categoryFolderRadius * 2.75
    property real categoryFolderRadius: (folio.FolioSettings.delegateIconSize * 2) * 0.125

    property real __folderSize: root.width - Kirigami.Units.gridUnit

    signal expandCategory(expandCategoryLayout: var, categoryTitle: string)

    MobileShell.HapticsEffect {
        id: haptics
    }

    function keyboardFocus(idx = 0) {
        focusChild(idx);
    }

    function focusChild(idx) {
        let total = root.__categoryModel.count > 4 ? 4 : root.__categoryModel.count;
        if (total === 0) return;

        idx = Math.max(0, Math.min(idx, 3));

        if (idx >= total) {
            if (idx === 2) {
                idx = 0;
            } else if (idx === 3) {
                idx = total >= 2 ? 1 : 0;
            } else if (idx === 1) {
                idx = 0;
            } else {
                idx = total - 1;
            }
        }

        if (idx === 3 && root.__categoryModel.count > 4) {
            expandCategoryButton.forceActiveFocus(Qt.TabFocusReason);
        } else {
            let wrapper = mainGridRepeater.itemAt(idx);
            if (wrapper && wrapper.appItem) {
                wrapper.appItem.keyboardFocus();
            }
        }
    }

    function navigateToNeighbor(direction, targetChildIdx) {
        let grid = root.GridView.view;
        if (!grid) return false;

        let cols = grid.columns || 1;

        let currentGridIdx = root.delegateIndex;

        let targetGridIdx = -1;

        if (direction === "right") {
            if ((currentGridIdx + 1) % cols !== 0 && currentGridIdx + 1 < grid.count) {
                targetGridIdx = currentGridIdx + 1;
            }
        } else if (direction === "left") {
            if (currentGridIdx % cols !== 0 && currentGridIdx - 1 >= 0) {
                targetGridIdx = currentGridIdx - 1;
            }
        } else if (direction === "down") {
            if (currentGridIdx + cols < grid.count) {
                targetGridIdx = currentGridIdx + cols;
            }
        } else if (direction === "up") {
            if (currentGridIdx - cols >= 0) {
                targetGridIdx = currentGridIdx - cols;
            }
        }

        if (targetGridIdx !== -1) {
            grid.currentIndex = targetGridIdx;
            let neighbor = grid.currentItem;
            if (neighbor && typeof neighbor.focusChild === "function") {
                neighbor.focusChild(targetChildIdx);
                return true;
            }
        }
        return false;
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        height: __folderSize + folio.HomeScreenState.pageDelegateLabelHeight
        width: __folderSize

        Rectangle {
            id: categoryFolder
            anchors.horizontalCenter: parent.horizontalCenter
            height: __folderSize
            width: __folderSize
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
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        property var appDelegate: index < root.__categoryModel.count ? root.__categoryModel.get(index, "delegate") : null
                        property alias appItem: app

                        AppDelegate {
                            id: app
                            anchors.centerIn: parent
                            height: folio.FolioSettings.delegateIconSize + Kirigami.Units.smallSpacing * 2
                            width: folio.FolioSettings.delegateIconSize + Kirigami.Units.smallSpacing * 2
                            scale: Math.min(folio.FolioSettings.delegateIconSize, parent.height) / folio.FolioSettings.delegateIconSize

                            folio: root.folio
                            shadow: false
                            application: appDelegate ? appDelegate.application : null
                            name: ""

                            enabled: appDelegate
                            visible: enabled

                            onPressAndHold: {
                                // prevent editing if lock layout is enabled
                                if (folio.FolioSettings.lockLayout) return;

                                const mappedCoords = root.homeScreen.prepareStartDelegateDrag(appDelegate, app, true, false);
                                folio.HomeScreenState.closeAppDrawer();
                                haptics.buttonVibrate();

                                // we need to adjust because app drawer delegates have a different size than regular homescreen delegates
                                const centerX = mappedCoords.x + app.width / 2;
                                const centerY = mappedCoords.y + app.height / 2;

                                folio.HomeScreenState.startDelegateAppDrawerDrag(
                                    centerX - folio.HomeScreenState.pageCellWidth / 2,
                                    centerY - folio.HomeScreenState.pageCellHeight / 2,
                                    app.pressPosition.x * (folio.HomeScreenState.pageCellWidth / app.width * app.scale),
                                    (app.pressPosition.y * (folio.HomeScreenState.pageCellHeight / app.height * app.scale)),
                                    app.application.storageId
                                );
                            }

                            // keyboard navigation
                            Keys.onRightPressed: (event) => {
                                if (index === 0 && root.__categoryModel.count > 1) {
                                    root.focusChild(1);
                                    event.accepted = true;
                                } else if (index === 2 && root.__categoryModel.count > 3) {
                                    root.focusChild(3);
                                    event.accepted = true;
                                } else {
                                    let targetChild = (index < 2) ? 0 : 2;
                                    event.accepted = root.navigateToNeighbor("right", targetChild);
                                }
                            }

                            Keys.onLeftPressed: (event) => {
                                if (index === 1) {
                                    root.focusChild(0);
                                    event.accepted = true;
                                } else if (index === 3) {
                                    root.focusChild(2);
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
                                if (index === 0 && root.__categoryModel.count > 2) {
                                    root.focusChild(2);
                                    event.accepted = true;
                                } else if (index === 1 && root.__categoryModel.count > 3) {
                                    root.focusChild(3);
                                    event.accepted = true;
                                } else {
                                    let targetChild = (index % 2 === 0) ? 0 : 1;
                                    event.accepted = root.navigateToNeighbor("down", targetChild);
                                }
                            }

                            Keys.onUpPressed: (event) => {
                                if (index === 2) {
                                    root.focusChild(0);
                                    event.accepted = true;
                                } else if (index === 3) {
                                    root.focusChild(1);
                                    event.accepted = true;
                                } else {
                                    let targetChild = (index % 2 === 0) ? 2 : 3;
                                    event.accepted = root.navigateToNeighbor("up", targetChild);
                                }
                            }
                        }
                    }
                }

                // if the category has more then 4 apps, show the mini-grid for the rest of the category
                Controls.Button {
                    id: expandCategoryButton
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    enabled: root.__categoryModel.count > 4
                    background: Item {}
                    focusPolicy: Qt.StrongFocus

                    visible: expandCategoryButton.enabled

                    contentItem: Item {
                        anchors.fill: parent

                        KeyboardHighlight {
                            anchors.centerIn: parent
                            height: folio.FolioSettings.delegateIconSize + Kirigami.Units.smallSpacing * 2
                            width: folio.FolioSettings.delegateIconSize + Kirigami.Units.smallSpacing * 2
                            scale: Math.min(folio.FolioSettings.delegateIconSize, parent.height) / folio.FolioSettings.delegateIconSize

                            z: -10
                            visible: expandCategoryButton.visualFocus && expandCategoryButton.focusReason !== Qt.MouseFocusReason
                        }

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
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    // offset by 3 to get apps at index after the first few apps in a category
                                    property int appIndex: index + 3
                                    property var appDelegate: appIndex < root.__categoryModel.count ? root.__categoryModel.get(appIndex, "delegate") : null

                                    DelegateAppIcon {
                                        anchors.centerIn: parent
                                        folio: root.folio
                                        scale: 0.5

                                        visible: parent.appDelegate !== null
                                        source: parent.appDelegate && parent.appDelegate.application ? parent.appDelegate.application.icon : "unknown"
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
                    Keys.onLeftPressed: (event) => {
                        root.focusChild(2);
                        event.accepted = true;
                    }
                    Keys.onUpPressed: (event) => {
                        root.focusChild(1);
                        event.accepted = true;
                    }
                    Keys.onRightPressed: (event) => {
                        event.accepted = root.navigateToNeighbor("right", 2);
                    }
                    Keys.onDownPressed: (event) => {
                        event.accepted = root.navigateToNeighbor("down", 1);
                    }
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
