/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <Aix.m@outlook.com>
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.2
import QtQuick.Layouts 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.private.volume 0.1

PlasmaCore.IconItem {

    id: paIcon
    Layout.fillHeight: true
    Layout.preferredWidth: height
    property bool volumeFeedback: true
    property int maxVolumeValue: Math.round(100 * PulseAudio.NormalVolume / 100.0)
    property int volumeStep: Math.round(5 * PulseAudio.NormalVolume / 100.0)
    readonly property string dummyOutputName: "auto_null"
    source: paSinkModel.preferredSink && !isDummyOutput(paSinkModel.preferredSink)
        ? iconName(paSinkModel.preferredSink.volume, paSinkModel.preferredSink.muted)
        : iconName(0, true)

    colorGroup: PlasmaCore.ColorScope.colorGroup

    visible: paSinkModel.preferredSink && paSinkModel.preferredSink.muted

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

    SinkModel {
        id: paSinkModel
    }

    VolumeOSD {
        id: osd
    }

    VolumeFeedback {
        id: feedback
    }
}
