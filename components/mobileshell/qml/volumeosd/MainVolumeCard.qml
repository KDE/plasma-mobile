// SPDX-FileCopyrightText: 2021-2023 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Window

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.core as PlasmaCore

PopupCard {
    id: osd

    property bool showFullApplet

    contentItem: RowLayout {
        id: containerLayout
        spacing: Kirigami.Units.smallSpacing

        anchors.leftMargin: Kirigami.Units.smallSpacing * 2
        anchors.rightMargin: Kirigami.Units.smallSpacing

        PlasmaComponents.ToolButton {
            icon.name: !MobileShell.AudioInfo.paSinkModel.preferredSink || MobileShell.AudioInfo.paSinkModel.preferredSink.muted ? "audio-volume-muted" : "audio-volume-high"
            text: !MobileShell.AudioInfo.paSinkModel.preferredSink || MobileShell.AudioInfo.paSinkModel.preferredSink.muted ? i18n("Unmute") : i18n("Mute")
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
                MobileShellState.ShellDBusClient.openAppLaunchAnimation("audio-volume-high", i18n("Audio Settings"), coords.x, coords.y, Kirigami.Units.iconSizes.medium);
                MobileShell.ShellUtil.executeCommand("plasma-open-settings kcm_pulseaudio");
            }
        }

        PlasmaComponents.ToolButton {
            icon.name: root.showFullApplet ? "arrow-up" : "arrow-down"
            text: i18n("Toggle showing audio streams")
            display: Controls.AbstractButton.IconOnly
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            onClicked: {
                root.showFullApplet = !root.showFullApplet
                // don't autohide applet when full applet is shown
                if (root.showFullApplet) {
                    hideTimer.stop();
                } else {
                    hideTimer.restart();
                }
            }
        }
    }
}