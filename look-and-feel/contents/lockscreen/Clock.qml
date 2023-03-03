/*
 * SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
 * SPDX-FileCopyrightText: 2020-2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Item {
    id: root
    implicitHeight: clockColumn.implicitHeight
    implicitWidth: clockColumn.implicitWidth
    
    property int layoutAlignment
    
    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60000
        intervalAlignment: PlasmaCore.Types.AlignToMinute
    }
    
    DropShadow {
        anchors.fill: parent
        source: clockColumn
        cached: true
        verticalOffset: 1
        radius: 4
        samples: 6
        color: Qt.rgba(0, 0, 0, 0.4)
    }
    
    ColumnLayout {
        id: clockColumn
        opacity: 0.8
        spacing: PlasmaCore.Units.gridUnit
        
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        
        PC3.Label {
            text: Qt.formatTime(timeSource.data["Local"]["DateTime"], MobileShell.ShellUtil.isSystem24HourFormat ? "h:mm" : "h:mm ap")
            color: "white"
            
            Layout.alignment: root.layoutAlignment
            font.weight: Font.Bold
            font.pointSize: 36
        }
        
        PC3.Label {
            text: Qt.formatDate(timeSource.data["Local"]["DateTime"], "ddd, MMM d")
            color: "white"
            
            Layout.alignment: root.layoutAlignment
            font.weight: Font.Bold
            font.pointSize: 10
        }
    }
}
