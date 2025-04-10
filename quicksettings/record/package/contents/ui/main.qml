// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Window 2.15

import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.pipewire.record 0.1 as PWRec
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.quicksetting.record 1.0
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    id: root
    text: switch (record.state) {
        case PWRec.PipeWireRecord.Idle:
            return i18n("Record Screen")
        case PWRec.PipeWireRecord.Recording:
            return i18n("Recording…")
        case PWRec.PipeWireRecord.Rendering:
            i18n("Writing…")
    }
    status: switch(record.state) {
        case PWRec.PipeWireRecord.Idle:
            return i18n("Tap to start recording")
        case PWRec.PipeWireRecord.Recording:
            return i18n("Screen is being captured…")
        case PWRec.PipeWireRecord.Rendering:
            i18n("Please wait…")
    }
    icon: "camera-video-symbolic"
    enabled: false
    available: record.encoder != PWRec.PipeWireRecord.NoEncoder

    function toggle() {
        if (!record.active) {
            // See this https://invent.kde.org/plasma/kpipewire/-/blob/eb21912e7e0ce5a70c6f906c6e5a20f56cc6783e/src/pipewirerecord.cpp#L82
            switch (record.encoder) {
                case PWRec.PipeWireRecord.H264Main:
                case PWRec.PipeWireRecord.H264Baseline:
                    record.output = RecordUtil.videoLocation("screen-recording.mp4");
                    break;
                case PWRec.PipeWireRecord.VP8:
                case PWRec.PipeWireRecord.VP9:
                    record.output = RecordUtil.videoLocation("screen-recording.webm");
                    break;
            }
        } else {
            RecordUtil.showNotification(i18n("New Screen Recording"), i18n("New Screen Recording saved in %1", record.output), record.output);
        }

        enabled = !enabled
        MobileShellState.ShellDBusClient.closeActionDrawer();
    }

    PWRec.PipeWireRecord {
        id: record
        nodeId: waylandItem.nodeId
        active: root.enabled
    }
    TaskManager.ScreencastingRequest {
        id: waylandItem
        outputName: root.enabled ? Screen.name : ""
    }
}
