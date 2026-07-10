/*
    SPDX-FileCopyrightText: 2026 Micah Stanley <stanleymicah@proton.me>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio
import "./delegate"
import "./private"

AppDrawerGrid {
    id: root

    readonly property int columns: baseColumns

    cellWidth: Math.floor(effectiveContentWidth / columns)
    cellHeight: Math.max(folio.FolioSettings.delegateIconSize + reservedSpaceForLabel + Kirigami.Units.gridUnit * 2, cellWidth * 0.75)

    readonly property real appDelegateTopMargin: (cellHeight - (folio.FolioSettings.delegateIconSize + folio.HomeScreenState.pageDelegateLabelSpacing + folio.HomeScreenState.pageDelegateLabelHeight)) * 0.5

    topMargin: -containerTopMargin + Kirigami.Units.largeSpacing - appDelegateTopMargin
    bottomMargin: -containerBottomMargin
    leftMargin: Screen.height > Screen.width ? Math.max(Kirigami.Units.largeSpacing, horizontalMargin * 0.25) : Math.min(Math.max((containerWidth - (Kirigami.Units.gridUnit * 26)) * 0.5, Kirigami.Units.largeSpacing), horizontalMargin)
    rightMargin: leftMargin

    MobileShell.HapticsEffect {
        id: haptics
    }

    delegate: AppDelegate {
        folio: root.folio
        shadow: false
        application: model.delegate.application
        width: root.cellWidth
        height: root.cellHeight

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
}
