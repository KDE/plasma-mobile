/*
    SPDX-FileCopyrightText: 2026 Micah Stanley <stanleymicah@proton.me>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell

import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio

import "./delegate"
import "./private"

AppDrawerAppGrid {
    id: root

    visible: opened || animationProgress > 0 || keepVisibleForDrag
    swipeArea: AppDrawerGrid.SwipeArea.Disable
    scale: root.categoryFolderIconScale + ((1 - root.categoryFolderIconScale) * root.animationProgress)
    interactive: opened

    property string __category: ""
    property var __expandTarget

    property bool opened: false
    property bool keepVisibleForDrag: false

    property real animationProgress: 0.0

    // global expansion anchor points
    property real __originX: width * 0.5
    property real __originY: height * 0.5
    readonly property real folderIconSize: folio.FolioSettings.delegateIconSize

    readonly property real totalRows: Math.max(1, Math.ceil(root.count / root.columns))
    readonly property real miniSpacing: __expandTarget ? __expandTarget.columnSpacing * 0.5 : 0
    readonly property real categoryFolderIconScale: __expandTarget ? __expandTarget.scale : 1
    readonly property real halfMiniIcon: (root.folderIconSize * 0.5) * 0.5

    readonly property int topLeftColumn: 0
    readonly property int topLeftRow: 0

    readonly property int topRightColumn: Math.max(0, Math.min(root.count - 1, root.columns - 1))
    readonly property int topRightRow: 0

    // the bottom left corner dynamically shifts left a space to the right if there is only 1 row of space available
    readonly property int bottomLeftColumn: bottomLeftRow > 0 ? 0 : 1
    readonly property int bottomLeftRow: Math.max(0, totalRows - 1)

    // the bottom right corner dynamically shifts up if the last row does not reach the right edge
    // this corner also shifts left a space if there is only 1 row of space available
    readonly property int bottomRightColumn: (root.count <= root.columns ? Math.max(0, root.count - 1) : (root.columns - 1)) - (bottomLeftRow > 0 ? 0 : 1)
    readonly property int bottomRightRow: root.count <= root.columns ? 0 : ((root.count % root.columns === 0) ? (totalRows - 1) : (totalRows - 2))

    readonly property real expectedContentHeight: totalRows * cellHeight
    readonly property real verticalCenterOffset: expectedContentHeight > 0 && expectedContentHeight < root.height ? (root.height - expectedContentHeight) * 0.5 : 0

    topMargin: Math.max(verticalCenterOffset - containerTopMargin + Kirigami.Units.largeSpacing - appDelegateTopMargin, Kirigami.Units.gridUnit * 3)
    bottomMargin: Math.max(verticalCenterOffset - containerBottomMargin, Kirigami.Units.gridUnit * 2)

    MobileShell.HapticsEffect {
        id: haptics
    }

    delegate: AppDelegate {
        id: delegateItem
        folio: root.folio
        shadow: false
        application: model.delegate.application
        width: root.cellWidth
        height: root.cellHeight

        opacity: root.animationProgress

        // index based grid centers
        readonly property int column: index % root.columns
        readonly property int row: Math.floor(index / root.columns)
        readonly property real stableCenterX: root.leftMargin + column * root.cellWidth + root.cellWidth * 0.5
        readonly property real stableCenterY: root.topMargin + row * root.cellHeight + root.cellHeight * 0.5

        readonly property bool isLeftQuadrant: stableCenterX < (root.width * 0.5)
        readonly property bool isTopQuadrant: stableCenterY < (root.height * 0.5)

        // corner distance decay math
        readonly property real distanceTopLeft: Math.sqrt(Math.pow(column - root.topLeftColumn, 2) + Math.pow(row - root.topLeftRow, 2))
        readonly property real distanceTopRight: Math.sqrt(Math.pow(column - root.topRightColumn, 2) + Math.pow(row - root.topRightRow, 2))
        readonly property real distanceBottomLeft: Math.sqrt(Math.pow(column - root.bottomLeftColumn, 2) + Math.pow(row - root.bottomLeftRow, 2))
        readonly property real distanceBottomRight: Math.sqrt(Math.pow(column - root.bottomRightColumn, 2) + Math.pow(row - root.bottomRightRow, 2))

        // find how close this specific item is to any valid corner
        readonly property real minimumCornerDistance: Math.min(distanceTopLeft, Math.min(distanceTopRight, Math.min(distanceBottomLeft, distanceBottomRight)))

        // calculate the maximum possible distance a cell can be from a corner
        readonly property real maximumMinimumDistance: Math.max(1.0, Math.sqrt(Math.pow(root.columns - 1, 2) + Math.pow(root.totalRows - 1, 2)) * 0.5)

        // the normalized distance where 0 is a corner and 1 is at the center of the grid
        readonly property real normalizedDistance: Math.min(1.0, minimumCornerDistance / maximumMinimumDistance)

        readonly property real offsetX: isLeftQuadrant ? (-(root.miniSpacing * 0.5) - root.halfMiniIcon) : ((root.miniSpacing * 0.5) + root.halfMiniIcon)
        readonly property real offsetY: isTopQuadrant ? (-(root.miniSpacing * 0.5) - root.halfMiniIcon) : ((root.miniSpacing * 0.5) + root.halfMiniIcon)

        readonly property real sourceX: root.__originX + (offsetX * (1.0 - normalizedDistance))
        readonly property real sourceY: root.__originY + (offsetY * (1.0 - normalizedDistance))

        readonly property real deltaX: stableCenterX - sourceX
        readonly property real deltaY: stableCenterY - sourceY

        readonly property real easedProgress: Math.pow(root.animationProgress, 1.0 + (normalizedDistance * 0.5))

        readonly property real startScale: Math.max(0.0, 0.5 * (1.0 - normalizedDistance))

        transform: [
            Scale {
                origin.x: delegateItem.width * 0.5
                origin.y: delegateItem.height * 0.5
                xScale: delegateItem.startScale + ((1.0 - delegateItem.startScale) * delegateItem.easedProgress)
                yScale: delegateItem.startScale + ((1.0 - delegateItem.startScale) * delegateItem.easedProgress)
            },
            Translate {
                x: -delegateItem.deltaX * (1.0 - delegateItem.easedProgress)
                y: -delegateItem.deltaY * (1.0 - delegateItem.easedProgress)
            }
        ]

        onPressAndHold: {
            // prevent editing if lock layout is enabled
            if (folio.FolioSettings.lockLayout) return;

            const mappedCoords = root.homeScreen.prepareStartDelegateDrag(model.delegate, delegateItem, true, true);
            folio.HomeScreenState.closeAppDrawer();

            haptics.buttonVibrate();

            // we need to adjust because app drawer delegates have a different size than regular homescreen delegates
            const centerX = mappedCoords.x + root.cellWidth / 2;
            const centerY = mappedCoords.y + root.cellHeight / 2;

            folio.HomeScreenState.startDelegateAppDrawerDrag(
                centerX - folio.HomeScreenState.pageCellWidth / 2,
                centerY - folio.HomeScreenState.pageCellHeight / 2,
                pressPosition.x * (folio.HomeScreenState.pageCellWidth / root.cellWidth),
                pressPosition.y * (folio.HomeScreenState.pageCellHeight / root.cellHeight),
                model.delegate.application.storageId
            );
        }
    }

    Item {
        id: fakeGridOverlay
        anchors.fill: parent
        z: 9999

        transform: [
            Translate {
                y: -root.contentY + root.originY - root.topMargin
            }
        ]

        opacity: 1.0 - root.animationProgress
        visible: opacity > 0

        function getInterpolatedX(isLeft, targetColumn) {
            let startX = root.__originX + (isLeft ? (-(root.miniSpacing * 0.5) - root.halfMiniIcon) : ((root.miniSpacing * 0.5) + root.halfMiniIcon));
            let endX = root.leftMargin + targetColumn * root.cellWidth + root.cellWidth * 0.5;
            return startX + (endX - startX) * root.animationProgress - root.halfMiniIcon;
        }

        function getInterpolatedY(isTop, targetRow) {
            let startY = root.__originY + (isTop ? (-(root.miniSpacing * 0.5) - root.halfMiniIcon) : ((root.miniSpacing * 0.5) + root.halfMiniIcon));
            let endY = root.topMargin + targetRow * root.cellHeight + root.cellHeight * 0.5;
            return startY + (endY - startY) * root.animationProgress - root.halfMiniIcon;
        }

        // offset x and y to compensate for the item's unscaled bounding box being twice as large
        // this keeps the visual center aligned with the getInterpolated logic
        readonly property real centerOffset: root.folderIconSize * 0.25

        // top left icon
        DelegateAppIcon {
            x: fakeGridOverlay.getInterpolatedX(true, root.topLeftColumn) - fakeGridOverlay.centerOffset
            y: fakeGridOverlay.getInterpolatedY(true, root.topLeftRow) - fakeGridOverlay.centerOffset
            width: root.folderIconSize
            height: root.folderIconSize
            scale: 0.5 + (0.5 * root.animationProgress)
            visible: root.count > 3
            source: visible && root.model.get(0, "delegate") ? root.model.get(3, "delegate").application.icon : "unknown"
        }

        // top right icon
        DelegateAppIcon {
            x: fakeGridOverlay.getInterpolatedX(false, root.topRightColumn) - fakeGridOverlay.centerOffset
            y: fakeGridOverlay.getInterpolatedY(true, root.topRightRow) - fakeGridOverlay.centerOffset
            width: root.folderIconSize
            height: root.folderIconSize
            scale: 0.5 + (0.5 * root.animationProgress)
            visible: root.count > 4
            source: visible && root.model.get(1, "delegate") ? root.model.get(4, "delegate").application.icon : "unknown"
        }

        // bottom left icon
        DelegateAppIcon {
            x: fakeGridOverlay.getInterpolatedX(true, root.bottomLeftColumn) - fakeGridOverlay.centerOffset
            y: fakeGridOverlay.getInterpolatedY(false, root.bottomLeftRow) - fakeGridOverlay.centerOffset
            width: root.folderIconSize
            height: root.folderIconSize
            scale: 0.5 + (0.5 * root.animationProgress)
            visible: root.count > 5
            source: visible && root.model.get(2, "delegate") ? root.model.get(5, "delegate").application.icon : "unknown"
        }

        // bottom right icon
        DelegateAppIcon {
            x: fakeGridOverlay.getInterpolatedX(false, root.bottomRightColumn) - fakeGridOverlay.centerOffset
            y: fakeGridOverlay.getInterpolatedY(false, root.bottomRightRow) - fakeGridOverlay.centerOffset
            width: root.folderIconSize
            height: root.folderIconSize
            scale: 0.5 + (0.5 * root.animationProgress)
            visible: root.count > 6
            source: visible && root.model.get(3, "delegate") ? root.model.get(6, "delegate").application.icon : "unknown"
        }
    }

    states: [
        State {
            name: "closed"
            when: !root.opened
            PropertyChanges { target: root; animationProgress: 0.0; contentY: root.originY - root.topMargin }
        },
        State {
            name: "opened"
            when: root.opened
            PropertyChanges { target: root; animationProgress: 1.0 }
        }
    ]

    transitions: [
        Transition {
            from: "closed"; to: "opened"
            NumberAnimation {
                property: "animationProgress"
                duration: 600
                easing.type: Easing.OutExpo
            }
        },
        Transition {
            from: "opened"; to: "closed"
            ParallelAnimation {
                NumberAnimation {
                    property: "animationProgress"
                    duration: 500
                    easing.type: Easing.OutExpo
                }
                NumberAnimation {
                    property: "contentY"
                    duration: 500
                    easing.type: Easing.OutExpo
                }
            }
        }
    ]

    model: Folio.ApplicationListSearchModel {
        sourceModel: root.folio.ApplicationListModel
        categoryFilter: root.__category
    }

    function expandCategory(expandCategoryButton: var, category: string) {
        if (expandCategoryButton && expandCategoryButton.width !== undefined && root.parent) {
            let mapped = root.mapFromItem(expandCategoryButton, expandCategoryButton.width * 0.5, expandCategoryButton.height * 0.5);
            root.__originX = mapped.x;
            root.__originY = mapped.y;
        } else {
            root.__originX = root.width * 0.5;
            root.__originY = root.height * 0.5;
        }

        root.__category = category;
        root.__expandTarget = expandCategoryButton;
        root.opened = true;

        root.contentY = -root.originY - root.topMargin;
        root.returnToBounds();
    }

    function closeCategory() {
        root.opened = false;
    }

    Connections {
        target: folio.HomeScreenState
        function onAppDrawerOpened() { root.opened = false; }
        function onAppDrawerClosed() { root.opened = false; }
        function onSwipeStateChanged() {
            if (folio.HomeScreenState.swipeState === Folio.HomeScreenState.DraggingDelegate) {
                if (root.opened || root.animationProgress > 0) root.keepVisibleForDrag = true;
            } else {
                root.keepVisibleForDrag = false;
            }
        }
    }

    TapHandler {
        onTapped: root.closeCategory()
    }
}
