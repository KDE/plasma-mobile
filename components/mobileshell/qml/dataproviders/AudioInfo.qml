// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma Singleton

import QtQuick

import org.kde.plasma.private.volume
import org.kde.plasma.private.mobileshell as MobileShell

QtObject {
    id: root

    property var config: GlobalConfig {}

    property SinkModel paSinkModel: SinkModel {}

    // whether the audio icon should be visible in the status bar
    readonly property bool isVisible: PreferredDevice.sink

    // the icon that should be displayed in the status bar
    readonly property string icon: PreferredDevice.sink && !isDummyOutput(PreferredDevice.sink)
                                    ? iconName(PreferredDevice.sink.volume, PreferredDevice.sink.muted)
                                    : iconName(0, true)

    // the name of the audio device when it isn't valid
    readonly property string dummyOutputName: "auto_null"

    // the maximum volume amount (percentage)
    readonly property int maxVolumePercent: config.raiseMaximumVolume ? 150 : 100

    // the maximum volume amount
    readonly property int maxVolumeValue: maxVolumePercent * PulseAudio.NormalVolume / 100

    // The current audio volume (updated by connecting to sinks)
    readonly property int volumeValue: PreferredDevice.sink ? (PreferredDevice.sink.volume / PulseAudio.NormalVolume) * 100 : 0

    function isDummyOutput(output) {
        return output && output.name === dummyOutputName;
    }

    function iconName(volume, muted, prefix) {
        if (!prefix) {
            prefix = "audio-volume";
        }
        var icon = null;
        var percent = volume / maxVolumeValue;
        if (percent <= 0.0 || muted) {
            icon = prefix + "-muted";
        } else if (percent <= 0.25) {
            icon = prefix + "-low";
        } else if (percent <= 0.75) {
            icon = prefix + "-medium";
        } else {
            icon = prefix + "-high";
        }
        return icon;
    }
}
