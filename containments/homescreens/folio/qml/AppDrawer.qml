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

    property var flickable: {
        if (categoryAppGridItem.opened) {
            return categoryAppGridItem;
        }
        return folio.HomeScreenState.currentAppDrawerPage === 0 ? allAppsGrid : categoryGridView;
    }

    // Keyboard navigation
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Back) {
            // Close drawer if "back" action
            folio.HomeScreenState.closeAppDrawer();
            event.accepted = true;
        }
    }

    function reset() {
        appDrawer.flickable.contentY = 0 - appDrawer.flickable.topMargin;
        appDrawer.flickable.returnToBounds();
    }

    // App drawer container
    Item {
        id: appDrawerContainer
        anchors.fill: parent

        anchors.leftMargin: root.leftPadding
        anchors.topMargin: root.topPadding
        anchors.rightMargin: root.rightPadding
        anchors.bottomMargin: root.bottomPadding

        readonly property real scaleEase: Math.pow(categoryAppGridItem.animationProgress, 1)
        readonly property real opacityEase: Math.pow(1.0 - categoryAppGridItem.animationProgress, 2)

        opacity: Math.min(Math.max(0.0, opacityEase), 1)
        visible: opacity > 0.01
        scale: Math.min(Math.max(1.0 - (scaleEase * 0.25), 0), 1)

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
            anchors.topMargin: -Kirigami.Units.gridUnit * 2.5
            anchors.bottomMargin: -root.bottomPadding + Math.max(root.bottomPadding - Kirigami.Units.gridUnit, 0)
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
                value: 2
            }

            Item {
                id: contentContainer
                height: parent.height
                x: folio.HomeScreenState.appDrawerPageX

                // All apps grid
                AppDrawerAppGrid {
                    id: allAppsGrid
                    folio: root.folio
                    homeScreen: root.homeScreen
                    headerHeight: root.headerHeight
                    currentPage: folio.HomeScreenState.currentAppDrawerPage === 0

                    width: swipeContainer.width
                    height: swipeContainer.height
                    containerWidth: swipeContainer.width
                    containerTopMargin: swipeContainer.anchors.topMargin
                    containerBottomMargin: swipeContainer.anchors.bottomMargin

                    model: Folio.ApplicationListSearchModel {
                        sourceModel: root.folio.ApplicationListModel
                        searchString: root.headerItem.searchText
                    }
                }

                // Categories grid
                AppDrawerCategoryGrid {
                    id: categoryGridView
                    folio: root.folio
                    homeScreen: root.homeScreen
                    categoryAppGrid: categoryAppGridItem
                    headerHeight: root.headerHeight
                    currentPage: folio.HomeScreenState.currentAppDrawerPage === 1

                    width: swipeContainer.width
                    height: swipeContainer.height
                    x: swipeContainer.width
                    containerWidth: swipeContainer.width
                    containerTopMargin: swipeContainer.anchors.topMargin
                    containerBottomMargin: swipeContainer.anchors.bottomMargin

                    model: root.folio.ApplicationListModel.categories.slice(1)

                    onExpandCategory: (expandCategoryButton, category) => {
                        categoryAppGridItem.expandCategory(expandCategoryButton, category);
                    }
                }
            }

            layer.enabled: true
            layer.effect: OpacityMask {
                invert: true

                maskSource: Rectangle {
                    id: gridViewMask
                    width: swipeContainer.width
                    height: swipeContainer.height

                    property real gradientPct: (Kirigami.Units.gridUnit * 3) / height
                    property real bottomGradientPct: (-swipeContainer.anchors.bottomMargin + Kirigami.Units.gridUnit) / height

                    gradient: Gradient {
                        orientation: Gradient.Vertical

                        GradientStop { position: 0; color: 'white' }
                        GradientStop { position: 0 + gridViewMask.gradientPct; color: 'transparent' }
                        GradientStop { position: 1.0 - gridViewMask.bottomGradientPct; color: 'transparent' }
                        GradientStop { position: 1.0; color: 'white' }
                    }

                    Rectangle {
                        width: root.headerItem.tabbar.width
                        height: root.headerItem.tabbar.height
                        radius: height * 2
                        opacity: 0.95

                        readonly property point position: {
                            swipeContainer.width
                            swipeContainer.height
                            folio.HomeScreenState.appDrawerPageX
                            swipeContainer.mapFromItem(root.headerItem.tabbar, 0, 0)
                        }

                        x: position.x
                        y: position.y
                        color: "white"
                    }
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: categoryAppGridItem.opened || categoryAppGridItem.animationProgress > 0 || categoryAppGridItem.keepVisibleForDrag

        CategoryAppGrid {
            id: categoryAppGridItem
            anchors.fill: parent

            anchors.leftMargin: root.leftPadding
            anchors.topMargin: root.topPadding + Kirigami.Units.gridUnit * 3
            anchors.rightMargin: root.rightPadding
            anchors.bottomMargin: root.bottomPadding

            folio: root.folio
            homeScreen: root.homeScreen
            clip: true

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    id: categoryAppGridMask
                    width: swipeContainer.width
                    height: swipeContainer.height

                    property real gradientPct: (Kirigami.Units.gridUnit * 3) / height
                    property real bottomGradientPct: (-swipeContainer.anchors.bottomMargin + Kirigami.Units.gridUnit) / height

                    gradient: Gradient {
                        orientation: Gradient.Vertical

                        GradientStop { position: 0; color: 'transparent' }
                        GradientStop { position: 0 + categoryAppGridMask.gradientPct; color: 'white' }
                        GradientStop { position: 1.0 - categoryAppGridMask.bottomGradientPct; color: 'white' }
                        GradientStop { position: 1.0; color: 'transparent' }
                    }
                }
            }
        }

        CategoryAppGridTitle {
            categoryAppGrid: categoryAppGridItem
        }

        TapHandler {
            onTapped: categoryAppGridItem.closeCategory()
        }
    }
}
