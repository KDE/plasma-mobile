/*
 *   SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

PlasmaComponents.Label {
    horizontalAlignment: Qt.AlignHCenter
    verticalAlignment: Qt.AlignVCenter
    font.pixelSize: PlasmaCore.Units.gridUnit * 1.6
    property alias sub: longHold.text
    property var callback
    Layout.fillWidth: true

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (callback) {
                callback();
            } else {
                addNumber(parent.text);
            }
        }

        onPressAndHold: {
            if (longHold.visible) {
                addNumber(longHold.text);
            } else {
                addNumber(parent.text);
            }
        }
    }

    PlasmaComponents.Label {
        id: longHold
        anchors {
            top: parent.top
            right: parent.right
        }
        height: parent.height
        width: parent.width / 3
        verticalAlignment: Qt.AlignVCenter
        visible: text.length > 0
        opacity: 0.7

        font.pixelSize: parent.pixelSize * .8
    }
}
