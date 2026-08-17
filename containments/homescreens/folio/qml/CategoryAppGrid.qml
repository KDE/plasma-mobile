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
    interactive: opened
    keyNavigationWraps: true

    readonly property real baseVisualScale: root.categoryFolderIconScale + ((1.0 - root.categoryFolderIconScale) * root.animationProgress)

    property string __category: ""
    property var __categoryGridTarget
    property var __expandTarget

    property bool opened: false
    property bool keepVisibleForDrag: false

    property real animationProgress: 0.0

    // global expansion anchor points
    property real __originX: width * 0.5
    property real __originY: height * 0.5
    readonly property real folderIconSize: folio.FolioSettings.delegateIconSize

    onWidthChanged: updateTargetPosition(__categoryGridTarget, __expandTarget)
    onHeightChanged: updateTargetPosition(__categoryGridTarget, __expandTarget)

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
    readonly property int bottomRightColumn: Math.min((root.count <= root.columns ? Math.max(0, root.count - 1) : (root.columns - 1)) - (bottomLeftRow > 0 ? 0 : 1), root.count - (bottomRightRow * root.columns) - 1)
    readonly property int bottomRightRow: root.count <= root.columns ? 0 : ((root.count % root.columns === 0 || root.count <= root.columns * 2) ? (totalRows - 1) : (totalRows - 2))

    readonly property real expectedContentHeight: totalRows * cellHeight
    readonly property real verticalCenterOffset: expectedContentHeight > 0 && expectedContentHeight < root.height ? (root.height - expectedContentHeight - (Kirigami.Units.gridUnit * 3)) * 0.5 : 0

    topMargin: Math.max(verticalCenterOffset - containerTopMargin + Kirigami.Units.largeSpacing - __appDelegateTopMargin, Kirigami.Units.gridUnit * 3)
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

        interactive: root.opened

        opacity: root.animationProgress

        // index based grid centers
        readonly property int column: index % root.columns
        readonly property int row: Math.floor(index / root.columns)
        readonly property real labelOffset: (folio.HomeScreenState.pageDelegateLabelHeight + folio.HomeScreenState.pageDelegateLabelSpacing) * -0.25
        readonly property real stableCenterX: root.leftMargin + column * root.cellWidth + root.cellWidth * 0.5
        readonly property real stableCenterY: labelOffset + root.topMargin + row * root.cellHeight + root.cellHeight * 0.5

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

        readonly property real currentVisualCenterX: stableCenterX - (deltaX * (1.0 - easedProgress))
        readonly property real currentVisualCenterY: stableCenterY - (deltaY * (1.0 - easedProgress))

        readonly property real scaleOffsetX: (currentVisualCenterX - root.__originX) * (root.baseVisualScale - 1.0)
        readonly property real scaleOffsetY: (currentVisualCenterY - root.__originY) * (root.baseVisualScale - 1.0)

        transform: [
            Scale {
                origin.x: delegateItem.width * 0.5
                origin.y: delegateItem.height * 0.5
                xScale: (delegateItem.startScale + ((1.0 - delegateItem.startScale) * delegateItem.easedProgress)) * root.baseVisualScale
                yScale: (delegateItem.startScale + ((1.0 - delegateItem.startScale) * delegateItem.easedProgress)) * root.baseVisualScale
            },
            Translate {
                x: -(delegateItem.deltaX * (1.0 - delegateItem.easedProgress)) + delegateItem.scaleOffsetX
                y: -(delegateItem.deltaY * (1.0 - delegateItem.easedProgress)) + delegateItem.scaleOffsetY
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

            // the center coordinate during the standard animation
            let currentCenterX = startX + (endX - startX) * root.animationProgress;

            // pull the center towards __originX based on baseVisualScale
            let scaledCenterX = root.__originX + (currentCenterX - root.__originX) * root.baseVisualScale;

            return scaledCenterX - root.halfMiniIcon;
        }

        function getInterpolatedY(isTop, targetRow) {
            let labelOffset = (folio.HomeScreenState.pageDelegateLabelHeight + folio.HomeScreenState.pageDelegateLabelSpacing) * -0.5;

            let startY = root.__originY + (isTop ? (-(root.miniSpacing * 0.5) - root.halfMiniIcon) : ((root.miniSpacing * 0.5) + root.halfMiniIcon));
            let endY = labelOffset + root.topMargin + targetRow * root.cellHeight + root.cellHeight * 0.5;

            // the center coordinate during the standard animation
            let currentCenterY = startY + (endY - startY) * root.animationProgress;

            // pull the center towards __originY based on baseVisualScale
            let scaledCenterY = root.__originY + (currentCenterY - root.__originY) * root.baseVisualScale;

            return scaledCenterY - root.halfMiniIcon;
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

            scale: (0.5 + (0.5 * root.animationProgress)) * root.baseVisualScale

            visible: root.count > 3
            source: visible && root.__category && root.model.get(0, "delegate") ? root.model.get(3, "delegate").application.icon : "unknown"
        }

        // top right icon
        DelegateAppIcon {
            x: fakeGridOverlay.getInterpolatedX(false, root.topRightColumn) - fakeGridOverlay.centerOffset
            y: fakeGridOverlay.getInterpolatedY(true, root.topRightRow) - fakeGridOverlay.centerOffset
            width: root.folderIconSize
            height: root.folderIconSize
            scale: (0.5 + (0.5 * root.animationProgress)) * root.baseVisualScale
            visible: root.count > 4
            source: visible && root.__category && root.model.get(1, "delegate") ? root.model.get(4, "delegate").application.icon : "unknown"
        }

        // bottom left icon
        DelegateAppIcon {
            x: fakeGridOverlay.getInterpolatedX(true, root.bottomLeftColumn) - fakeGridOverlay.centerOffset
            y: fakeGridOverlay.getInterpolatedY(false, root.bottomLeftRow) - fakeGridOverlay.centerOffset
            width: root.folderIconSize
            height: root.folderIconSize
            scale: (0.5 + (0.5 * root.animationProgress)) * root.baseVisualScale
            visible: root.count > 5
            source: visible && root.__category && root.model.get(2, "delegate") ? root.model.get(5, "delegate").application.icon : "unknown"
        }

        // bottom right icon
        DelegateAppIcon {
            x: fakeGridOverlay.getInterpolatedX(false, root.bottomRightColumn) - fakeGridOverlay.centerOffset
            y: fakeGridOverlay.getInterpolatedY(false, root.bottomRightRow) - fakeGridOverlay.centerOffset
            width: root.folderIconSize
            height: root.folderIconSize
            scale: (0.5 + (0.5 * root.animationProgress)) * root.baseVisualScale
            visible: root.count > 6
            source: visible && root.__category && root.model.get(3, "delegate") ? root.model.get(6, "delegate").application.icon : "unknown"
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
                duration: 800
                easing.type: Easing.OutExpo
            }
        },
        Transition {
            from: "opened"; to: "closed"
            ParallelAnimation {
                NumberAnimation {
                    property: "animationProgress"
                    duration: 700
                    easing.type: Easing.OutExpo
                }
                NumberAnimation {
                    property: "contentY"
                    duration: 700
                    easing.type: Easing.OutExpo
                }
            }
        }
    ]

    model: Folio.ApplicationListSearchModel {
        sourceModel: root.folio.ApplicationListModel
        categoryFilter: root.__category
    }

    function expandCategory(categoryGrid: var, expandCategoryButton: var, categoryTitle: string) {
        updateTargetPosition(categoryGrid, expandCategoryButton);

        root.__category = categoryTitle;
        root.__categoryGridTarget = categoryGrid;
        root.__expandTarget = expandCategoryButton;
        root.opened = true;

        root.contentY = -root.originY - root.topMargin;
        root.returnToBounds();

        Qt.callLater(() => {
            root.forceActiveFocus();
        });
    }

    function closeCategory() {
        root.opened = false;
        root.updateTargetPosition(root.__categoryGridTarget, root.__expandTarget);

        // return focus to the 2x2 grid that was expanded from
        if (root.__categoryGridTarget) {
            root.__categoryGridTarget.forceActiveFocus();
        }
    }

    function updateTargetPosition(categoryGrid: var, expandCategoryButton: var) {
        if (categoryGrid && expandCategoryButton && expandCategoryButton.width !== undefined && root.parent) {
            let buttonCenterX = expandCategoryButton.width * 0.5;
            let buttonCenterY = expandCategoryButton.height * 0.5;

            let posInGrid = categoryGrid.mapFromItem(expandCategoryButton, buttonCenterX, buttonCenterY);

            let contentContainer = categoryGrid.parent;
            let swipeContainer = contentContainer.parent;

            let xInAppDrawer = posInGrid.x + swipeContainer.x;
            let yInAppDrawer = posInGrid.y + categoryGrid.y + contentContainer.y + swipeContainer.y;

            root.__originX = xInAppDrawer - root.x;
            root.__originY = yInAppDrawer - root.y;
        } else {
            root.__originX = root.width * 0.5;
            root.__originY = root.height * 0.5;
        }
    }

    Keys.onEscapePressed: (event) => { closeCategory(); event.accepted = true; }
    Keys.onBackPressed: (event) => { closeCategory(); event.accepted = true; }

    Connections {
        target: root.__categoryGridTarget
        enabled: root.visible

        function onContentYChanged() {
            root.updateTargetPosition(root.__categoryGridTarget, root.__expandTarget);
        }
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
        function onAppDrawerPageXChanged() {
            if (!root.visible) return;
            root.updateTargetPosition(root.__categoryGridTarget, root.__expandTarget);
        }
    }

    TapHandler {
        enabled: root.interactive
        onTapped: root.closeCategory()
    }
}
