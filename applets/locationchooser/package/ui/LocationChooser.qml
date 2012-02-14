/*
 *   Copyright 2012 Ivan Cukic <ivan.cukic at kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents

Item {
    id: locationUi
    // property int minimumWidth: 290
    property int minimumWidth: buttonChange.width * 3
    property int minimumHeight: 64

    PlasmaCore.Theme {
        id: theme
    }

    PlasmaComponents.Label {
        id: labelLocation

        text: "Current location:"

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    Item {
        id: input

        anchors {
            top: labelLocation.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        PlasmaComponents.Button {
            id: buttonChange
            text: textLocation.visible ? "Set" : "Change"

            anchors {
                top: parent.top
                right: parent.right
            }

            onClicked: {
                if (textLocation.visible == true) {
                    locationManager.setCurrentLocation(textLocation.text)
                    textLocation.visible = false
                } else {
                    textLocation.visible = true
                }
            }
        }

        PlasmaComponents.TextField {
            id: textLocation
            text: locationManager.currentLocationName

            anchors {
                top: parent.top
                bottom: buttonChange.bottom
                right: buttonChange.left
                left: parent.left
            }

            visible: false
        }

        PlasmaComponents.Label {
            id: textLocationRO
            text: (textLocation.text == "") ? "Unkown" : textLocation.text

            anchors.fill: textLocation
            visible: !textLocation.visible

            MouseArea {
                anchors.fill: parent
                onClicked: textLocation.visible = true
            }
        }

        Connections {
            target: locationManager
            onCurrentLocationNameChanged: {
                if (textLocation.text == name) return;

                textLocation.text = name

                if (name == "") {
                    locationManager.setIcon("location-unknown")
                } else {
                    locationManager.setIcon("location-changed")
                }
            }

            onResetUiRequested: {
                textLocation.text    = locationManager.currentLocationName
                textLocation.visible = false
            }
        }
    }
}
