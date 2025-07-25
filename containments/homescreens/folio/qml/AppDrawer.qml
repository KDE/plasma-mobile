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

    property alias flickable: appDrawerGrid

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

            // Keyboard navigation for header (search bar)
            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                    // Go from search bar to app grid
                    appDrawerGrid.forceActiveFocus();
                    appDrawerGrid.currentIndex = 0;
                    event.accepted = true;
                } else if (event.key === Qt.Key_Up) {
                    // Go to homescreen pages
                    folio.HomeScreenState.closeAppDrawer();
                    event.accepted = true;
                }
            }
        }

        // App list
        AppDrawerGrid {
            id: appDrawerGrid
            folio: root.folio
            homeScreen: root.homeScreen
            height: parent.height - drawerHeader.height
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            opacity: 0 // we display with the opacity gradient below
            headerHeight: root.headerHeight

            // Keyboard navigation
            topEdgeCallback: () => {
                drawerHeader.contentItem.forceActiveFocus();
                currentIndex = -1;
            }

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                    topEdgeCallback();
                    event.accepted = true;
                }
            }
        }

        // Opacity gradient at grid edges
        MobileShell.FlickableOpacityGradient {
            anchors.fill: appDrawerGrid
            flickable: appDrawerGrid
        }
    }
}
