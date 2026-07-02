// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Qt5Compat.GraphicalEffects

import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami as Kirigami

import org.kde.plasma.private.mobileshell as MobileShell
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio

import 'private'

Item {
    id: root
    required property Folio.HomeScreen folio

    property var homeScreen

    property real leftPadding: 0
    property real topPadding: 0
    property real bottomPadding: 0
    property real rightPadding: 0

    required property int headerHeight
    required property var headerItem

    // Height from top of screen that the drawer starts
    readonly property real drawerTopMargin: height - topPadding - bottomPadding

    property var flickable: delegateRepeater.itemAt(folio.HomeScreenState.currentAppDrawerPage)?.flickable

    // Keyboard navigation
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Back) {
            // Close drawer if "back" action
            folio.HomeScreenState.closeAppDrawer();
            event.accepted = true;
        }
    }

    // App drawer container
    Item {
        anchors.fill: parent

        anchors.leftMargin: root.leftPadding
        anchors.topMargin: root.topPadding
        anchors.rightMargin: root.rightPadding
        anchors.bottomMargin: root.bottomPadding

        // Drawer header
        MobileShell.BaseItem {
            id: drawerHeader
            z: 1
            height: root.headerHeight

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            contentItem: root.headerItem
        }

        Item {
            id: swipeContainer
            anchors.top: drawerHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            clip: true

            onWidthChanged: folio.HomeScreenState.appDrawerPageWidth = width
            Component.onCompleted: folio.HomeScreenState.appDrawerPageWidth = width

            Binding {
                target: folio.HomeScreenState
                property: "appDrawerPageCount"
                value: folio.ApplicationListModel.categories.length
            }

            Item {
                id: contentContainer
                height: parent.height
                x: folio.HomeScreenState.appDrawerPageX

                Repeater {
                    id: delegateRepeater
                    model: folio.ApplicationListModel.categories

                    Item {
                        id: pageItem
                        width: swipeContainer.width
                        height: swipeContainer.height

                        x: index * width

                        property alias flickable: appDrawerGrid

                        // App list
                        AppDrawerGrid {
                            id: appDrawerGrid
                            anchors.fill: parent
                            folio: root.folio
                            homeScreen: root.homeScreen
                            headerHeight: root.headerHeight

                            currentPage: folio.HomeScreenState.currentAppDrawerPage === index

                            opacity: 0 // we display with the opacity gradient below

                            model: Folio.ApplicationListSearchModel {
                                sourceModel: root.folio.ApplicationListModel
                                categoryFilter: modelData
                                searchString: root.headerItem.searchText
                            }

                            // Keyboard navigation
                            topEdgeCallback: () => {
                                root.headerItem.focusTabBar();
                            }

                            Keys.onPressed: (event) => {
                                if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                                    topEdgeCallback();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Up) {
                                    if (appDrawerGrid.currentIndex < appDrawerGrid.columns) {
                                        topEdgeCallback();
                                        event.accepted = true;
                                    }
                                } else if (event.key === Qt.Key_Down) {
                                    if (appDrawerGrid.currentIndex + appDrawerGrid.columns >= appDrawerGrid.count) {
                                        event.accepted = true;
                                    }
                                } else if (event.key === Qt.Key_Left) {
                                    if (appDrawerGrid.currentIndex % appDrawerGrid.columns === 0) {
                                        if (index > 0) {
                                            folio.HomeScreenState.goToAppDrawerPage(index - 1, false);
                                            let prevGrid = delegateRepeater.itemAt(index - 1).flickable;
                                            if (prevGrid) {
                                                prevGrid.forceActiveFocus();
                                            }
                                        } else {
                                            folio.HomeScreenState.goToAppDrawerPage(delegateRepeater.count - 1, false);
                                            let wrapAround = delegateRepeater.itemAt(delegateRepeater.count - 1).flickable;
                                            if (wrapAround) {
                                                wrapAround.forceActiveFocus();
                                            }
                                        }
                                        event.accepted = true;
                                    }
                                } else if (event.key === Qt.Key_Right) {
                                    if (appDrawerGrid.currentIndex % appDrawerGrid.columns === appDrawerGrid.columns - 1 ||
                                        appDrawerGrid.currentIndex === appDrawerGrid.count - 1) {

                                        if (index < delegateRepeater.count - 1) {
                                            folio.HomeScreenState.goToAppDrawerPage(index + 1, false);
                                            let nextGrid = delegateRepeater.itemAt(index + 1).flickable;
                                            if (nextGrid) {
                                                nextGrid.forceActiveFocus();
                                            }
                                        } else {
                                            folio.HomeScreenState.goToAppDrawerPage(0, false);
                                            let wrapAround = delegateRepeater.itemAt(0).flickable;
                                            if (wrapAround) {
                                                wrapAround.forceActiveFocus();
                                            }
                                        }
                                        event.accepted = true;
                                        }
                                }
                            }
                        }

                        // Opacity gradient at grid edges
                        MobileShell.FlickableOpacityGradient {
                            anchors.fill: appDrawerGrid
                            flickable: appDrawerGrid
                        }

                        // No results find message
                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            opacity: 0.5
                            y: (parent.height * 0.25) - (height * 0.5)
                            visible: appDrawerGrid.count == 0 && root.headerItem.searchText != ""

                            Kirigami.Icon {
                                Layout.alignment: Qt.AlignHCenter
                                source: "file-search-symbolic"

                                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                                Layout.preferredWidth: Kirigami.Units.gridUnit * 3
                            }

                            PC3.Label {
                                text: "No Results for \"" + root.headerItem.searchText  + "\""
                                font.bold: true
                                color: "white"
                                wrapMode: Text.Wrap
                                horizontalAlignment: Text.AlignHCenter

                                Layout.alignment: Qt.AlignHCenter
                                Layout.maximumWidth: Math.min(parent.width - Kirigami.Units.gridUnit * 2, Kirigami.Units.gridUnit * 16)
                            }
                            PC3.Label {
                                text: "Check spelling or try a different search."
                                color: "white"
                                wrapMode: Text.Wrap
                                horizontalAlignment: Text.AlignHCenter

                                Layout.alignment: Qt.AlignHCenter
                                Layout.maximumWidth: Math.min(parent.width - Kirigami.Units.gridUnit * 2, Kirigami.Units.gridUnit * 16)
                            }
                        }
                    }
                }
            }
        }
    }
}
