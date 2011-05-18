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
    property variant containmentConfig
    color: Qt.rgba(0,0,0,0.5)
    width: 800
    height: 480

    //FIXME: artificial delay to have configInterface working
    Timer {
        repeat: false
        running: true
        interval: 250
        onTriggered: activityNameEdit.text = configInterface.activityName
    }

    PlasmaCore.Theme {
        id: theme
    }

    PlasmaCore.FrameSvgItem {
        id: frame
        anchors.centerIn: parent
        width: 400
        height: 180
        imagePath: "dialogs/background"

        Row {
            anchors.centerIn: parent
            Text {
                color: theme.textColor
                text: i18n("Activity name:")
                anchors.verticalCenter: activityNameEdit.verticalCenter
            }
            PlasmaWidgets.LineEdit {
                id: activityNameEdit
            }
        }

        PlasmaWidgets.PushButton {
            id: closeButton
            anchors {
                bottom: parent.bottom
                right: parent.right
                rightMargin: frame.margins.right
                bottomMargin: frame.margins.bottom
            }

            text: i18n("Cancel")
            onClicked : main.closeRequested()
        }

        PlasmaWidgets.PushButton {
            id: okButton
            anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: frame.margins.left
                bottomMargin: frame.margins.bottom
            }

            text: i18n("Ok")
            onClicked : {
                configInterface.activityName = activityNameEdit.text
                main.closeRequested()
            }
        }
    }
}
