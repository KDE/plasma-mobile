/*
 *  SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as Controls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.extras 2.0 as PlasmaExtra
import org.kde.kirigami 2.10 as Kirigami

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import "../private"
import "../"

Item {
    id: root
    required property var homeScreenState

    property real leftPadding: 0
    property real topPadding: 0
    property real bottomPadding: 100
    property real rightPadding: 0

    property alias flickable: flickableBody.contentItem
    
    property Flickable contentItem
    property real contentWidth: holdingColumn.width
    
    required property int headerHeight
    required property var headerItem
    
    signal launched
    signal dragStarted

    readonly property int reservedSpaceForLabel: metrics.height
    property int availableCellHeight: PlasmaCore.Units.iconSizes.huge + reservedSpaceForLabel

    readonly property real openFactor: factorNormalize(view.contentY / (PlasmaCore.Units.gridUnit * 10))

    // height from top of screen that the drawer starts
    readonly property real drawerTopMargin: height - topPadding - bottomPadding - closedPositionOffset
    readonly property real closedPositionOffset: homeScreenState.appDrawerBottomOffset
    
//BEGIN functions 

    function factorNormalize(num) {
        return Math.min(1, Math.max(0, num));
    }
    
//END functions 

    Drag.dragType: Drag.Automatic

    PC3.Label {
        id: metrics
        text: "M\nM"
        visible: false
        font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 0.8
        font.weight: Font.Bold
    }
    
    // bottom divider
    GradientBar {
        opacity: (homeScreenState.currentView !== HomeScreenState.PageView || homeScreenState.currentSwipeState === HomeScreenState.SwipingAppDrawerVisibility) ? 0.6 : 0
        visible: root.bottomPadding > 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.bottomPadding - height
    }
    
    // physical position of drawer is handled through this flickable
    Flickable {
        id: view
        anchors.fill: parent
        
        // scroll events are handled by our flick container, we are only using this for positioning
        interactive: false
        contentY: Math.max(0, Math.min(root.drawerTopMargin, root.drawerTopMargin - homeScreenState.yPosition))
        
        contentHeight: column.implicitHeight
        contentWidth: -1
        boundsBehavior: Flickable.StopAtBounds
        
        ColumnLayout {
            id: column
            width: view.width
            spacing: 0
            
            // margin of the drawer from the top
            Rectangle {
                id: topMargin
                color: "transparent"
                Layout.fillWidth: true
                Layout.preferredHeight: root.drawerTopMargin
                
                OpenDrawerButton {
                    id: openDrawerButton
                    anchors {
                        leftMargin: root.leftPadding
                        left: parent.left
                        rightMargin: root.rightPadding
                        right: parent.right
                        bottom: parent.bottom
                    }
                    factor: root.openFactor
                    flickable: view
                    onOpenRequested: {
                        contentItem.positionViewAtBeginning();
                        homeScreenState.openAppDrawer();
                    }
                    onCloseRequested: homeScreenState.closeAppDrawer();
                }
            }
            
            // actual drawer
            MobileShell.BaseItem {
                visible: root.openFactor > 0 // prevent handlers from picking up events
                
                Layout.fillWidth: true
                Layout.preferredHeight: root.height
                leftPadding: root.leftPadding; topPadding: root.topPadding
                rightPadding: root.rightPadding; bottomPadding: root.bottomPadding
                
                // drawer background
                background: Rectangle {
                    id: scrim
                    color: "black"
                    opacity: 0.6 * root.openFactor
                    
                    // remove radius 
                    radius: view.contentY > (topMargin.height - PlasmaCore.Units.gridUnit) ? 0 : PlasmaCore.Units.gridUnit
                    Behavior on radius {
                        NumberAnimation { duration: Kirigami.Units.shortDuration; easing.type: Easing.InOutQuad }
                    }
                }
                
                opacity: root.openFactor
                
                contentItem: ColumnLayout {
                    id: holdingColumn
                    width: view.width
                    spacing: 0
                    
                    // drawer header
                    MobileShell.BaseItem {
                        id: flickableHeader
                        Layout.preferredHeight: root.headerHeight
                        Layout.fillWidth: true
                        leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
                        
                        contentItem: root.headerItem
                    }
                    
                    // drawer body
                    MobileShell.BaseItem {
                        id: flickableBody
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
                        
                        contentItem: root.contentItem
                    }
                }
            }
        }
    }
}

