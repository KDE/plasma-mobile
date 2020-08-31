/*
Copyright (C) 2019 Nicolas Fella <nicolas.fella@gmx.de>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.8
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.12
import org.kde.plasma.core 2.0

ColumnLayout {
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    
    property int alignment
    Layout.alignment: alignment
    spacing: units.gridUnit
    
    Label {
        text: Qt.formatTime(timeSource.data["Local"]["DateTime"], "h:mm ap")
        color: ColorScope.textColor
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? ColorScope.backgroundColor : "transparent" // no outline, doesn't matter
        
        Layout.alignment: alignment
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
        
        Layout.alignment: alignment
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
        interval: 1000
    }
}
