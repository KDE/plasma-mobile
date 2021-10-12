/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.workspace.components 2.0 as PW

import "indicators" as Indicators
import "indicators/providers" as Providers

// a simple version of the task panel
// in the future, it should share components with the existing task panel
PlasmaCore.ColorScope {
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    
    property real textPixelSize: PlasmaCore.Units.gridUnit * 0.6
    
    layer.enabled: true
    layer.effect: DropShadow {
        visible: true
        cached: true
        horizontalOffset: 0
        verticalOffset: 1
        radius: 6.0
        samples: 17
        color: Qt.rgba(0,0,0,0.6)
    }
    
    Providers.SignalStrengthProvider {
        id: signalStrengthProviderLoader
    }
    
    Controls.Control {
        topPadding: PlasmaCore.Units.smallSpacing
        bottomPadding: PlasmaCore.Units.smallSpacing
        rightPadding: PlasmaCore.Units.smallSpacing * 3
        leftPadding: PlasmaCore.Units.smallSpacing * 3
        
        anchors.fill: parent
        
        contentItem: RowLayout {
            id: row
            spacing: 0
            
            Indicators.SignalStrength {
                provider: signalStrengthProviderLoader
                labelPixelSize: textPixelSize
                Layout.fillHeight: true
            }
            
            // spacing in the middle
            Item {
                Layout.fillWidth: true
            }
            
            RowLayout {
                id: indicators
                spacing: PlasmaCore.Units.smallSpacing * 1.5
                Layout.fillHeight: true

                Indicators.Bluetooth {
                    Layout.fillHeight: true
                }
                Indicators.Wifi {
                    Layout.fillHeight: true
                }
                Indicators.Volume {
                    Layout.fillHeight: true
                }
                Indicators.Battery {
                    spacing: PlasmaCore.Units.smallSpacing * 1.5
                    labelPixelSize: textPixelSize
                    Layout.fillHeight: true
                }
            }
        }
    }
}
