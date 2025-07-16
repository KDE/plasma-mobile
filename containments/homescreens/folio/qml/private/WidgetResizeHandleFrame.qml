// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio

import '../delegate'

Item {
    id: root
    property Folio.HomeScreen folio

    // given by parent:

    property real widgetWidth
    property real widgetHeight
    property real widgetX
    property real widgetY

    property real widgetTopMargin
    property real widgetBottomMargin
    property real widgetLeftMargin
    property real widgetRightMargin

    property int widgetRow
    property int widgetColumn
    property int widgetGridWidth
    property int widgetGridHeight

    // filled here, given to parent:

    // what the drag intends for the dimensions and position of the widget
    property int widgetRowAfterDrag: 0
    property int widgetColumnAfterDrag: 0
    property int widgetGridWidthAfterDrag: 0
    property int widgetGridHeightAfterDrag: 0

    property var lockDrag: null

    property alias handleContainer: handleContainer

    signal widgetChangeAfterDrag(int widgetRow, int widgetColumn, int widgetGridWidth, int widgetGridHeight)

    // solely used here:

    property real startDragWidth: 0
    property real startDragHeight: 0
    property real startX: 0
    property real startY: 0

    property int startWidgetRow: 0
    property int startWidgetColumn: 0

    onWidgetWidthChanged: {
        if (lockDrag === null) updateDimensions();
    }
    onWidgetHeightChanged: {
        if (lockDrag === null) updateDimensions();
    }
    onWidgetXChanged: {
        if (lockDrag === null) updateDimensions();
    }
    onWidgetYChanged: {
        if (lockDrag === null) updateDimensions();
    }

    function updateDimensions() {
        handleContainer.width = widgetWidth;
        handleContainer.height = widgetHeight;
        handleContainer.x = widgetX;
        handleContainer.y = widgetY;
    }

    function startDrag() {
        startDragWidth = handleContainer.width;
        startDragHeight = handleContainer.height;
        startX = handleContainer.x;
        startY = handleContainer.y;

        startWidgetRow = root.widgetRow;
        startWidgetColumn = root.widgetColumn;

        root.widgetChangeAfterDrag(startWidgetRow, startWidgetColumn, root.widgetGridWidth, root.widgetGridHeight);
    }

    function snapEdges() {
        lockDrag = null;

        // snaps the bounds to what we ended up at
        widthAnim.to = widgetWidth;
        widthAnim.restart();
        heightAnim.to = widgetHeight;
        heightAnim.restart();
        xAnim.to = widgetX;
        xAnim.restart();
        yAnim.to = widgetY;
        yAnim.restart();
    }

    function pressedHandler(orientation) {
        if (root.lockDrag !== orientation) {
            root.startDrag();
            root.lockDrag = orientation;
        }
    }

    function dragHandler(orientation, leftEdgeDelta, rightEdgeDelta, topEdgeDelta, bottomEdgeDelta) {
        if (root.lockDrag === orientation) {
            // update the handle container dimensions and position
            handleContainer.x = root.startX - leftEdgeDelta;
            handleContainer.y = root.startY - topEdgeDelta;
            handleContainer.width = root.startDragWidth + rightEdgeDelta + leftEdgeDelta;
            handleContainer.height = root.startDragHeight + bottomEdgeDelta + topEdgeDelta;

            // update the widget dimensions and position
            const columnsMovedRight = Math.round((handleContainer.x - root.startX) / folio.HomeScreenState.pageCellWidth);
            const rowsMovedDown = Math.round((handleContainer.y - root.startY) / folio.HomeScreenState.pageCellHeight);

            const realWidgetWidth = handleContainer.width + widgetLeftMargin + widgetRightMargin;
            const realWidgetHeight = handleContainer.height + widgetTopMargin + widgetBottomMargin;

            const widgetRowAfterDrag = startWidgetRow + rowsMovedDown;
            const widgetColumnAfterDrag = startWidgetColumn + columnsMovedRight;
            const widgetGridWidthAfterDrag = Math.round(realWidgetWidth / folio.HomeScreenState.pageCellWidth);
            const widgetGridHeightAfterDrag = Math.round(realWidgetHeight / folio.HomeScreenState.pageCellHeight);

            root.widgetChangeAfterDrag(widgetRowAfterDrag, widgetColumnAfterDrag, widgetGridWidthAfterDrag, widgetGridHeightAfterDrag);
        }
    }

    function releaseHandler(orientation) {
        if (root.lockDrag === orientation) {
            root.snapEdges();
        }
    }

    Item {
        id: handleContainer

        NumberAnimation on width {
            id: widthAnim
            duration: 200
            easing.type: Easing.InOutQuad
        }

        NumberAnimation on height {
            id: heightAnim
            duration: 200
            easing.type: Easing.InOutQuad
        }

        NumberAnimation on x {
            id: xAnim
            duration: 200
            easing.type: Easing.InOutQuad
        }

        NumberAnimation on y {
            id: yAnim
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    Rectangle {
        id: resizeOutline
        color: 'transparent'
        border.color: 'white'
        radius: Kirigami.Units.cornerRadius
        border.width: 1

        anchors.fill: handleContainer
        anchors.leftMargin: -root.widgetLeftMargin
        anchors.rightMargin: -root.widgetRightMargin
        anchors.topMargin: -root.widgetTopMargin
        anchors.bottomMargin: -root.widgetBottomMargin
    }

    WidgetResizeHandle {
        id: topHandle
        orientation: WidgetHandlePosition.TopCenter

        x: resizeOutline.x + Math.round(resizeOutline.width / 2) - Math.round(width / 2)
        y: resizeOutline.y - Math.round(height / 2)

        width: Math.round(Math.max(height, resizeOutline.width * 0.3)) + touchPadding * 2

        onPressed: pressedHandler(orientation)
        onDragEvent: (leftEdgeDelta, rightEdgeDelta, topEdgeDelta, bottomEdgeDelta) => dragHandler(orientation, leftEdgeDelta, rightEdgeDelta, topEdgeDelta, bottomEdgeDelta)
        onReleased: releaseHandler(orientation)
    }

    WidgetResizeHandle {
        id: leftHandle
        orientation: WidgetHandlePosition.LeftCenter

        x: resizeOutline.x - (width / 2)
        y: resizeOutline.y + (resizeOutline.height / 2) - (height / 2)

        height: Math.round(Math.max(width, resizeOutline.height * 0.3)) + touchPadding * 2

        onPressed: pressedHandler(orientation)
        onDragEvent: (leftEdgeDelta, rightEdgeDelta, topEdgeDelta, bottomEdgeDelta) => dragHandler(orientation, leftEdgeDelta, rightEdgeDelta, topEdgeDelta, bottomEdgeDelta)
        onReleased: releaseHandler(orientation)
    }

    WidgetResizeHandle {
        id: rightHandle
        orientation: WidgetHandlePosition.RightCenter

        x: resizeOutline.x + resizeOutline.width - (width / 2)
        y: resizeOutline.y + (resizeOutline.height / 2) - (height / 2)

        height: Math.round(Math.max(width, resizeOutline.height * 0.3)) + touchPadding * 2

        onPressed: pressedHandler(orientation)
        onDragEvent: (leftEdgeDelta, rightEdgeDelta, topEdgeDelta, bottomEdgeDelta) => dragHandler(orientation, leftEdgeDelta, rightEdgeDelta, topEdgeDelta, bottomEdgeDelta)
        onReleased: releaseHandler(orientation)
    }

    WidgetResizeHandle {
        id: bottomHandle
        orientation: WidgetHandlePosition.BottomCenter

        x: resizeOutline.x + (resizeOutline.width / 2) - (width / 2)
        y: resizeOutline.y + resizeOutline.height - (height / 2)

        width: Math.round(Math.max(height, resizeOutline.width * 0.3)) + touchPadding * 2

        onPressed: pressedHandler(orientation)
        onDragEvent: (leftEdgeDelta, rightEdgeDelta, topEdgeDelta, bottomEdgeDelta) => dragHandler(orientation, leftEdgeDelta, rightEdgeDelta, topEdgeDelta, bottomEdgeDelta)
        onReleased: releaseHandler(orientation)
    }
}
