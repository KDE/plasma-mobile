/*
 * SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
 * SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.8
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0

ColumnLayout {
    id: root
    property int layoutAlignment
    
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    readonly property bool is24HourTime: Qt.locale().timeFormat(Locale.ShortFormat).toLowerCase().indexOf("ap") === -1
    
    Layout.alignment: layoutAlignment
    spacing: Units.gridUnit
    
    Label {
        text: Qt.formatTime(timeSource.data["Local"]["DateTime"], root.is24HourTime ? "h:mm" : "h:mm ap")
        color: ColorScope.textColor
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? ColorScope.backgroundColor : "transparent" // no outline, doesn't matter
        
        Layout.alignment: root.layoutAlignment
        font.weight: Font.Light // this font weight may switch to regular on distros that don't have a light variant
        font.pointSize: 36
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 1
            radius: 4
            samples: 6
            color: "#757575"
        }
    }
    
    Label {
        text: Qt.formatDate(timeSource.data["Local"]["DateTime"], "ddd, MMM d")
        color: ColorScope.textColor
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? ColorScope.backgroundColor : "transparent" // no outline, doesn't matter
        
        Layout.alignment: root.layoutAlignment
        font.pointSize: 10
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 1
            radius: 4
            samples: 6
            color: "#757575"
        }
    }
    
    DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60000
        intervalAlignment: Types.AlignToMinute
    }
}
