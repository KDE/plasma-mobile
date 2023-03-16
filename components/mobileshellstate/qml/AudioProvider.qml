/*
    SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
    SPDX-FileCopyrightText: 2019 Aditya Mehra <Aix.m@outlook.com>
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.volume 0.1
import org.kde.plasma.private.mobileshell as MobileShell

pragma Singleton

QtObject {
    id: root

    /**
     * Whether or not to bind the volume global key shortcuts.
     * We should never bind the shortcut multiple times in the shell, or else they may not work at all.
     * 
     * We only set this to true when loaded for the panel containment (and NOT in the lockscreen).
     */
    property bool bindShortcuts: false
    
    property int volumeValue

    function showVolumeOverlay() {
        osd.showOverlay();
    }

    property var audioInfo: MobileShell.AudioInfo {}

    property var updateVolume: Connections {
        target: audioInfo.paSinkModel.preferredSink
        
        function onVolumeChanged() {
            var percent = audioInfo.volumePercent(audioInfo.paSinkModel.preferredSink.volume, audioInfo.maxVolumeValue);
            volumeValue = percent;

            osd.showOverlay();
        }

        function onMutedChanged() {
            volumeValue = audioInfo.paSinkModel.preferredSink.muted ? 0 : audioInfo.volumePercent(audioInfo.paSinkModel.preferredSink.volume, audioInfo.maxVolumeValue);
            osd.showOverlay();
        }
    }

    property var updateVolumeOnSinkChange: Connections {
        target: audioInfo.paSinkModel
        
        function onPreferredSinkChanged() {
            if (audioInfo.paSinkModel.preferredSink) {
                var percent = audioInfo.volumePercent(audioInfo.paSinkModel.preferredSink.volume, audioInfo.maxVolumeValue);
                volumeValue = percent;
            }
        }
    }

    property var osd: MobileShell.VolumeOSD {
        volume: volumeValue
    }

    // only bind the global shortcuts when told to
    property var actionCollection: Loader {
        active: bindShortcuts
        
        sourceComponent: GlobalActionCollection {
            name: "kmix"
            displayName: i18n("Audio")

            GlobalAction {
                objectName: "increase_volume"
                text: i18n("Increase Volume")
                shortcut: Qt.Key_VolumeUp
                onTriggered: root.audioInfo.increaseVolume()
            }

            GlobalAction {
                objectName: "decrease_volume"
                text: i18n("Decrease Volume")
                shortcut: Qt.Key_VolumeDown
                onTriggered: root.audioInfo.decreaseVolume()
            }

            GlobalAction {
                objectName: "mute"
                text: i18n("Mute")
                shortcut: Qt.Key_VolumeMute
                onTriggered: root.audioInfo.muteVolume()
            }
        }
    }
}
