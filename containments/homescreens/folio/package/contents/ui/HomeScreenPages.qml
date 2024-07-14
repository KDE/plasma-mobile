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
    property Folio.HomeScreen folio

    property var homeScreen

    readonly property real verticalMargin: Math.round((folio.HomeScreenState.pageHeight - folio.HomeScreenState.pageContentHeight) / 2)
    readonly property real horizontalMargin: Math.round((folio.HomeScreenState.pageWidth - folio.HomeScreenState.pageContentWidth) / 2)

    onPressAndHold: folio.HomeScreenState.openSettingsView()

    Repeater {
        model: folio.PageListModel

        delegate: HomeScreenPage {
            id: homeScreenPage
            folio: root.folio
            pageNum: model.index
            pageModel: model.delegate
            homeScreen: root.homeScreen

            anchors.fill: root
            anchors.leftMargin: root.horizontalMargin
            anchors.rightMargin: root.horizontalMargin
            anchors.topMargin: root.verticalMargin
            anchors.bottomMargin: root.verticalMargin

            // animation so that full opacity is only when the page is in view
            readonly property real distanceToCenter: Math.abs(-folio.HomeScreenState.pageViewX - root.width * pageNum)
            readonly property real positionX: root.width * index + folio.HomeScreenState.pageViewX
            readonly property real progressToCenter: 1 - Math.min(1, Math.max(0, distanceToCenter / root.width))

            visible: opacity > 0
            opacity: {
                switch (folio.FolioSettings.pageTransitionEffect) {
                    case Folio.FolioSettings.StackTransition:
                        return (positionX < 0) ? progressToCenter :
                            ((progressToCenter < 0.3) ? 0 : ((1 / 0.7) * (progressToCenter - 0.3)))
                    default:
                        return progressToCenter;
                }
            }

            // x position of page
            transform: {
                switch (folio.FolioSettings.pageTransitionEffect) {
                    case Folio.FolioSettings.SlideTransition:
                        return [translate];
                    case Folio.FolioSettings.CubeTransition:
                        return [translate, cubeTransitionRotation];
                    case Folio.FolioSettings.FadeTransition:
                        return [];
                    case Folio.FolioSettings.StackTransition:
                        return [stackScale, stackTranslate];
                    case Folio.FolioSettings.RotationTransition:
                        return [translate, rotationTransitionRotation];
                    default:
                        return [translate];
                }
            }

            Translate {
                id: translate
                x: homeScreenPage.positionX
            }

            Scale {
                id: stackScale
                origin.x: folio.HomeScreenState.pageWidth / 2
                origin.y: folio.HomeScreenState.pageHeight / 2
                xScale: (homeScreenPage.positionX < 0) ? 1 : 0.5 + homeScreenPage.progressToCenter * 0.5
                yScale: (homeScreenPage.positionX < 0) ? 1 : 0.5 + homeScreenPage.progressToCenter * 0.5
            }

            Translate {
                id: stackTranslate
                x: Math.min(0, homeScreenPage.positionX)
            }

            Rotation {
                id: cubeTransitionRotation
                origin.x: (positionX < 0) ?
                            (folio.HomeScreenState.pageWidth / 2) * homeScreenPage.progressToCenter :
                            (folio.HomeScreenState.pageWidth / 2) + (folio.HomeScreenState.pageWidth / 2) * (1 - homeScreenPage.progressToCenter);
                origin.y: folio.HomeScreenState.pageHeight / 2;
                axis { x: 0; y: 1; z: 0 }
                angle: {
                    return Math.min(1, Math.max(0, distanceToCenter / root.width)) * 90 * ((positionX > 0) ? 1 : -1)
                }
            }

            Rotation {
                id: rotationTransitionRotation
                origin.x: (positionX < 0) ?
                            (folio.HomeScreenState.pageWidth / 2) * homeScreenPage.progressToCenter :
                            (folio.HomeScreenState.pageWidth / 2) + (folio.HomeScreenState.pageWidth / 2) * (1 - homeScreenPage.progressToCenter);
                origin.y: 0
                axis { x: -0.2; y: 0.3; z: 0.5 }
                angle: {
                    return Math.min(1, Math.max(0, distanceToCenter / root.width)) * 90 * ((positionX > 0) ? 1 : -1)
                }
            }
        }
    }
}
