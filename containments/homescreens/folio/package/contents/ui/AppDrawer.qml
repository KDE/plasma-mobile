// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Qt5Compat.GraphicalEffects

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami 2.10 as Kirigami

import org.kde.plasma.private.mobileshell as MobileShell

Item {
    id: root

    property var homeScreen

    property real leftPadding: 0
    property real topPadding: 0
    property real bottomPadding: 0
    property real rightPadding: 0

    required property int headerHeight
    required property var headerItem

    // height from top of screen that the drawer starts
    readonly property real drawerTopMargin: height - topPadding - bottomPadding

    property alias flickable: appDrawerGrid

    Item {
        anchors.fill: parent

        anchors.leftMargin: root.leftPadding
        anchors.topMargin: root.topPadding
        anchors.rightMargin: root.rightPadding
        anchors.bottomMargin: root.bottomPadding

        // drawer header
        MobileShell.BaseItem {
            id: drawerHeader
            height: root.headerHeight

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            contentItem: root.headerItem
        }

        AppDrawerGrid {
            id: appDrawerGrid
            homeScreen: root.homeScreen
            height: parent.height - drawerHeader.height
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            opacity: 0
        }

        // opacity gradient at grid edges
        OpacityMask {
            anchors.fill: appDrawerGrid
            source: appDrawerGrid
            maskSource: Rectangle {
                id: mask
                width: appDrawerGrid.width
                height: appDrawerGrid.height

                property real gradientPct: (Kirigami.Units.gridUnit * 2) / appDrawerGrid.height

                gradient: Gradient {
                    GradientStop { position: 0.0; color: appDrawerGrid.atYBeginning ? 'white' : 'transparent' }
                    GradientStop { position: mask.gradientPct; color: 'white' }
                    GradientStop { position: 1.0 - mask.gradientPct; color: 'white' }
                    GradientStop { position: 1.0; color: appDrawerGrid.atYEnd ? 'white' : 'transparent' }
                }
            }
        }
    }
}


