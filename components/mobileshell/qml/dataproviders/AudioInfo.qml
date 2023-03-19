// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.plasma.private.volume

QtObject {
    property SinkModel paSinkModel: SinkModel {}

    // whether the audio icon should be visible in the status bar
    readonly property bool isVisible: paSinkModel.preferredSink

    // the icon that should be displayed in the status bar
    readonly property string icon: paSinkModel.preferredSink && !isDummyOutput(paSinkModel.preferredSink)
                                    ? iconName(paSinkModel.preferredSink.volume, paSinkModel.preferredSink.muted)
                                    : iconName(0, true)

    // the name of the audio device when it isn't valid
    readonly property string dummyOutputName: "auto_null"

    // the maximum volume amount
    readonly property int maxVolumeValue: Math.round(100 * PulseAudio.NormalVolume / 100.0)

    // step that increments when adjusting the volume
    readonly property int volumeStep: Math.round(5 * PulseAudio.NormalVolume / 100.0)

    function isDummyOutput(output) {
        return output && output.name === dummyOutputName;
    }

    function boundVolume(volume) {
        return Math.max(PulseAudio.MinimalVolume, Math.min(volume, maxVolumeValue));
    }

    function volumePercent(volume, max){
        if (!max) {
            max = PulseAudio.NormalVolume;
        }
        return Math.round(volume / max * 100.0);
    }

    function increaseVolume() {
        if (!paSinkModel.preferredSink || isDummyOutput(paSinkModel.preferredSink)) {
            return;
        }

        var volume = boundVolume(paSinkModel.preferredSink.volume + volumeStep);
        var percent = volumePercent(volume, maxVolumeValue);
        paSinkModel.preferredSink.muted = percent == 0;
        paSinkModel.preferredSink.volume = volume;
    }

    function decreaseVolume() {
        if (!paSinkModel.preferredSink || isDummyOutput(paSinkModel.preferredSink)) {
            return;
        }

        var volume = boundVolume(paSinkModel.preferredSink.volume - volumeStep);
        var percent = volumePercent(volume, maxVolumeValue);
        paSinkModel.preferredSink.muted = percent == 0;
        paSinkModel.preferredSink.volume = volume;
    }

    function muteVolume() {
        if (!paSinkModel.preferredSink || isDummyOutput(paSinkModel.preferredSink)) {
            return;
        }

        paSinkModel.preferredSink.muted = !paSinkModel.preferredSink.muted;
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
