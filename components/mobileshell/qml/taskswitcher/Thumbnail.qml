/*
 *   SPDX-FileCopyrightText: 2020 Marco Martin <notmart@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.taskmanager 0.1 as TaskManager

TaskManager.PipeWireSourceItem {
    visible: false
    nodeId: waylandItem.nodeId
    
    // Visible only if casting has begun
    onNodeIdChanged: {
        visible = true;
    }
    
    readonly property string uuid: waylandItem.uuid

    function refresh() {
        if (model.WinIdList) {
            waylandItem.uuid = model.WinIdList[0];
        }
    }

    TaskManager.ScreencastingRequest {
        id: waylandItem
        uuid: ""
    }
}


