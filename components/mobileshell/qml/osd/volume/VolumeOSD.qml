/*
 *  SPDX-FileCopyrightText: 2014 Martin Klapetek <mklapetek@kde.org>
 *  SPDX-FileCopyrightText: 2019 Kai Uwe Broulik <kde@broulik.de>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtra
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtra
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState

import org.kde.kirigami 2.12 as Kirigami

// this is loaded and managed by indicators/providers/VolumeProvider.qml
NanoShell.FullScreenOverlay {
    id: window
    visible: false
    color: showFullApplet ? Qt.rgba(0, 0, 0, 0.6) : "transparent"
    
    property bool suppressActiveClose: false // used by context menus opened in the applet to not autoclose the osd
    
    Behavior on color {
        ColorAnimation {}
    }
    
    property int volume: 0
    property bool showFullApplet: false
    
    function showOverlay() {
        if (!window.visible) {
            window.showFullApplet = false;
            window.showMaximized();
            hideTimer.restart();
        } else if (!window.showFullApplet) { // don't autohide applet when the full applet is showing
            hideTimer.restart();
        }
    }

    onActiveChanged: {
        if (!active && !suppressActiveClose) {
            hideTimer.stop();
            hideTimer.triggered();
        }
    }
    
    Timer {
        id: hideTimer
        interval: 3000
        running: false
        onTriggered: {
            window.close();
            window.showFullApplet = false;
        }
    }
    
    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: cards.implicitHeight
        boundsBehavior: window.showFullApplet ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
        
        pressDelay: 50
        
        MouseArea {
            // capture taps behind cards to close
            anchors.left: parent.left
            anchors.right: parent.right
            width: parent.width
            height: Math.max(cards.implicitHeight, window.height)
            onReleased: {
                hideTimer.stop();
                hideTimer.triggered();
            }
            
            ColumnLayout {
                id: cards
                width: parent.width
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0
                
                // osd card
                PopupCard {
                    id: osd
                    Layout.topMargin: PlasmaCore.Units.largeSpacing
                    Layout.alignment: Qt.AlignHCenter
                    
                    contentItem: RowLayout {
                        id: containerLayout
                        spacing: PlasmaCore.Units.smallSpacing

                        anchors.leftMargin: PlasmaCore.Units.smallSpacing * 2
                        anchors.rightMargin: PlasmaCore.Units.smallSpacing
                        
                        PlasmaComponents.ToolButton {
                            icon.name: !paSinkModel.preferredSink || paSinkModel.preferredSink.muted ? "audio-volume-muted" : "audio-volume-high"
                            text: !paSinkModel.preferredSink || paSinkModel.preferredSink.muted ? i18n("Unmute") : i18n("Mute")
                            display: Controls.AbstractButton.IconOnly
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: PlasmaCore.Units.iconSizes.medium
                            Layout.preferredHeight: PlasmaCore.Units.iconSizes.medium
                            Layout.rightMargin: PlasmaCore.Units.smallSpacing
                            onClicked: muteVolume()
                        }
                        
                        PlasmaComponents.ProgressBar {
                            id: volumeSlider
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: PlasmaCore.Units.smallSpacing * 2
                            value: window.volume
                            from: 0
                            to: 100
                            Behavior on value { NumberAnimation { duration: PlasmaCore.Units.shortDuration } }
                        }
                        
                        // Get the width of a three-digit number so we can size the label
                        // to the maximum width to avoid the progress bar resizing itself
                        TextMetrics {
                            id: widestLabelSize
                            text: i18n("100%")
                            font: percentageLabel.font
                        }

                        PlasmaExtra.Heading {
                            id: percentageLabel
                            Layout.preferredWidth: widestLabelSize.width
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: PlasmaCore.Units.smallSpacing
                            level: 3
                            text: i18nc("Percentage value", "%1%", window.volume)
                            
                            // Display a subtle visual indication that the volume might be
                            // dangerously high
                            // ------------------------------------------------
                            // Keep this in sync with the copies in plasma-pa:ListItemBase.qml
                            // and plasma-pa:VolumeSlider.qml
                            color: {
                                if (volumeSlider.value <= 100) {
                                    return PlasmaCore.Theme.textColor
                                } else if (volumeSlider.value > 100 && volumeSlider.value <= 125) {
                                    return PlasmaCore.Theme.neutralTextColor
                                } else {
                                    return PlasmaCore.Theme.negativeTextColor
                                }
                            }
                        }
                        
                        PlasmaComponents.ToolButton {
                            icon.name: "configure"
                            text: i18n("Open audio settings")
                            visible: opacity !== 0
                            opacity: showFullApplet ? 1 : 0
                            display: Controls.AbstractButton.IconOnly
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: PlasmaCore.Units.iconSizes.medium
                            Layout.preferredHeight: PlasmaCore.Units.iconSizes.medium
                            Layout.rightMargin: PlasmaCore.Units.smallSpacing
                            
                            Behavior on opacity { NumberAnimation { duration: PlasmaCore.Units.shortDuration } }
                            
                            onClicked: {
                                let coords = mapToItem(flickable, 0, 0);
                                MobileShellState.Shell.openAppLaunchAnimation("audio-volume-high", i18n("Audio Settings"), coords.x, coords.y, PlasmaCore.Units.iconSizes.medium);
                                MobileShell.ShellUtil.executeCommand("plasma-open-settings kcm_pulseaudio");
                            }
                        }
                        
                        PlasmaComponents.ToolButton {
                            icon.name: window.showFullApplet ? "arrow-up" : "arrow-down"
                            text: i18n("Toggle showing audio streams")
                            display: Controls.AbstractButton.IconOnly
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: PlasmaCore.Units.iconSizes.medium
                            Layout.preferredHeight: PlasmaCore.Units.iconSizes.medium
                            onClicked: {
                                window.showFullApplet = !window.showFullApplet
                                // don't autohide applet when full applet is shown
                                if (window.showFullApplet) {
                                    hideTimer.stop();
                                } else {
                                    hideTimer.restart();
                                }
                            }
                        }
                    }
                }

                // other applet cards
                AudioApplet {
                    id: applet
                    Layout.topMargin: PlasmaCore.Units.largeSpacing
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: cards.width
                    
                    opacity: window.showFullApplet ? 1 : 0
                    visible: opacity !== 0
                    transform: Translate { 
                        y: window.showFullApplet ? 0 : -PlasmaCore.Units.gridUnit
                        Behavior on y { NumberAnimation {} }
                    }
                    
                    Behavior on opacity { NumberAnimation {} }
                }
            }
        }
    }
}
