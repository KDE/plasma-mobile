/*
    SPDX-FileCopyrightText: 2026 Micah Stanley <stanleymicah@proton.me>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami
import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio
import "./delegate"

AppDrawerGrid {
    id: root
    property var categoryAppGrid

    readonly property int columns: Math.max(baseColumns - 2, 1)

    readonly property real rawCellWidth: (containerWidth / columns)
    readonly property real categoryFolderSize: Math.min(folio.FolioSettings.delegateIconSize * 2 + categoryFolderRadius * 2.75, rawCellWidth - Kirigami.Units.gridUnit - Kirigami.Units.largeSpacing)
    readonly property real categoryFolderRadius: (folio.FolioSettings.delegateIconSize * 2) * 0.125

    cellWidth: effectiveContentWidth / columns
    cellHeight: cellWidth + reservedSpaceForLabel + Math.max(Kirigami.Units.gridUnit * 0.2 + (cellWidth - categoryFolderSize) * 0.4, Kirigami.Units.gridUnit * 0.2)

    topMargin: -containerTopMargin + Kirigami.Units.largeSpacing
    bottomMargin: -containerBottomMargin
    leftMargin: Math.floor(Math.max(((width - Math.max((categoryFolderSize * columns), Kirigami.Units.gridUnit * (columns > 1 ? 26 : 0))) * 0.5) - Kirigami.Units.gridUnit, Kirigami.Units.gridUnit))
    rightMargin: leftMargin

    signal expandCategory(expandCategoryButton: var, category: string)

    delegate: CategoryDelegate {
        folio: root.folio
        homeScreen: root.homeScreen
        categoryAppGrid: root.categoryAppGrid
        width: root.cellWidth
        height: root.cellHeight
        category: modelData

        categoryFolderSize: root.categoryFolderSize
        categoryFolderRadius: root.categoryFolderRadius

        function keyboardFocus() {
            forceActiveFocus();
        }

        onExpandCategory: (expandCategoryButton, category) => root.expandCategory(expandCategoryButton, category)
    }
}
