// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import org.kde.plasma.core as PlasmaCore

import org.kde.plasma.private.mobileshell as MobileShell

ColumnLayout {
    id: root

    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    readonly property bool is24HourTime: MobileShell.ShellUtil.isSystem24HourFormat
    
    spacing: 0

    Label {
        text: Qt.formatTime(timeSource.data["Local"]["DateTime"], root.is24HourTime ? "h:mm" : "h:mm ap")
        color: "white"
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? ColorScope.backgroundColor : "transparent" // no outline, doesn't matter
        
        Layout.fillWidth: true
        
        horizontalAlignment: Text.AlignLeft
        font.weight: Font.Bold // this font weight may switch to regular on distros that don't have a light variant
        font.pointSize: 28
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 1
            radius: 4
            samples: 6
            color: Qt.rgba(0, 0, 0, 0.5)
        }
    }
    
    Label {
        Layout.topMargin: PlasmaCore.Units.smallSpacing
        Layout.fillWidth: true
        
        horizontalAlignment: Text.AlignLeft
        text: Qt.formatDate(timeSource.data["Local"]["DateTime"], "ddd, MMM d")
        color: "white"
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? ColorScope.backgroundColor : "transparent" // no outline, doesn't matter
        
        font.pointSize: 12
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 1
            radius: 4
            samples: 6
            color: Qt.rgba(0, 0, 0, 0.5)
        }
    }
    
    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }

}
