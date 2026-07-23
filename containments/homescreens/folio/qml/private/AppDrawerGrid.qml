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

    property Folio.HomeScreen folio
    property var homeScreen

    cacheBuffer: cellHeight * 20
    reuseItems: true
    layer.enabled: true
    keyNavigationEnabled: true
    highlightMoveDuration: 0
    highlight: null // We supply our own highlight from the delegate
    boundsBehavior: Flickable.DragAndOvershootBounds

    // HACK: the first swipe from the top of the app drawer is done from HomeScreenState, not the flickable
    //       due to issues with Flickable getting its swipe stolen by SwipeArea
    interactive: (dragging || !atYBeginning) && folio.HomeScreenState.swipeState !== Folio.HomeScreenState.SwipingAppDrawerGrid

    readonly property real __iconCellPadding: Kirigami.Units.largeSpacing * 5 // extra space reserved around the icons to fit comfortably within the grid
    readonly property real __horizontalMarginLowerLimit: Kirigami.Units.largeSpacing
    readonly property real __horizontalMarginUpperLimit: Kirigami.Units.gridUnit * 26

    // this value represent how many app icons can comfortably fit on the screen with a lower limit of the homescreen column value and a upper limit of 8
    // we add a portion of the `horizontalMargin` value to the icon size to make sure the column value does not grow as much for the wider screen sizes
    readonly property int baseColumns: Math.min(Math.max(Math.round(width / (folio.FolioSettings.delegateIconSize + __iconCellPadding + horizontalMargin * 0.5)), folio.FolioSettings.homeScreenColumns), 8)
    readonly property real effectiveContentWidth: width - leftMargin - rightMargin
    // make sure we set a lower limit for the `baseHorizontalMargin` and `horizontalMargin` so it never goes under `__horizontalMarginLowerLimit`
    readonly property real baseHorizontalMargin: Math.max(Math.round(width * 0.125) - Kirigami.Units.gridUnit * 2.25, __horizontalMarginLowerLimit)
    // we set an upper limit for the horizontal margins, as aesthetically for a grid full of apps, it looks better to not let the padding get too exessive
    readonly property real horizontalMargin: Math.min(Math.max((root.width - __horizontalMarginUpperLimit) * 0.5, __horizontalMarginLowerLimit), baseHorizontalMargin)

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
