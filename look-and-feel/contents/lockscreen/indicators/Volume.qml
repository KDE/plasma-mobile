/*
    Copyright 2019 Aditya Mehra <Aix.m@outlook.com>
    Copyright 2014-2015 Harald Sitter <sitter@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
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
