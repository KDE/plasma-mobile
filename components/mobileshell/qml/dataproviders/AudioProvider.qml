/*
    SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <Aix.m@outlook.com>
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.2
import QtQuick.Layouts 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.volume 0.1

import "../osd/volume"

pragma Singleton

QtObject {
    /**
     * Whether or not to bind the volume global key shortcuts.
     * We should never bind the shortcut multiple times in the shell, or else they may not work at all.
     * 
     * We only set this to true when loaded for the panel containment (and NOT in the lockscreen).
     */
    property bool bindShortcuts: false
    
    readonly property bool isVisible: paSinkModel.preferredSink && paSinkModel.preferredSink.muted
    
    readonly property string icon: paSinkModel.preferredSink && !isDummyOutput(paSinkModel.preferredSink)
                                    ? iconName(paSinkModel.preferredSink.volume, paSinkModel.preferredSink.muted)
                                    : iconName(0, true)
    
    readonly property int maxVolumeValue: Math.round(100 * PulseAudio.NormalVolume / 100.0)
    readonly property int volumeStep: Math.round(5 * PulseAudio.NormalVolume / 100.0)
    
    property int volumeValue
    
    readonly property string dummyOutputName: "auto_null"

    function showVolumeOverlay() {
        osd.showOverlay();
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
        if (sinkIndex == undefined) {
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
        volumeValue = percent;
        osd.showOverlay();
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
        volumeValue = percent;
        osd.showOverlay();
        playFeedback();
    }

    function muteVolume() {
        if (!paSinkModel.preferredSink || isDummyOutput(paSinkModel.preferredSink)) {
            return;
        }

        var toMute = !paSinkModel.preferredSink.muted;
        paSinkModel.preferredSink.muted = toMute;
        
        volumeValue = toMute ? 0 : volumePercent(paSinkModel.preferredSink.volume, maxVolumeValue);
        osd.showOverlay();
        
        if (!toMute) {
            playFeedback();
        }
    }
    
    property var updateVolume: Connections {
        target: paSinkModel.preferredSink
        
        function onVolumeChanged() {
            var percent = volumePercent(paSinkModel.preferredSink.volume, maxVolumeValue);
            volumeValue = percent;
        }
    }
    property var updateVolumeOnSinkChange: Connections {
        target: paSinkModel
        
        function onPreferredSinkChanged() {
            if (paSinkModel.preferredSink) {
                var percent = volumePercent(paSinkModel.preferredSink.volume, maxVolumeValue);
                volumeValue = percent;
            }
        }
    }

    property SinkModel paSinkModel: SinkModel {}

    property var osd: VolumeOSD {
        volume: volumeValue
    }

    property VolumeFeedback feedback: VolumeFeedback {}

    // only bind the global shortcuts when told to
    property var actionCollection: Loader {
        active: bindShortcuts
        
        sourceComponent: GlobalActionCollection {
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
}
