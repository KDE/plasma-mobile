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

import org.kde.plasma.private.mobilehomescreencomponents 0.1 as HomeScreenComponents

import "private"

Item {
    id: root

    enum Status {
        Closed,
        Peeking,
        Open
    }

    enum MovementDirection {
        None = 0,
        Up,
        Down
    }

    readonly property int status: {
        if (flickable.contentY >= topMargin.height) {
            return AbstractAppDrawer.Status.Open;
        } else if (flickable.contentY > 0) {
            return AbstractAppDrawer.Status.Peeking;
        } else {
            return AbstractAppDrawer.Status.Closed;
        }
    }

    property real offset: 0
    property real closedPositionOffset: 0

    property real leftPadding: 0
    property real topPadding: 0
    property real bottomPadding: 100
    property real rightPadding: 0

    property alias flickable: view
    
    property var contentItem
    property real contentWidth: holdingColumn.width
    
    required property int headerHeight
    required property var headerItem
    
    signal launched
    signal dragStarted

    readonly property int reservedSpaceForLabel: metrics.height
    property int availableCellHeight: PlasmaCore.Units.iconSizes.huge + reservedSpaceForLabel

    readonly property real openFactor: factorNormalize(flickable.contentY / (units.gridUnit * 10))

    // height from top of screen that the drawer starts
    readonly property real drawerTopMargin: height - topPadding - bottomPadding - closedPositionOffset
    
//BEGIN functions 

    function goToBeginning() {
        scrollAnim.to = drawerTopMargin;
        scrollAnim.restart();
    }
    
    function open() {
        if (root.status === AbstractAppDrawer.Status.Open) {
            flickable.flick(0,1);
        } else {
            goToBeginning();
        }
    }

    function close() {
        if (root.status !== AbstractAppDrawer.Status.Closed) {
            scrollAnim.to = 0;
            scrollAnim.restart();
        }
    }

    // snap the drawer to an open or close position
    function snapDrawerStatus() {
        if (flickable.contentY > topMargin.height) {
            return;
        }

        if (flickable.movementDirection === AbstractAppDrawer.MovementDirection.Up) {
            if (flickable.contentY > topMargin.height / 8) { // over one eighth of the screen
                open();
            } else {
                close();
            }
        } else {
            if (flickable.contentY < 7 * topMargin.height / 8) { // over one eighth of the screen 
                close();
            } else {
                open();
            }
        }
    }
    
    function factorNormalize(num) {
        return Math.min(1, Math.max(0, num));
    }
    
//END functions 

    Drag.dragType: Drag.Automatic

    NumberAnimation {
        id: scrollAnim
        target: flickable
        properties: "contentY"
        duration: PlasmaCore.Units.longDuration * 2
        easing.type: Easing.OutQuad
        easing.amplitude: 2.0
    }

    PC3.Label {
        id: metrics
        text: "M\nM"
        visible: false
        font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 0.9
    }
    
    // bottom divider
    GradientBar {
        opacity: root.status !== AbstractAppDrawer.Status.Closed ? 0.6 : 0
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
        
        // We have a situation where this vertical flickable conflicts with the horizontal flickable used for homescreen pages.
        // This flickable is on top of the other, so we disable it when it isn't open.
        // We do the initial open gesture in private/DragGestureHandler.qml
        interactive: contentY > PlasmaCore.Units.gridUnit
        
        contentHeight: column.implicitHeight
        contentWidth: -1
        boundsBehavior: Flickable.StopAtBounds
        
        // snap
        onMovementEnded: root.snapDrawerStatus()
        
        property int movementDirection: AbstractAppDrawer.MovementDirection.None
        property real oldContentY
        onContentYChanged: { // update state
            movementDirection = oldContentY > contentY ? AbstractAppDrawer.MovementDirection.Down : AbstractAppDrawer.MovementDirection.Up;
            oldContentY = contentY;
        }
        
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
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    factor: root.openFactor
                    flickable: view
                    onOpenRequested: root.open();
                    onCloseRequested: root.close();
                }
            }
            
            // actual drawer
            Controls.Control {
                id: drawerFlickable
                Layout.fillWidth: true
                Layout.preferredHeight: root.height
                
                visible: view.interactive // this is so that the favourites strip can be interacted with
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
                    Controls.Control {
                        id: flickableHeader
                        Layout.preferredHeight: root.headerHeight
                        Layout.fillWidth: true
                        leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
                        
                        contentItem: root.headerItem
                    }
                    
                    // drawer body
                    Controls.Control {
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

