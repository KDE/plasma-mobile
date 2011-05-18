/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents

Rectangle {
    id: main
    signal closeRequested
    color: Qt.rgba(0,0,0,0.82)
    width: 800
    height: 480

    PlasmaCore.FrameSvgItem {
        id: frame
        anchors.fill: parent
        anchors.margins: 100
        imagePath: "dialogs/background"

        PlasmaWidgets.PushButton {
            id: closeButton
            width: addButton.width
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: frame.margins.right
            anchors.bottomMargin: frame.margins.bottom

            text: i18n("Close")
            onClicked : main.closeRequested()
        }
    }
}
