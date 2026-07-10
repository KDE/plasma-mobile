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
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio

MobileShell.GridView {
    id: root

    enum SwipeArea {
        Enable,
        Disable
    }

    property int swipeArea: AppDrawerGrid.SwipeArea.Enable

    property Folio.HomeScreen folio
    property var homeScreen
    property real headerHeight
    property bool currentPage: false

    property real containerTopMargin: 0
    property real containerBottomMargin: 0
    property real containerWidth: width

    cacheBuffer: cellHeight * 20
    reuseItems: true
    layer.enabled: true
    keyNavigationEnabled: true
    keyNavigationWraps: true
    highlightMoveDuration: 0
    highlight: null // We supply our own highlight from the delegate
    boundsBehavior: Flickable.DragAndOvershootBounds

    // HACK: the first swipe from the top of the app drawer is done from HomeScreenState, not the flickable
    //       due to issues with Flickable getting its swipe stolen by SwipeArea
    interactive: (dragging || !atYBeginning || swipeArea === AppDrawerGrid.SwipeArea.Disable) && folio.HomeScreenState.swipeState !== Folio.HomeScreenState.SwipingAppDrawerGrid

    readonly property int baseColumns: Math.min(Math.round(width / (folio.FolioSettings.delegateIconSize * 1 + Kirigami.Units.largeSpacing * 4 + horizontalMargin * 0.5)), 8)
    readonly property int reservedSpaceForLabel: folio.HomeScreenState.pageDelegateLabelHeight
    readonly property real effectiveContentWidth: Math.floor(width - leftMargin - rightMargin)
    readonly property real horizontalMargin: Math.floor(Math.max(Math.round(width * 0.125) - Kirigami.Units.gridUnit * 2.25, Kirigami.Units.largeSpacing))

    onCurrentPageChanged: {
        if (!currentPage) {
            // root.positionViewAtBeginning()
        }
    }

    // Keyboard focus on app delegate when it is the selected item
    onCurrentItemChanged: {
        if (currentItem) {
            currentItem.keyboardFocus();
        }
    }

    Component.onCompleted: Qt.callLater(() => {
        root.contentY = 0 - root.topMargin
    })

    Connections {
        target: folio.HomeScreenState
        enabled: root.currentPage

        function onSwipeStateChanged() {
            if (folio.HomeScreenState.swipeState === Folio.HomeScreenState.SwipingAppDrawerGrid) {
                velocityCalculator.startMeasure();
                velocityCalculator.changePosition(root.contentY);
            }
        }

        function onAppDrawerGridYChanged(y) {
            const maxContentY = Math.max(0, root.contentHeight - root.height);
            let contentY = root.contentY - y;

            if (root.contentHeight < root.height) {
                // prevent bottom overscroll only if contents are smaller than the view
                contentY = Math.min(maxContentY, contentY);
            }

            root.contentY = contentY;
            velocityCalculator.changePosition(root.contentY);
        }

        function onAppDrawerGridFlickRequested() {
            root.flick(0, -velocityCalculator.velocity);
        }
    }

    MobileShell.VelocityCalculator {
        id: velocityCalculator
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
