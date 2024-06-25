/*
 *  SPDX-FileCopyrightText: 2014 Martin Klapetek <mklapetek@kde.org>
 *  SPDX-FileCopyrightText: 2019 Kai Uwe Broulik <kde@broulik.de>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Window

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState

import org.kde.plasma.private.volume

NanoShell.FullScreenOverlay {
    id: window

    // used by context menus opened in the applet to not autoclose the osd
    property bool suppressActiveClose: false

    // whether the applet is showing all devices
    property bool showFullApplet: false

    visible: false

    color: showFullApplet ? Qt.rgba(0, 0, 0, 0.6) : "transparent"
    Behavior on color {
        ColorAnimation {}
    }

    function showOverlay() {
        if (!window.visible) {
            window.showFullApplet = false;
            window.showFullScreen();
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
                    Layout.topMargin: Kirigami.Units.gridUnit
                    Layout.alignment: Qt.AlignHCenter

                    contentItem: RowLayout {
                        id: containerLayout
                        spacing: Kirigami.Units.smallSpacing

                        anchors.leftMargin: Kirigami.Units.smallSpacing * 2
                        anchors.rightMargin: Kirigami.Units.smallSpacing

                        PlasmaComponents.ToolButton {
                            icon.name: !PreferredDevice.sink || PreferredDevice.sink.muted ? "audio-volume-muted" : "audio-volume-high"
                            text: !PreferredDevice.sink || PreferredDevice.sink.muted ? i18n("Unmute") : i18n("Mute")
                            display: Controls.AbstractButton.IconOnly
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                            Layout.rightMargin: Kirigami.Units.smallSpacing
                            onClicked: muteVolume()
                        }

                        PlasmaComponents.ProgressBar {
                            id: volumeSlider
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: Kirigami.Units.smallSpacing * 2
                            value: MobileShell.AudioInfo.volumeValue
                            from: 0
                            to: MobileShell.AudioInfo.maxVolumePercent
                            Behavior on value { NumberAnimation { duration: Kirigami.Units.shortDuration } }
                        }

                        // Get the width of a three-digit number so we can size the label
                        // to the maximum width to avoid the progress bar resizing itself
                        TextMetrics {
                            id: widestLabelSize
                            text: i18n("100%")
                            font: percentageLabel.font
                        }

                        Kirigami.Heading {
                            id: percentageLabel
                            Layout.preferredWidth: widestLabelSize.width
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: Kirigami.Units.smallSpacing
                            level: 3
                            text: i18nc("Percentage value", "%1%", MobileShell.AudioInfo.volumeValue)

                            // Display a subtle visual indication that the volume might be
                            // dangerously high
                            // ------------------------------------------------
                            // Keep this in sync with the copies in plasma-pa:ListItemBase.qml
                            // and plasma-pa:VolumeSlider.qml
                            color: {
                                if (MobileShell.AudioInfo.volumeValue <= 100) {
                                    return Kirigami.Theme.textColor
                                } else if (MobileShell.AudioInfo.volumeValue > 100 && MobileShell.AudioInfo.volumeValue <= 125) {
                                    return Kirigami.Theme.neutralTextColor
                                } else {
                                    return Kirigami.Theme.negativeTextColor
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
                            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                            Layout.rightMargin: Kirigami.Units.smallSpacing

                            Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration } }

                            onClicked: {
                                let coords = mapToItem(flickable, 0, 0);
                                MobileShell.ShellUtil.executeCommand("plasma-open-settings kcm_pulseaudio");
                            }
                        }

                        PlasmaComponents.ToolButton {
                            icon.name: window.showFullApplet ? "arrow-up" : "arrow-down"
                            text: i18n("Toggle showing audio streams")
                            display: Controls.AbstractButton.IconOnly
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
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
                    Layout.topMargin: Kirigami.Units.gridUnit
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: cards.width
                    opacity: window.showFullApplet ? 1 : 0
                    visible: opacity !== 0
                    transform: Translate {
                        y: window.showFullApplet ? 0 : -Kirigami.Units.gridUnit
                        Behavior on y { NumberAnimation {} }
                    }

                    Behavior on opacity { NumberAnimation {} }
                }
            }
        }
    }
}
