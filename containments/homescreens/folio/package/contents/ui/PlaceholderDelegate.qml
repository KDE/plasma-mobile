// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts

import org.kde.private.mobile.homescreen.folio 1.0 as Folio
import org.kde.kirigami 2.10 as Kirigami

import "./delegate"

Item {
    id: root
    width: Folio.HomeScreenState.pageCellWidth
    height: Folio.HomeScreenState.pageCellHeight

    // we need to simulate the position of the icon if it is placed at this spot
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // icon position placement
        Rectangle {
            id: loader
            color: Qt.rgba(255, 255, 255, 0.3)
            radius: Kirigami.Units.largeSpacing

            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.minimumWidth: Folio.FolioSettings.delegateIconSize
            Layout.minimumHeight: Folio.FolioSettings.delegateIconSize
            Layout.preferredHeight: Layout.minimumHeight
            layer.enabled: true
            layer.effect: DelegateShadow {}
        }

        // simulate a delegate's label for positioning purposes
        DelegateLabel {
            id: label
            opacity: 0
            Layout.fillWidth: true
            Layout.preferredHeight: Folio.HomeScreenState.pageDelegateLabelHeight
            Layout.topMargin: Folio.HomeScreenState.pageDelegateLabelSpacing
        }
    }
}
