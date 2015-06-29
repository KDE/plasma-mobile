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
import "../Dialpad"

Item {
    id: dialer

    property alias numberEntryText: status.text

    property string providerId: ofonoWrapper.providerId

    function addNumber(number) {
        status.text = status.text + number
    }

    Rectangle {
        width: parent.width / 2
        x: parent.width / 4
        y: parent.height - callStatusNotification.paintedHeight
        color: PlasmaCore.ColorScope.backgroundColor
        opacity: 0.6
        visible: dialerUtils.callState == "failed"

        PlasmaComponents.Label {
            id: callStatusNotification
            anchors.fill: parent
            text: "Unable to make a call at this moment"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: PlasmaCore.ColorScope.textColor
        }
    }

    ColumnLayout {
        id: dialPadArea

        anchors {
            fill: parent
            margins: units.largeSpacing
        }

        PlasmaComponents.Label {
            id: status
            Layout.fillWidth: true
            Layout.minimumHeight: parent.height / 6
            Layout.maximumHeight: Layout.minimumHeight

            horizontalAlignment: Qt.AlignRight
            verticalAlignment: Qt.AlignVCenter
            font.pointSize: 1024
            fontSizeMode: Text.Fit
        }

        Dialpad {
            Layout.fillWidth: true
            Layout.fillHeight: true

            callback: function (string) {
                addNumber(string);
            }
            pressedCallback: function (string) {
                ofonoWrapper.startTone(string);
            }
            releasedCallback: function (string) {
                ofonoWrapper.stopTone();
            }
        }
    }
}
