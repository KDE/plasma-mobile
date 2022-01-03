/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *  SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "../components" as Components

Components.BaseItem {
    id: root
    
    visible: mpris2Source.hasPlayer
    padding: visible ? Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing : 0
    implicitHeight: visible ? bottomPadding + topPadding + PlasmaCore.Units.gridUnit * 2 + PlasmaCore.Units.smallSpacing : 0
    
    background: BlurredBackground {
        imageSource: mpris2Source.albumArt
    }
    
    contentItem: PlasmaCore.ColorScope {
        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        width: root.width - root.leftPadding - root.rightPadding
        
        MediaControlsSource {
            id: mpris2Source
        }
        
        RowLayout {
            id: controlsRow
            width: parent.width
            height: parent.height
            spacing: 0

            enabled: mpris2Source.canControl

            Image {
                id: albumArt
                Layout.preferredWidth: height
                Layout.fillHeight: true
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                source: mpris2Source.albumArt
                sourceSize.height: height
                visible: status === Image.Loading || status === Image.Ready
            }

            ColumnLayout {
                Layout.leftMargin: albumArt.visible ? Kirigami.Units.largeSpacing : 0
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                QQC2.Label {
                    Layout.fillWidth: true
                    wrapMode: Text.NoWrap
                    elide: Text.ElideRight
                    text: mpris2Source.track || i18n("No media playing")
                    textFormat: Text.PlainText
                    font.pointSize: PlasmaCore.Theme.defaultFont.pointSize
                    maximumLineCount: 1
                    color: "white"
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    wrapMode: Text.NoWrap
                    elide: Text.ElideRight
                    // if no artist is given, show player name instead
                    text: mpris2Source.artist || mpris2Source.identity || ""
                    textFormat: Text.PlainText
                    font.pointSize: PlasmaCore.Theme.smallestFont.pointSize
                    maximumLineCount: 1
                    opacity: 0.9
                    color: "white"
                }
            }

            PlasmaComponents3.ToolButton {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                
                enabled: mpris2Source.canGoBack
                icon.name: LayoutMirroring.enabled ? "media-skip-forward" : "media-skip-backward"
                icon.width: PlasmaCore.Units.iconSizes.small
                icon.height: PlasmaCore.Units.iconSizes.small
                onClicked: mpris2Source.goPrevious()
                visible: mpris2Source.canGoBack || mpris2Source.canGoNext
                Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Previous track")
            }

            PlasmaComponents3.ToolButton {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                
                icon.name: mpris2Source.playing ? "media-playback-pause" : "media-playback-start"
                icon.width: PlasmaCore.Units.iconSizes.small
                icon.height: PlasmaCore.Units.iconSizes.small
                onClicked: mpris2Source.playPause()
                Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Play or Pause media")
            }

            PlasmaComponents3.ToolButton {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                
                enabled: mpris2Source.canGoNext
                icon.name: LayoutMirroring.enabled ? "media-skip-backward" : "media-skip-forward"
                icon.width: PlasmaCore.Units.iconSizes.small
                icon.height: PlasmaCore.Units.iconSizes.small
                onClicked: mpris2Source.goNext()
                visible: mpris2Source.canGoBack || mpris2Source.canGoNext
                Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Next track")
            }
        }
    }
}
