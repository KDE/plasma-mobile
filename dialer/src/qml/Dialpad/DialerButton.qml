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
import QtQuick.Controls 2.2 as Controls

import org.kde.kirigami 2.2 as Kirigami


Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    signal clicked(string text)

    property string text
    property string sub
    property string display
    property string subdisplay
    property bool special: false

    Rectangle {
        anchors.fill: parent
        z: -1
        color: Kirigami.Theme.highlightColor
        radius: units.smallSpacing
        opacity: mouse.pressed ? 0.4 : 0
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent

        onClicked: root.clicked(parent.text)

        onPressAndHold: {
            var text = parent.sub.length > 0 ? parent.sub : parent.text
            if (text.length === 1) {
                root.clicked(text);
            }
        }
    }

    ColumnLayout {
        spacing: -5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Controls.Label {
            id: main

            font.pixelSize: units.gridUnit * 2
            text: root.display || root.text
            opacity: special ? 0.4 : 1.0
            Layout.minimumWidth: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        Controls.Label {
            id: longHold

            text: root.subdisplay || root.sub
            opacity: 0.4
            Layout.minimumWidth: parent.width
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
