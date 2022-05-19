/*
 *   SPDX-FileCopyrightText: 2020 Marco Martin <notmart@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.pipewire 0.1 as PipeWire

PipeWire.PipeWireSourceItem {
    id: root
    visible: nodeId > 0
    nodeId: waylandItem.nodeId
    
    readonly property alias uuid: waylandItem.uuid

    function refresh() {
        if (model.WinIdList) {
            waylandItem.uuid = model.WinIdList[0];
        }
    }

    PipeWire.ScreencastingRequest {
        id: waylandItem
        uuid: ""
    }
}


