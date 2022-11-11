// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Window 2.15

import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobileshell.state 1.0 as MobileShellState
import org.kde.pipewire.record 0.1 as PWRec
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.quicksetting.record 1.0

MobileShell.QuickSetting {
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
    icon: "media-record"
    enabled: false

    function toggle() {
        if (!record.active) {
            record.output = RecordUtil.videoLocation("screen-recording.mp4");
        } else {
            RecordUtil.showNotification(i18n("New Screen Recording"), i18n("New Screen Recording saved in %1", record.output), record.output);
        }
        
        enabled = !enabled
        MobileShellState.Shell.closeActionDrawer();
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
