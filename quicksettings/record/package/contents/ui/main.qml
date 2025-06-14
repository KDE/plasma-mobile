// SPDX-FileCopyrightText: 2022-2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Window

import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.taskmanager as TaskManager
import org.kde.plasma.quicksetting.record
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    id: root

    text: RecordUtil.quickSettingText
    status: RecordUtil.quickSettingStatus
    icon: "camera-video-symbolic"
    enabled: RecordUtil.isRecording
    available: true

    function toggle() {
        if (RecordUtil.isRecording) {
            RecordUtil.stopRecording();
            waylandItem.outputName = '';
        } else {
            // Start recording only when waylandItem's nodeId updates
            waylandItem.startRecordingRequest = true;
            waylandItem.outputName = Screen.name;
        }
    }

    TaskManager.ScreencastingRequest {
        id: waylandItem
        property bool startRecordingRequest: false

        onNodeIdChanged: {
            if (startRecordingRequest) {
                let status = RecordUtil.startRecording(waylandItem.nodeId);
                if (status) {
                    MobileShellState.ShellDBusClient.closeActionDrawer();
                } else {
                    waylandItem.outputName = '';
                }

                startRecordingRequest = false;
            }
        }
    }
}
