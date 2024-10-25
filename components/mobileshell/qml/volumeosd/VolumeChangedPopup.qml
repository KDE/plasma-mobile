/*
 *  SPDX-FileCopyrightText: 2024 Micah Stanley <stanleymicah@proton.me>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Window

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState

import org.kde.plasma.private.volume

import org.kde.layershell 1.0 as LayerShell


Window {
    id: window

    width: osd.width + 6
    height: cards.implicitHeight + 6

    visible: false

    readonly property real offsetMargins: Math.max(cards.offset, 0)

    LayerShell.Window.scope: "overlay"
    LayerShell.Window.anchors: LayerShell.Window.AnchorTop
    LayerShell.Window.layer: LayerShell.Window.LayerOverlay
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.margins.top: offsetMargins

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    color: "transparent"

    function showOverlay() {
        if (cards.state == "closed") {
            hideTimer.stop();
            window.open();
        } else if (!volumeSlider.isPressed) {
            hideTimer.restart();
        }
    }

    function open() {
        cards.state = "open";
        // set window input transparency to accept touches
        ShellUtil.setInputTransparent(window, false);
        window.visible = true;
    }

    function close() {
        cards.state = "closed";
        // set window input transparency to allow touches to pass through while the closing animation is playing
        ShellUtil.setInputTransparent(window, true);
    }

    Timer {
        id: hideTimer
        interval: 2000
        running: false
        onTriggered: {
           window.close();
        }
    }

    Component.onCompleted: {
        window.close();
        visible = false;
    }

    ColumnLayout {
        id: cards
        width: parent.width
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        readonly property real closedOffset: -(cards.implicitHeight + Kirigami.Units.smallSpacing)
        readonly property real openOffset: Kirigami.Units.gridUnit + Kirigami.Units.smallSpacing * 3
        property real offset: closedOffset
        property real scale: 0.95

        state: "closed"

        states: [
            State {
                name: "open"
                PropertyChanges {
                    target: cards; offset: openOffset
                }
                PropertyChanges {
                    target: cards; scale: 1.0
                }
            },
            State {
                name: "closed"
                PropertyChanges {
                    target: cards; offset: closedOffset
                }
                PropertyChanges {
                    target: cards; scale: 0.95
                }
            }
        ]

        transitions: Transition {
            SequentialAnimation {
                ParallelAnimation {
                    PropertyAnimation {
                        properties: "offset"; easing.type: Easing.OutExpo; duration: Kirigami.Units.veryLongDuration
                    }
                    PropertyAnimation {
                        properties: "scale"; easing.type: Easing.OutExpo; duration: Kirigami.Units.veryLongDuration
                    }
                }
                ScriptAction {
                    script: {
                        if (cards.state == "open") {
                            hideTimer.restart();
                        } else {
                            hideTimer.stop();
                            window.visible = false;
                        }
                    }
                }
            }
        }

        PopupCard {
            id: osd
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Math.min(Kirigami.Units.gridUnit * 15, Screen.width - Kirigami.Units.gridUnit * 2)

            transform: [
                Translate {
                    y: cards.offset - window.offsetMargins + 1
                },
                Scale {
                    origin.x: Math.round(width / 2)
                    origin.y: Math.round(height / 2)
                    xScale: cards.scale
                    yScale: cards.scale
                }
            ]

            contentItem: RowLayout {
                id: containerLayout
                spacing: Kirigami.Units.smallSpacing

                anchors.leftMargin: Kirigami.Units.smallSpacing * 2
                anchors.rightMargin: Kirigami.Units.smallSpacing

                property int volumePercent: PreferredDevice.sink.volume / PulseAudio.NormalVolume * 100.0

                PlasmaComponents.ToolButton {
                    icon.name: !PreferredDevice.sink || PreferredDevice.sink.muted ? "audio-volume-muted" : MobileShell.AudioInfo.icon
                    text: !PreferredDevice.sink || PreferredDevice.sink.muted ? i18n("Unmute") : i18n("Mute")
                    display: Controls.AbstractButton.IconOnly
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                    onClicked: {
                        hideTimer.restart();
                        PreferredDevice.sink.muted = !PreferredDevice.sink.muted;
                    }
                }

                PlasmaComponents.Slider {
                    id: volumeSlider
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: Kirigami.Units.smallSpacing * 2

                    property real volume: PreferredDevice.sink.volume
                    property bool muted: PreferredDevice.sink.muted
                    property bool ignoreValueChange: false
                    property bool isPressed: false

                    from: PulseAudio.MinimalVolume
                    to: PulseAudio.NormalVolume
                    stepSize: to / (to / PulseAudio.NormalVolume * 100.0)
                    opacity: muted ? 0.5 : 1.0

                    Component.onCompleted: {
                        ignoreValueChange = false;
                    }

                    onVolumeChanged: {
                        if (!window.visible) {
                            return;
                        }
                        var oldIgnoreValueChange = ignoreValueChange;
                        ignoreValueChange = true;
                        value = muted ? 0 : PreferredDevice.sink.volume;
                        ignoreValueChange = oldIgnoreValueChange;
                        if (volumeSlider.isPressed) {
                            return;
                        }
                        window.open();
                        hideTimer.restart();
                    }

                    onMutedChanged: {
                        var oldIgnoreValueChange = ignoreValueChange;
                        ignoreValueChange = true;
                        value = muted ? 0 : PreferredDevice.sink.volume;
                        ignoreValueChange = oldIgnoreValueChange;
                        if (!window.visible || volumeSlider.isPressed) {
                            return;
                        }
                        window.open();
                        hideTimer.restart();
                    }

                    onValueChanged: {
                        if (!ignoreValueChange) {
                            PreferredDevice.sink.muted = false;
                            PreferredDevice.sink.volume = value;
                            if (!volumeSlider.isPressed) {
                                updateTimer.restart();
                            }
                        }
                    }

                    onPressedChanged: {
                        volumeSlider.isPressed = pressed;
                        if (pressed) {
                            window.open();
                            hideTimer.stop();
                        } else {
                            // Make sure to sync the volume once the button was
                            // released.
                            // Otherwise it might be that the slider is at v10
                            // whereas PA rejected the volume change and is
                            // still at v15 (e.g.).
                            hideTimer.restart();
                            updateTimer.restart();
                        }
                    }

                    Timer {
                        id: updateTimer
                        interval: 200
                        onTriggered: volumeSlider.value = PreferredDevice.sink.volume
                    }
                }

                PlasmaComponents.ToolButton {
                    icon.name: window.showFullApplet ? "arrow-up" : "arrow-down"
                    text: i18n("configure audio streams")
                    display: Controls.AbstractButton.IconOnly
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                    onClicked: MobileShellState.ShellDBusClient.showVolumeOSD()
                }
            }
        }
    }
}
