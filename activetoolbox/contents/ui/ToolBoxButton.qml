/***************************************************************************
 *   Copyright 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>    *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents

Item {
    id: toolBoxButton

    property string text: main.Plasmoid.activityName

    width: buttonLayout.width
    height: buttonLayout.height

    PlasmaCore.Svg {
        id: iconsSvg
        imagePath: "widgets/configuration-icons"
    }

    Row {
        id: buttonLayout
        spacing: units.smallSpacing

        MobileComponents.ActionButton {
            id: addButton
            svg: iconsSvg
            elementId: "add"
            onClicked: plasmoid.action("add widgets").trigger();
        }

        MobileComponents.ActionButton {
            id: configureButton
            svg: iconsSvg
            elementId: "configure"
            anchors {
                leftMargin: 10
            }
            onClicked: plasmoid.action("configure").trigger();
        }

        PlasmaComponents.Label {
            id: activityName
            text: toolBoxButton.text
            color: "white"
            font.bold: true
            font.pointSize: theme.defaultFont.pointSize * 1.5
            anchors{
                verticalCenter: configureButton.verticalCenter
            }
        }
    }
}
