/*
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2014 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.Label {
    Layout.fillWidth: true
    Layout.fillHeight: true

    //This is 0 to override the Label default height that would cause a binding loop
    height: 0
    horizontalAlignment: Qt.AlignHCenter
    verticalAlignment: Qt.AlignVCenter
    font.pointSize: 1024
    fontSizeMode: Text.VerticalFit

    property alias sub: longHold.text
    property var callback
    property var pressedCallback
    property var releasedCallback

    MouseArea {
        anchors.fill: parent
        onPressed: {
            if (pressedCallback) {
                pressedCallback(parent.text);
            } else if (pad.pressedCallback) {
                pad.pressedCallback(parent.text);
            }
        }
        onReleased: {
            if (releasedCallback) {
                releasedCallback(parent.text);
            } else if (pad.releasedCallback) {
                pad.releasedCallback(parent.text);
            }
        }
        onCanceled: {
            if (releasedCallback) {
                releasedCallback(parent.text);
            } else if (pad.releasedCallback) {
                pad.releasedCallback(parent.text);
            }
        }

        onClicked: {
            if (callback) {
                callback(parent.text);
            } else if (pad.callback) {
                pad.callback(parent.text);
            }
        }

        onPressAndHold: {
            var text;
            if (longHold.visible) {
                text = longHold.text;
            } else {
                text = parent.text;
            }

            if (callback) {
                callback(text);
            } else if (pad.callback) {
                pad.callback(text);
            }
        }
    }

    PlasmaComponents.Label {
        id: longHold
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
        }
        height: parent.height * 0.6
        width: parent.width / 3
        verticalAlignment: Qt.AlignVCenter
        visible: text.length > 0
        opacity: 0.7

        font.pointSize: 1024
        fontSizeMode: Text.Fit
    }
}
