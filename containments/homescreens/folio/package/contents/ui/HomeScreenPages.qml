// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window
import QtQuick.Layouts

import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami 2.10 as Kirigami
import org.kde.private.mobile.homescreen.folio 1.0 as Folio

MouseArea {
    id: root

    property var homeScreen

    readonly property real verticalMargin: Math.round((Folio.HomeScreenState.pageHeight - Folio.HomeScreenState.pageContentHeight) / 2)
    readonly property real horizontalMargin: Math.round((Folio.HomeScreenState.pageWidth - Folio.HomeScreenState.pageContentWidth) / 2)

    onPressAndHold: Folio.HomeScreenState.openSettingsView()

    Repeater {
        model: Folio.PageListModel

        delegate: HomeScreenPage {
            id: homeScreenPage
            pageNum: model.index
            pageModel: model.delegate
            homeScreen: root.homeScreen

            anchors.fill: root
            anchors.leftMargin: root.horizontalMargin
            anchors.rightMargin: root.horizontalMargin
            anchors.topMargin: root.verticalMargin
            anchors.bottomMargin: root.verticalMargin

            // animation so that full opacity is only when the page is in view
            opacity: 1 - Math.min(1, Math.max(0, Math.abs(-Folio.HomeScreenState.pageViewX - root.width * pageNum) / root.width))

            // x position of page
            transform: Translate {
                x: root.width * index + Folio.HomeScreenState.pageViewX
            }
        }
    }
}
