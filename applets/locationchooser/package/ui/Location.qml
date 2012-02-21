/*   vim:set foldenable foldmethod=marker:
 *
 *   Copyright (C) 2012 Ivan Cukic <ivan.cukic(at)kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0 as QML

import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents

QML.Item {
    id: main

    /* property: declarations --------------------------{{{ */
    property int minimumWidth: 312
    property int minimumHeight: locationDisplay.minimumHeight * 2
    /* }}} */

    /* signal declarations ----------------------------{{{ */
    /* }}} */

    /* JavaScript functions ---------------------------{{{ */
    onStateChanged: {
        locationManager.setListItemHeight(listItemMeasure.height)
        locationManager.setState(state)
    }
    /* }}} */

    /* object properties ------------------------------{{{ */
    state: "Showing"
    /* }}} */

    /* child objects ----------------------------------{{{ */
    PlasmaComponents.Label {
        id: labelTitle
        text: "Current location:"

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right

            leftMargin: 8
            rightMargin: 8
            topMargin: 8
        }
    }

    LocationDisplay {
        id: locationDisplay

        /*location: locationManager.currentLocationName*/

        anchors {
            top: labelTitle.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom

            leftMargin: 8
            rightMargin: 8
            bottomMargin: 8
        }

        onRequestChange: main.state = "Querying"
    }

    LocationChooser {
        id: locationChooser
        locationModel: locationManager.knownLocations

        anchors {
            top: labelTitle.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom

            leftMargin: 8
            rightMargin: 8
            bottomMargin: 8
        }

        onRequestChange: locationManager.setCurrentLocation(location)
    }

    LocationDelegate {
        id:      listItemMeasure
        property int index: 0
        title:   "Hello sweetie"
        visible: false
    }
    /* }}} */

    /* states -----------------------------------------{{{ */
    states: [
        QML.State {
            name: "Showing"
            QML.PropertyChanges { target: locationDisplay; visible: true }
            QML.PropertyChanges { target: locationChooser; visible: false }
        },
        QML.State {
            name: "Querying"
            QML.PropertyChanges { target: locationDisplay; visible: false }
            QML.PropertyChanges { target: locationChooser; visible: true }
        }
    ]
    /* }}} */

    /* transitions ------------------------------------{{{ */
    /* }}} */

    /* connections ------------------------------------{{{ */
    QML.Connections {
        target: locationManager

        onCurrentLocationNameChanged: {
            locationChooser.location = ""

            if (locationDisplay.location == name) return;
            locationDisplay.location = name

            if (name == "") {
                locationManager.setIcon("location-unknown")
            } else {
                locationManager.setIcon("location-changed")
            }
        }

        onResetUiRequested: {
            locationChooser.location = ""
            locationDisplay.location = locationManager.currentLocationName

            main.state = "Showing"
        }
    }
    /* }}} */
}

