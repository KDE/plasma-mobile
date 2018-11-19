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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    property string text
    property string sub
    property string display
    property string subdisplay
    property bool special: false

    Rectangle {
        anchors.fill: parent
        z: -1
        color: PlasmaCore.ColorScope.highlightColor
        radius: units.smallSpacing
        opacity: mouse.pressed ? 0.4 : 0
        Behavior on opacity {
            OpacityAnimator {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent

        onPressed: {
            if (pad.pressedCallback) {
                pad.pressedCallback(parent.text);
            }
        }
        onReleased: {
            if (pad.releasedCallback) {
                pad.releasedCallback(parent.text);
            }
        }
        onCanceled: {
            if (pad.releasedCallback) {
                pad.releasedCallback(parent.text);
            }
        }
        onClicked: {
            if (pad.callback) {
                pad.callback(parent.text);
            }
        }
        onPressAndHold: {
            var text = parent.sub.length > 0 ? parent.sub : parent.text
            if (pad.callback && text.length === 1) {
                pad.callback(text);
            }
        }
    }

    ColumnLayout {
        spacing: -5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        PlasmaComponents.Label {
            id: main

            font.pixelSize: units.gridUnit * 2
            text: root.display || root.text
            opacity: special? 0.4 : 1.0
            Layout.minimumWidth: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        PlasmaComponents.Label {
            id: longHold

            text: root.subdisplay || root.sub
            opacity: 0.4
            Layout.minimumWidth: parent.width
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
