// SPDX-FileCopyrightText: 2022 Yari Polla <skilvingr@gmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.15

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents

/**
 * This is a simple marquee (flowing) label based on PlasmaComponents Label.
 */

PlasmaComponents.Label {
    id: root

    required property string inputText
    readonly property string filteredText: inputText.replace(/\n/g, ' ') // remove new line characters

    readonly property int interval: 200 // update position every 200 ms
    readonly property int longDuration: 300
    readonly property int waitDuration: 900

    readonly property int charactersOverflow: Math.ceil((txtMeter.advanceWidth - root.width) / (txtMeter.advanceWidth / filteredText.length))
    property int step: 0

    TextMetrics {
        id: txtMeter
        font: root.font
        text: filteredText
    }

    Timer {
        property bool paused: false

        interval: root.interval
        running: visible && charactersOverflow > 0
        repeat: true
        onTriggered: {
            if (paused) {
                if (step != 0) {
                    interval = root.longDuration;
                    step = 0;
                } else {
                    interval = root.interval;
                    paused = false;
                }
            } else {
                step = (step + 1) % filteredText.length;
                if (step === charactersOverflow) {
                    interval = root.waitDuration;
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

    text: filteredText.substring(step, step + filteredText.length - charactersOverflow)
}
