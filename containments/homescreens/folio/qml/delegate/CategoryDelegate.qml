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

Item {
    id: root

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

    signal expandCategory(expandCategoryButton: var, category: string)

    MobileShell.HapticsEffect {
        id: haptics
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
                columnSpacing: anchors.margins * 0.5
                rowSpacing: anchors.margins * 0.5

                uniformCellHeights: true
                uniformCellWidths: true

                // the first few apps in a category
                Repeater {
                    model: root.__categoryModel.count <= 4 ? 4  :3

                    delegate: Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        property var appDelegate: index < root.__categoryModel.count ? root.__categoryModel.get(index, "delegate") : null

                        AppDelegate {
                            id: app
                            anchors.centerIn: parent
                            height: folio.FolioSettings.delegateIconSize
                            width: folio.FolioSettings.delegateIconSize
                            scale: Math.min(folio.FolioSettings.delegateIconSize, parent.height) / height

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
                        }
                    }
                }

                // if the category has more then 4 apps, show the mini-grid for the rest of the category
                Controls.Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    enabled: root.__categoryModel.count > 4
                    visible: enabled && (categoryAppGrid.__category != root.category || !categoryAppGrid.visible)
                    background: Item {}

                    contentItem: Item {
                        anchors.fill: parent

                        GridLayout {
                            id: expandCategoryButton

                            anchors.centerIn: parent
                            height: folio.FolioSettings.delegateIconSize
                            width: folio.FolioSettings.delegateIconSize
                            scale: Math.min(folio.FolioSettings.delegateIconSize, parent.height) / height

                            columns: 2
                            rows: 2
                            columnSpacing: Math.ceil(height * 0.06)
                            rowSpacing: Math.ceil(height * 0.06)

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
                        root.expandCategory(expandCategoryButton, root.category)
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
