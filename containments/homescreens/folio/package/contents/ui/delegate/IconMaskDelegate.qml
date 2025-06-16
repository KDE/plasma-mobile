// SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts

/**
 * Icon mask template component.
 */

AbstractMaskDelegate {
    id: root

    property bool expandBackground: false

    readonly property real scaleAmount: folderIcon.scaleAmount

    ColumnLayout {
        id: icon
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.minimumWidth: folio.FolioSettings.delegateIconSize
            Layout.minimumHeight: folio.FolioSettings.delegateIconSize

            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.preferredHeight: Layout.minimumHeight

            DelegateFolderIcon {
                id: folderIcon
                folio: root.folio
                expandBackground: root.expandBackground
                maskIcon: true
            }
        }

        Item {
            Layout.preferredHeight: folio.HomeScreenState.pageDelegateLabelHeight
            Layout.topMargin: folio.HomeScreenState.pageDelegateLabelSpacing
        }
    }
}
