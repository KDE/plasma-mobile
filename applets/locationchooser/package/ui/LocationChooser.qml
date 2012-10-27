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

    /* property declarations --------------------------{{{ */
    property alias location: textLocation.text
    property alias locationModel: listLocations.model
    /* }}} */

    /* signal declarations ----------------------------{{{ */
    signal requestChange(string location)
    /* }}} */

    /* JavaScript functions ---------------------------{{{ */
    /* }}} */

    /* object properties ------------------------------{{{ */
    /* }}} */

    /* child objects ----------------------------------{{{ */

        PlasmaComponents.TextField {
            id: textLocation

            anchors {
                bottom: parent.bottom
                top: buttonSet.top
                right: buttonSet.left
                left: parent.left
            }
        }

        PlasmaComponents.Button {
            id: buttonSet
            text: "Set"

            width: parent.width / 3

            onClicked: main.requestChange(textLocation.text)

            anchors {
                bottom: parent.bottom
                right: parent.right
            }
        }

        PlasmaCore.Svg {
            id: configIconsSvg
            imagePath: "widgets/configuration-icons"
        }
        QML.ListView {
            id: listLocations
            clip: true

            delegate: LocationDelegate {
                title:     model.modelData.name
                onClicked: {
                    print ("clicked")
                    main.requestChange(model.modelData.name)
                }
                onRemoveAsked: locationManager.removeLocation(model.modelData.id)
            }

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: buttonSet.top
            }
        }

    /* }}} */

    /* states -----------------------------------------{{{ */
    /* }}} */

    /* transitions ------------------------------------{{{ */
    /* }}} */
}

