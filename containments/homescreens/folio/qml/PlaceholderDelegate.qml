// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts

import plasma.applet.org.kde.plasma.mobile.homescreen.folio as Folio
import org.kde.kirigami 2.10 as Kirigami

import "./delegate"

Item {
    id: root
    property Folio.HomeScreen folio

    width: folio.HomeScreenState.pageCellWidth
    height: folio.HomeScreenState.pageCellHeight

    // we need to simulate the position of the icon if it is placed at this spot
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // icon position placement
        Rectangle {
            id: loader
            color: Qt.rgba(255, 255, 255, 0.3)
            radius: Kirigami.Units.cornerRadius

            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.minimumWidth: folio.FolioSettings.delegateIconSize
            Layout.minimumHeight: folio.FolioSettings.delegateIconSize
            Layout.preferredHeight: Layout.minimumHeight
        }

        // simulate a delegate's label for positioning purposes
        DelegateLabel {
            id: label
            opacity: 0
            Layout.fillWidth: true
            Layout.preferredHeight: folio.HomeScreenState.pageDelegateLabelHeight
            Layout.topMargin: folio.HomeScreenState.pageDelegateLabelSpacing
        }
    }
}
