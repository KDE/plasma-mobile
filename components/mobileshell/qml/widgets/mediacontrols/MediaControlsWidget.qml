// SPDX-FileCopyrightText: 2021-2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.components 3.0 as PlasmaComponents3

import org.kde.plasma.private.mpris as Mpris

/**
 * Embeddable component that provides MPRIS control.
 */
Item {
    id: root
    visible: sourceRepeater.count > 0
    
    readonly property real padding: Kirigami.Units.gridUnit
    readonly property real contentHeight: Kirigami.Units.gridUnit * 2
    implicitHeight: visible ? padding * 2 + contentHeight : 0
    
    MediaControlsSource {
        id: mpris2Source
    }
    
    // page indicator
    RowLayout {
        z: 1
        visible: view.count > 1
        spacing: Kirigami.Units.smallSpacing
        anchors.bottomMargin: Kirigami.Units.smallSpacing
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
            id: sourceRepeater
            model: mpris2Source.mpris2Model
            
            delegate: Loader {
                id: delegate
                // NOTE: model is PlayerContainer from KMpris in plasma-workspace

                asynchronous: true
                
                function getTrackName() {
                    console.log('track name: ' + model.title);
                    if (model.title) {
                        return model.title;
                    }
                    // if no track title is given, print out the file name
                    if (!model.url) {
                        return "";
                    }
                    const lastSlashPos = model.url.lastIndexOf('/')
                    if (lastSlashPos < 0) {
                        return ""
                    }
                    const lastUrlPart = model.url.substring(lastSlashPos + 1);
                    return decodeURIComponent(lastUrlPart);
                }

                sourceComponent: MouseArea {
                    id: mouseArea
                    implicitHeight: playerItem.implicitHeight
                    implicitWidth: playerItem.implicitWidth
                    
                    onClicked: {
                        MobileShell.AppLaunch.launchOrActivateApp(model.desktopEntry + ".desktop");
                        MobileShellState.ShellDBusClient.closeActionDrawer();
                    }
                    
                    MobileShell.BaseItem {
                        id: playerItem
                        anchors.fill: parent
                        
                        padding: root.padding
                        implicitHeight: root.contentHeight + root.padding * 2
                        implicitWidth: root.width
                        
                        background: BlurredBackground {
                            darken: mouseArea.pressed
                            imageSource: model.artUrl
                        }
                        
                        contentItem: Item {
                            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                            Kirigami.Theme.inherit: false
                            width: playerItem.width - playerItem.leftPadding - playerItem.rightPadding
                            
                            RowLayout {
                                id: controlsRow
                                width: parent.width
                                height: parent.height
                                spacing: 0

                                enabled: model.canControl

                                Image {
                                    id: albumArt
                                    Layout.preferredWidth: height
                                    Layout.fillHeight: true
                                    asynchronous: true
                                    fillMode: Image.PreserveAspectFit
                                    source: model.artUrl
                                    sourceSize.height: height
                                    visible: status === Image.Loading || status === Image.Ready
                                }

                                ColumnLayout {
                                    Layout.leftMargin: albumArt.visible ? Kirigami.Units.gridUnit : 0
                                    Layout.fillWidth: true
                                    spacing: Kirigami.Units.smallSpacing

                                    // media track name text
                                    MobileShell.MarqueeLabel {
                                        id: trackLabel
                                        Layout.fillWidth: true

                                        inputText: model.track || i18n("No media playing");
                                        textFormat: Text.PlainText
                                        font.pointSize: Kirigami.Theme.defaultFont.pointSize
                                        color: "white"
                                    }

                                    // media artist name text
                                    MobileShell.MarqueeLabel {
                                        id: artistLabel
                                        Layout.fillWidth: true

                                        // if no artist is given, show player name instead
                                        inputText: model.artist || model.identity || ""
                                        textFormat: Text.PlainText
                                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
                                        opacity: 0.9
                                        color: "white"
                                    }
                                }

                                PlasmaComponents3.ToolButton {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    
                                    enabled: model.canGoPrevious
                                    icon.name: LayoutMirroring.enabled ? "media-skip-forward" : "media-skip-backward"
                                    icon.width: Kirigami.Units.iconSizes.small
                                    icon.height: Kirigami.Units.iconSizes.small
                                    onClicked: {
                                        mpris2Source.setIndex(model.index);
                                        mpris2Source.goPrevious();
                                    }
                                    visible: model.canGoPrevious || model.canGoNext
                                    Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Previous track")
                                }

                                PlasmaComponents3.ToolButton {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    
                                    icon.name: (model.playbackStatus === Mpris.PlaybackStatus.Playing) ? "media-playback-pause" : "media-playback-start"
                                    icon.width: Kirigami.Units.iconSizes.small
                                    icon.height: Kirigami.Units.iconSizes.small
                                    onClicked: {
                                        mpris2Source.setIndex(model.index);
                                        mpris2Source.playPause();
                                    }
                                    Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Play or Pause media")
                                }

                                PlasmaComponents3.ToolButton {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    
                                    enabled: model.canGoNext
                                    icon.name: LayoutMirroring.enabled ? "media-skip-backward" : "media-skip-forward"
                                    icon.width: Kirigami.Units.iconSizes.small
                                    icon.height: Kirigami.Units.iconSizes.small
                                    onClicked: {
                                        mpris2Source.setIndex(model.index);
                                        mpris2Source.goNext();
                                    }
                                    visible: model.canGoPrevious || model.canGoNext
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
