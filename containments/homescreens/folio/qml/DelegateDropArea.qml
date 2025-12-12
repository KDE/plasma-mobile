// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick

import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio

DropArea {
    id: root
    property Folio.HomeScreen folio
    property Folio.HomeScreenState homeScreenState: folio.HomeScreenState

    keys: ["text/x-plasmoidservicename"]

    property real prevX
    property real prevY

    onEntered: (drag) => {
        drag.accept();
        const widthOffset = folio.HomeScreenState.pageCellWidth / 2;
        const heightOffset = folio.HomeScreenState.pageCellHeight / 2;

        homeScreenState.startDelegateWidgetListDrag(
            drag.x - widthOffset,
            drag.y - heightOffset,
            widthOffset,
            heightOffset,
            drag.getDataAsString("text/x-plasmoidservicename")
        );

        homeScreenState.dragStart();
        prevX = drag.x;
        prevY = drag.y;
    }
    onDropped: (drop) => {
        drop.accept();
        dropWaitTimer.restart();
    }
    onExited: {
        homeScreenState.dragCancel();
    }
    onPositionChanged: (drag) => {
        drag.accept();
        homeScreenState.dragMove(drag.x - prevX, drag.y - prevY);
        prevX = drag.x;
        prevY = drag.y;
    }

    // HACK: Seems to crash otherwise, Qt bug?
    Timer {
        id: dropWaitTimer
        interval: 10
        onTriggered: {
            homeScreenState.dragDrop();
        }
    }
}
