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
    height: cards.implicitHeight + 6 + cards.openOffset

    onWidthChanged: if (visible) window.updateTouchRegion()

    visible: false

    LayerShell.Window.scope: "overlay"
    LayerShell.Window.anchors: LayerShell.Window.AnchorTop
    LayerShell.Window.layer: LayerShell.Window.LayerOverlay
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityNone

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    color: "transparent"

    function showOverlay() {
        if (cards.state == "closed") {
            hideTimer.stop();
            window.open();
        } else if (!volumeSlider.pressed) {
            hideTimer.restart();
        }
    }

    function open() {
        // set window input transparency to allow touches to pass through while the opening animation is playing
        ShellUtil.setInputTransparent(window, true);

        window.visible = true;
        cards.state = "open";
    }

    function close() {
        cards.state = "closed";
        // set window input transparency to allow touches to pass through while the closing animation is playing
        ShellUtil.setInputTransparent(window, true);
    }

    function updateTouchRegion() {
        ShellUtil.setInputRegion(window, Qt.rect(0, cards.openOffset, window.width, cards.implicitHeight + 6));
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

        // Ensure children get visibility state of window so that they don't update while closed
        visible: window.visible

        width: parent.width
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        readonly property real closedOffset: -(cards.implicitHeight + Kirigami.Units.smallSpacing)
        readonly property real openOffset: Kirigami.Units.gridUnit + Kirigami.Units.smallSpacing * 3
        property real offset: closedOffset

        state: "closed"

        states: [
            State {
                name: "open"
                PropertyChanges {
                    target: cards; offset: openOffset
                }
            },
            State {
                name: "closed"
                PropertyChanges {
                    target: cards; offset: closedOffset
                }
            }
        ]

        transitions: Transition {
            SequentialAnimation {
                ParallelAnimation {
                    PropertyAnimation {
                        properties: "offset"; easing.type: cards.state == "open" ? Easing.OutQuint : Easing.InQuint; duration: Kirigami.Units.veryLongDuration * 1.25
                    }
                }
                ScriptAction {
                    script: {
                        if (cards.state == "open") {
                            hideTimer.restart();
                            // set window input transparency to accept touches
                            ShellUtil.setInputTransparent(window, false);
                            window.updateTouchRegion();
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
                    y: cards.offset + 1
                }
            ]

            contentItem: RowLayout {
                id: containerLayout
                spacing: Kirigami.Units.smallSpacing

                anchors.leftMargin: Kirigami.Units.smallSpacing * 2
                anchors.rightMargin: Kirigami.Units.smallSpacing

                property int volumePercent: PreferredDevice.sink.volume / PulseAudio.NormalVolume * 100.0

                PlasmaComponents.ToolButton {
                    icon.name: !PreferredDevice.sink || (PreferredDevice.sink.muted ? "audio-volume-muted" : MobileShell.AudioInfo.icon)
                    text: !PreferredDevice.sink || (PreferredDevice.sink.muted ? i18n("Unmute") : i18n("Mute"))
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

                VolumeSlider {
                    id: volumeSlider
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: Kirigami.Units.smallSpacing * 2

                    from: PulseAudio.MinimalVolume
                    to: PulseAudio.NormalVolume
                    stepSize: to / (to / PulseAudio.NormalVolume * 100.0)

                    volumeObject: PreferredDevice.sink
                    muted: PreferredDevice.sink.muted
                    value: PreferredDevice.sink.volume

                    onMoved: {
                        PreferredDevice.sink.volume = value;
                        PreferredDevice.sink.muted = value === 0;
                    }
                    onPressedChanged: {
                        if (pressed) {
                            hideTimer.stop();
                        } else {
                            // Make sure to sync the volume once the button was
                            // released.
                            // Otherwise it might be that the slider is at v10
                            // whereas PA rejected the volume change and is
                            // still at v15 (e.g.).
                            value = Qt.binding(() => PreferredDevice.sink.volume);
                            hideTimer.restart();
                        }
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
