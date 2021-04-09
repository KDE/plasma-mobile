/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <Aix.m@outlook.com>
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.2
import QtQuick.Layouts 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.private.volume 0.1

QtObject {
    property bool isVisible: paSinkModel.preferredSink && paSinkModel.preferredSink.muted
    property string icon: paSinkModel.preferredSink && !isDummyOutput(paSinkModel.preferredSink)
                          ? iconName(paSinkModel.preferredSink.volume, paSinkModel.preferredSink.muted)
                          : iconName(0, true)
    
    property bool volumeFeedback: true
    property int maxVolumeValue: Math.round(100 * PulseAudio.NormalVolume / 100.0)
    property int volumeStep: Math.round(5 * PulseAudio.NormalVolume / 100.0)
    readonly property string dummyOutputName: "auto_null"

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

    function isDummyOutput(output) {
        return output && output.name === dummyOutputName;
    }

    function boundVolume(volume) {
        return Math.max(PulseAudio.MinimalVolume, Math.min(volume, maxVolumeValue));
    }

    function volumePercent(volume, max){
        if(!max) {
            max = PulseAudio.NormalVolume;
        }
        return Math.round(volume / max * 100.0);
    }

    function playFeedback(sinkIndex) {
        if(!volumeFeedback){
            return;
        }
        if(sinkIndex == undefined) {
            sinkIndex = paSinkModel.preferredSink.index;
        }
        feedback.play(sinkIndex)
    }

    function increaseVolume() {
        if (!paSinkModel.preferredSink || isDummyOutput(paSinkModel.preferredSink)) {
            return;
        }

        var volume = boundVolume(paSinkModel.preferredSink.volume + volumeStep);
        var percent = volumePercent(volume, maxVolumeValue);
        paSinkModel.preferredSink.muted = percent == 0;
        paSinkModel.preferredSink.volume = volume;
        osd.show(percent);
        playFeedback();

    }

    function decreaseVolume() {
        if (!paSinkModel.preferredSink || isDummyOutput(paSinkModel.preferredSink)) {
            return;
        }

        var volume = boundVolume(paSinkModel.preferredSink.volume - volumeStep);
        var percent = volumePercent(volume, maxVolumeValue);
        paSinkModel.preferredSink.muted = percent == 0;
        paSinkModel.preferredSink.volume = volume;
        osd.show(percent);
        playFeedback();
    }



    function muteVolume() {
        if (!paSinkModel.preferredSink || isDummyOutput(paSinkModel.preferredSink)) {
            return;
        }

        var toMute = !paSinkModel.preferredSink.muted;
        paSinkModel.preferredSink.muted = toMute;
        osd.show(toMute ? 0 : volumePercent(paSinkModel.preferredSink.volume, maxVolumeValue));
        if (!toMute) {
            playFeedback();
        }
    }

    property SinkModel paSinkModel: SinkModel {}

    property VolumeOSD osd: VolumeOSD {}

    property VolumeFeedback feedback: VolumeFeedback {}

    property GlobalActionCollection actionCollection: GlobalActionCollection {
        // KGlobalAccel cannot transition from kmix to something else, so if
        // the user had a custom shortcut set for kmix those would get lost.
        // To avoid this we hijack kmix name and actions. Entirely mental but
        // best we can do to not cause annoyance for the user.
        // The display name actually is updated to whatever registered last
        // though, so as far as user visible strings go we should be fine.
        // As of 2015-07-21:
        //   componentName: kmix
        //   actions: increase_volume, decrease_volume, mute
        name: "kmix"
        displayName: i18n("Audio")

        GlobalAction {
            objectName: "increase_volume"
            text: i18n("Increase Volume")
            shortcut: Qt.Key_VolumeUp
            onTriggered: increaseVolume()
        }

        GlobalAction {
            objectName: "decrease_volume"
            text: i18n("Decrease Volume")
            shortcut: Qt.Key_VolumeDown
            onTriggered: decreaseVolume()
        }

        GlobalAction {
            objectName: "mute"
            text: i18n("Mute")
            shortcut: Qt.Key_VolumeMute
            onTriggered: muteVolume()
        }
    }
}
