/*
 *   SPDX-FileCopyrightText: 2022 Yari Polla <skilvingr@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

/**
 * This is a simple marquee (flowing) label based on PlasmaComponents Label.Array()
 * 
 * 
 */
PlasmaComponents.Label {
    id: root
                
    required property string inputText
    required property real rightPadding
    
    property int interval: PlasmaCore.Units.veryLongDuration
    
    readonly property int charactersOverflow: Math.ceil((txtMeter.width - parent.width + 2*rightPadding) / font.pointSize)
    readonly property string displayedText: inputText.substring(step, step + inputText.length - charactersOverflow)
    property int step: 0
    
    TextMetrics {
        id: txtMeter
        font.pointSize: root.font.pointSize
        text: inputText
    }
    
    Timer {              
        property bool paused: false
        
        interval: root.interval
        running: visible && charactersOverflow > 0
        repeat: true
        onTriggered: {
            if (paused) {
                if (step != 0) {
                    step = 0;
                } else {
                    interval /= 3;
                    paused = false;
                }                        
            } else {
                step = (step + 1) % inputText.length;
                    
                if (step === charactersOverflow) {
                    interval *= 3;
                    paused = true;
                }
            }
        }
        
        onRunningChanged: {
            if (!running) {
                step = 0;
            }
        }
    }
    
    text: displayedText
}
