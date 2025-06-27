// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Effects

import org.kde.private.mobile.homescreen.folio 1.0 as Folio

AbstractDelegate {
    id: root
    name: folder.name
    shadow: true

    property Folio.FolioApplicationFolder folder

    property bool appHoveredOver: false

    contentItem: DelegateFolderIcon {
        folio: root.folio
        maskManager: root.maskManager
        folder: root.folder
        expandBackground: root.appHoveredOver
    }
}


