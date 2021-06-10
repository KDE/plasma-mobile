/*
 *  SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.14
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
//import org.kde.kquickcontrolsaddons 2.0
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
        if (view.contentY >= -view.originY - view.height) {
            return AppDrawer.Status.Open;
        } else if (view.contentY > -view.originY - view.height*2 + closedPositionOffset*2) {
            return AppDrawer.Status.Peeking;
        } else {
            return AppDrawer.Status.Closed;
        }
    }

    property real offset: 0
    property real closedPositionOffset: 0

    property real leftPadding: 0
    property real topPadding: 0
    property real bottomPadding: 100
    property real rightPadding: 0

    readonly property int columns: Math.floor(view.width / cellWidth)
    property alias cellWidth: view.cellWidth
    property alias cellHeight: view.cellHeight
    signal launched
    signal dragStarted

    readonly property int reservedSpaceForLabel: metrics.height
    property int availableCellHeight: units.iconSizes.huge + reservedSpaceForLabel

    property alias flickable: view

    readonly property real openFactor: Math.min(1, Math.max(0, Math.min(1, (view.contentY + view.originY + view.height*2 - root.closedPositionOffset*2) / (units.gridUnit * 10))))

    function open() {
        if (root.status === AppDrawer.Status.Open) {
            view.flick(0,1);
        } else {
            scrollAnim.to = 0
            scrollAnim.restart();
        }
    }

    function close() {
        if (root.status !== AppDrawer.Status.Closed) {
            scrollAnim.to = -view.height + closedPositionOffset;
            scrollAnim.restart();
        }
    }

    function snapDrawerStatus() {
        if (root.status !== AppDrawer.Status.Peeking) {
            return;
        }

        if (view.movementDirection === AppDrawer.MovementDirection.Up) {
            if (view.contentY > 7 * -view.height / 8) { // over one eighth of the screen
                open();
            } else {
                close();
            }
        } else {
            if (view.contentY < -view.height / 8) { // over one eighth of the screen 
                close();
            } else {
                open();
            }
        }
    }

    Drag.dragType: Drag.Automatic

    onOffsetChanged: {
        if (!view.moving) {
            view.contentY = Math.max(0, offset) - view.originY - view.height*2 + closedPositionOffset*2
        }
    }

    NumberAnimation {
        id: scrollAnim
        target: view
        properties: "contentY"
        duration: units.longDuration * 2
        easing.type: Easing.OutQuad
        easing.amplitude: 2.0
    }

    PC3.Label {
        id: metrics
        text: "M\nM"
        visible: false
        font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 0.9
    }

    OpenDrawerButton {
        id: openDrawerButton
        anchors {
            left: parent.left
            right: parent.right
            bottom: scrim.top
        }
        factor: root.openFactor
        flickable: view
        onOpenRequested: root.open();
        onCloseRequested: root.close();
    }

    Rectangle {
        id: scrim
        anchors {
            left: view.left
            right: view.right
            leftMargin: -1
            rightMargin: -1
        }
        border.color: Qt.rgba(1, 1, 1, 0.5)
        radius: units.gridUnit
        color: "black"
        opacity: 0.4 * root.openFactor
        height: root.height + radius * 2
        y: Math.min(view.height, Math.max(-radius, -view.contentY - view.originY - root.height + root.topPadding + root.bottomPadding + root.closedPositionOffset))
    }

    Timer {
        id: closeTimer
        interval: 1000
        onTriggered: root.close();
    }
    GridView {
        id: view
        anchors {
            fill: parent
            leftMargin: root.leftPadding
            topMargin: root.topPadding
            rightMargin: root.rightPadding
            bottomMargin: root.bottomPadding
        }

        opacity: {
            if (root.status == AppDrawer.Status.Open) {
                return 1;
            } else if (root.status == AppDrawer.Status.Closed) {
                return 0;
            } else { // peeking
                return root.openFactor;
            }
        }
        
        visible: root.status !== AppDrawer.Status.Closed
        cellWidth: view.width / Math.floor(view.width / ((root.availableCellHeight - root.reservedSpaceForLabel) + units.smallSpacing*4))
        cellHeight: root.availableCellHeight
        clip: true

        cacheBuffer: contentHeight

        property real oldContentY: contentY
        property int movementDirection: AppDrawer.MovementDirection.None
        onContentYChanged: {
            if (contentY > oldContentY) {
                movementDirection = AppDrawer.MovementDirection.Up;
            } else {
                movementDirection = AppDrawer.MovementDirection.Down;
            }

            oldContentY = contentY;
            root.offset = contentY + view.originY + view.height*2 - root.closedPositionOffset*2
        }
        onMovementEnded: root.snapDrawerStatus()
        onFlickEnded: movementEnded()

       // boundsBehavior: Flickable.StopAtBounds

        model: HomeScreenComponents.ApplicationListModel

        header: Rectangle {
            height: root.height - root.topPadding - root.bottomPadding - root.closedPositionOffset
            property real oldHeight: height
            onHeightChanged: {
                if (root.status !== AppDrawer.Status.Open) {
                    view.contentY = -view.height + root.closedPositionOffset;
                }
                oldHeight = height;
            }
        }

        delegate: DrawerDelegate {
            id: delegate
            width: view.cellWidth
            height: view.cellHeight
            reservedSpaceForLabel: root.reservedSpaceForLabel

            onDragStarted: (imageSource, x, y, mimeData) => {
                root.Drag.imageSource = imageSource;
                root.Drag.hotSpot.x = x;
                root.Drag.hotSpot.y = y;
                root.Drag.mimeData = { "text/x-plasma-phone-homescreen-launcher": mimeData };

                root.close()

                root.dragStarted()
                root.Drag.active = true;
            }
            onLaunch: (x, y, icon, title, storageId) => {
                if (icon !== "") {
                    NanoShell.StartupFeedback.open(
                            icon,
                            title,
                            delegate.iconItem.Kirigami.ScenePosition.x + delegate.iconItem.width/2,
                            delegate.iconItem.Kirigami.ScenePosition.y + delegate.iconItem.height/2,
                            Math.min(delegate.iconItem.width, delegate.iconItem.height));
                }

                HomeScreenComponents.ApplicationListModel.setMinimizedDelegate(index, delegate);
                HomeScreenComponents.ApplicationListModel.runApplication(storageId);
                root.launched();
                closeTimer.restart();
            }
        }

        PC3.ScrollBar.vertical: PC3.ScrollBar {
            id: scrollabr
            opacity: view.moving
            interactive: false
            enabled: false
            Behavior on opacity {
                OpacityAnimator {
                    duration: units.longDuration * 2
                    easing.type: Easing.InOutQuad
                }
            }
            implicitWidth: Math.round(units.gridUnit/3)
            contentItem: Rectangle {
                radius: width/2
                color: Qt.rgba(1, 1, 1, 0.3)
                border.color: Qt.rgba(0, 0, 0, 0.4)
            }
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: units.gridUnit + root.leftPadding
            rightMargin: units.gridUnit + root.rightPadding
            bottomMargin: root.bottomPadding - height
        }
        height: 1
        visible: root.bottomPadding > 0
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0) }
            GradientStop { position: 0.15; color: Qt.rgba(1, 1, 1, 0.5) }
            GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 1) }
            GradientStop { position: 0.85; color: Qt.rgba(1, 1, 1, 0.5) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0) }
        }
        opacity: root.status !== AppDrawer.Status.Closed ? 0.6 : 0
        Behavior on opacity {
            OpacityAnimator {
                duration: units.longDuration * 2
                easing.type: Easing.InOutQuad
            }
        }
    }
}
