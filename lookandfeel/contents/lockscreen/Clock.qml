/*
 * SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
 * SPDX-FileCopyrightText: 2020-2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Item {
    id: root
    implicitHeight: clockColumn.implicitHeight
    implicitWidth: clockColumn.implicitWidth
    
    property int layoutAlignment
    
    P5Support.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60000
        intervalAlignment: P5Support.Types.AlignToMinute
    }
    
    ColumnLayout {
        id: clockColumn
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

            layer.enabled: true
            layer.effect: MobileShell.TextDropShadow {
                blurMax: 16
            }
        }
        
        PC3.Label {
            text: Qt.formatDate(timeSource.data["Local"]["DateTime"], "ddd, MMM d")
            color: "white"
            
            Layout.alignment: root.layoutAlignment
            font.weight: Font.Bold
            font.pointSize: 10

            layer.enabled: true
            layer.effect: MobileShell.TextDropShadow {
                blurMax: 16
            }
        }
    }
}
