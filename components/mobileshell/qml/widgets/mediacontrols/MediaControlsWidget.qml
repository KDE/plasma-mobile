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

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "../../components" as Components

/**
 * Embeddable component that provides MPRIS control.
 */
Item {
    id: root
    visible: mpris2Source.hasPlayer
    
    readonly property real padding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
    readonly property real contentHeight: PlasmaCore.Units.gridUnit * 2 + PlasmaCore.Units.smallSpacing
    implicitHeight: visible ? padding * 2 + contentHeight : 0
    
    MediaControlsSource {
        id: mpris2Source
    }
    
    // page indicator
    RowLayout {
        z: 1
        visible: view.count > 1
        spacing: Kirigami.Units.smallSpacing
        anchors.bottomMargin: Kirigami.Units.smallSpacing * 2
        anchors.bottom: view.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        
        Repeater {
            model: view.count
            delegate: Rectangle {
                width: Kirigami.Units.smallSpacing
                height: Kirigami.Units.smallSpacing
                radius: width / 2
                color: Qt.rgba(255, 255, 255, view.currentIndex == model.index ? 1 : 0.5)
            }
        }
    }
    
    // list of app media widgets
    QQC2.SwipeView {
        id: view
        clip: true
        
        anchors.fill: parent
        
        Repeater {
            model: mpris2Source.mprisSourcesModel
            
            delegate: Loader {
                active: modelData
                
                asynchronous: true
                
                sourceComponent: MouseArea {
                    id: mouseArea
                    implicitHeight: playerItem.implicitHeight
                    implicitWidth: playerItem.implicitWidth
                    
                    onClicked: {
                        MobileShell.ShellUtil.launchApp(modelData.desktopEntry + ".desktop");
                        MobileShellState.Shell.closeActionDrawer();
                    }
                    
                    Components.BaseItem {
                        id: playerItem
                        anchors.fill: parent
                        
                        property string source: modelData.source
                        
                        padding: root.padding
                        implicitHeight: root.contentHeight + root.padding * 2
                        implicitWidth: root.width
                        
                        background: BlurredBackground {
                            darken: mouseArea.pressed
                            imageSource: mpris2Source.albumArt(playerItem.source)
                        }
                        
                        contentItem: PlasmaCore.ColorScope {
                            colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
                            width: playerItem.width - playerItem.leftPadding - playerItem.rightPadding
                            
                            RowLayout {
                                id: controlsRow
                                width: parent.width
                                height: parent.height
                                spacing: 0

                                enabled: mpris2Source.canControl(playerItem.source)

                                Image {
                                    id: albumArt
                                    Layout.preferredWidth: height
                                    Layout.fillHeight: true
                                    asynchronous: true
                                    fillMode: Image.PreserveAspectFit
                                    source: mpris2Source.albumArt(playerItem.source)
                                    sourceSize.height: height
                                    visible: status === Image.Loading || status === Image.Ready
                                }

                                ColumnLayout {
                                    Layout.leftMargin: albumArt.visible ? Kirigami.Units.largeSpacing : 0
                                    Layout.fillWidth: true
                                    spacing: Kirigami.Units.smallSpacing

                                    Components.MarqueeLabel {
                                        Layout.fillWidth: true

                                        inputText: mpris2Source.track(playerItem.source) || i18n("No media playing")
                                        textFormat: Text.PlainText
                                        font.pointSize: PlasmaCore.Theme.defaultFont.pointSize
                                        color: "white"
                                    }

                                    Components.MarqueeLabel {
                                        Layout.fillWidth: true

                                        // if no artist is given, show player name instead
                                        inputText: mpris2Source.artist(playerItem.source) || modelData.application || ""
                                        textFormat: Text.PlainText
                                        font.pointSize: PlasmaCore.Theme.smallestFont.pointSize
                                        opacity: 0.9
                                        color: "white"
                                    }
                                }

                                PlasmaComponents3.ToolButton {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    
                                    enabled: mpris2Source.canGoBack(playerItem.source)
                                    icon.name: LayoutMirroring.enabled ? "media-skip-forward" : "media-skip-backward"
                                    icon.width: PlasmaCore.Units.iconSizes.small
                                    icon.height: PlasmaCore.Units.iconSizes.small
                                    onClicked: mpris2Source.goPrevious(playerItem.source)
                                    visible: mpris2Source.canGoBack(playerItem.source) || mpris2Source.canGoNext(playerItem.source)
                                    Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Previous track")
                                }

                                PlasmaComponents3.ToolButton {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    
                                    icon.name: mpris2Source.isPlaying(playerItem.source) ? "media-playback-pause" : "media-playback-start"
                                    icon.width: PlasmaCore.Units.iconSizes.small
                                    icon.height: PlasmaCore.Units.iconSizes.small
                                    onClicked: mpris2Source.playPause(playerItem.source)
                                    Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Play or Pause media")
                                }

                                PlasmaComponents3.ToolButton {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    
                                    enabled: mpris2Source.canGoBack(playerItem.source)
                                    icon.name: LayoutMirroring.enabled ? "media-skip-backward" : "media-skip-forward"
                                    icon.width: PlasmaCore.Units.iconSizes.small
                                    icon.height: PlasmaCore.Units.iconSizes.small
                                    onClicked: mpris2Source.goNext(playerItem.source)
                                    visible: mpris2Source.canGoBack(playerItem.source) || mpris2Source.canGoNext(playerItem.source)
                                    Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Next track")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
