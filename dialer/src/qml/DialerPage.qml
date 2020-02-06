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
import QtQuick.Controls 2.5 as QQC2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.9 as Kirigami
import "Dialpad"

Kirigami.Page {
    id: dialer

    property alias numberEntryText: status.text

    title: i18n("Dialer")
    header: Kirigami.InlineMessage {
        type: Kirigami.MessageType.Error
        text: i18n("Unable to make a call at this moment")
        visible: dialerUtils.callState == "failed"
    }

    ColumnLayout {
        id: dialPadArea
        anchors.fill: parent

        QQC2.Label {
            id: status

            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignBottom

            Layout.fillWidth: true
            Layout.topMargin: units.largeSpacing * 2
            Layout.bottomMargin: units.largeSpacing
            Layout.minimumHeight: units.gridUnit * 3
            Layout.maximumHeight: Layout.minimumHeight
            font.pixelSize: units.gridUnit * 2.3
        }

        Dialpad {
            Layout.fillWidth: true
            Layout.fillHeight: true

            callback: function (string) {
                var newText = status.text + string
                status.text = dialerUtils.formatNumber(newText);
            }
            deleteCallback: function () {
                var newText = status.text.slice(0, -1)
                status.text = dialerUtils.formatNumber(newText);
            }
            pressedCallback: function (string) {
                // TODO
                // ofonoWrapper.startTone(string);
            }
            releasedCallback: function (string) {
                // ofonoWrapper.stopTone();
            }
        }
    }
}
