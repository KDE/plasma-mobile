/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.workspace.components 2.0 as PW

import "indicators" as Indicators

// a simple version of the task panel
// in the future, it should share components with the existing task panel
PlasmaCore.ColorScope {
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    
    layer.enabled: true
    layer.effect: DropShadow {
        visible: true
        cached: true
        horizontalOffset: 0
        verticalOffset: 1
        radius: 4.0
        samples: 17
        color: Qt.rgba(0,0,0,0.8)
    }
    
    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
    }
    
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 1.0
                color: "transparent"
            }
            GradientStop {
                position: 0.0
                color: Qt.rgba(0, 0, 0, 0.1)
            }
        }
    }
    
    Loader {
        id: strengthLoader
        height: parent.height
        width: item ? item.width : 0
        active: signalStrengthProviderLoader.item
        sourceComponent: Indicators.SignalStrength {
            provider: signalStrengthProviderLoader.item
        }
    }

    Loader {
        id: signalStrengthProviderLoader
        source: Qt.resolvedUrl("indicators/providers/SignalStrengthProvider.qml")
    }

    PlasmaComponents.Label {
        id: clock
        anchors.fill: parent
        text: Qt.formatTime(timeSource.data.Local.DateTime, root.is24HourTime ? "h:mm" : "h:mm ap")
        color: PlasmaCore.ColorScope.textColor
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        font.pixelSize: height / 2
    }

    RowLayout {
        id: appletIconsRow
        anchors {
            bottom: parent.bottom
            right: simpleIndicatorsLayout.left
        }
        height: parent.height
    }

    RowLayout {
        id: simpleIndicatorsLayout
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            rightMargin: PlasmaCore.Units.smallSpacing
        }
        Indicators.Bluetooth {}
        Indicators.Wifi {}
        Indicators.Volume {}
        Indicators.Battery {}
    }
}
