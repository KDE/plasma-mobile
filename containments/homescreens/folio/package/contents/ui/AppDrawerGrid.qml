// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami as Kirigami

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.private.mobile.homescreen.folio 1.0 as Folio

import "./delegate"

MobileShell.GridView {
    id: root
    cacheBuffer: cellHeight * 20
    reuseItems: true
    layer.enabled: true

    property var homeScreen
    property real headerHeight

    readonly property int reservedSpaceForLabel: Folio.HomeScreenState.pageDelegateLabelHeight
    readonly property real effectiveContentWidth: width - leftMargin - rightMargin
    readonly property real horizontalMargin: Math.round(width * 0.05)

    leftMargin: horizontalMargin
    rightMargin: horizontalMargin

    cellWidth: effectiveContentWidth / Math.min(Math.floor(effectiveContentWidth / (Folio.FolioSettings.delegateIconSize + Kirigami.Units.largeSpacing * 3.5)), 8)
    cellHeight: cellWidth + reservedSpaceForLabel

    boundsBehavior: Flickable.DragAndOvershootBounds

    readonly property int columns: Math.floor(effectiveContentWidth / cellWidth)
    readonly property int rows: Math.ceil(root.count / columns)

    // HACK: the first swipe from the top of the app drawer is done from HomeScreenState, not the flickable
    //       due to issues with Flickable getting its swipe stolen by SwipeArea
    interactive: !atYBeginning && Folio.HomeScreenState.swipeState !== Folio.HomeScreenState.SwipingAppDrawerGrid
    Connections {
        target: Folio.HomeScreenState

        function onSwipeStateChanged() {
            if (Folio.HomeScreenState.swipeState === Folio.HomeScreenState.SwipingAppDrawerGrid) {
                velocityCalculator.startMeasure();
                velocityCalculator.changePosition(root.contentY);
            }
        }

        function onAppDrawerGridYChanged(y) {
            const maxContentY = Math.max(0, root.contentHeight - root.height);
            const minContentY = 0;
            root.contentY = Math.min(maxContentY, Math.max(minContentY, root.contentY - y));
            velocityCalculator.changePosition(root.contentY);
        }

        function onAppDrawerGridFlickRequested() {
            root.returnToBounds();
            root.flick(0, -velocityCalculator.velocity);
        }
    }

    MobileShell.VelocityCalculator {
        id: velocityCalculator
    }

    model: Folio.ApplicationListModel

    delegate: AppDelegate {
        id: delegate
        shadow: false
        application: model.delegate.application

        width: root.cellWidth
        height: root.cellHeight

        onPressAndHold: {
            const mappedCoords = root.homeScreen.prepareStartDelegateDrag(model.delegate, delegate.delegateItem);
            Folio.HomeScreenState.closeAppDrawer();

            // we need to adjust because app drawer delegates have a different size than regular homescreen delegates
            const centerX = mappedCoords.x + root.cellWidth / 2;
            const centerY = mappedCoords.y + root.cellHeight / 2;

            Folio.HomeScreenState.startDelegateAppDrawerDrag(
                centerX - Folio.HomeScreenState.pageCellWidth / 2,
                centerY - Folio.HomeScreenState.pageCellHeight / 2,
                delegate.pressPosition.x * (Folio.HomeScreenState.pageCellWidth / root.cellWidth),
                delegate.pressPosition.y * (Folio.HomeScreenState.pageCellHeight / root.cellHeight),
                model.delegate.application.storageId
            );
        }
    }

    PC3.ScrollBar.vertical: PC3.ScrollBar {
        id: scrollBar
        interactive: true
        enabled: true
        implicitWidth: Kirigami.Units.smallSpacing

        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.longDuration * 2
                easing.type: Easing.InOutQuad
            }
        }

        contentItem: Rectangle {
            radius: width / 2
            color: Qt.rgba(1, 1, 1, 0.3)
        }
    }
}
