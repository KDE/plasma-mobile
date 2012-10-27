/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1 as QtExtra

Item {
    id: taskIcon
    width: main.itemWidth
    height: main.itemHeight
    //hide application status icons
    opacity: (Category != "ApplicationStatus" && (main.state == "active" || Status != "Passive")) ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    //FIXME: sometimes doesn't get mapped in roles
    property string iconName: statusNotifierSource.data[DataEngineSource]["IconName"]
    onIconNameChanged: iconSvg.updateVisibility()
    PlasmaCore.Svg {
        id: iconSvg
        imagePath: iconName ? "icons/" + String(iconName).split('-')[0] : ''
        onRepaintNeeded: updateVisibility()
        Component.onCompleted: updateVisibility()

        function updateVisibility() {
            var hasSvg = iconName ? iconSvg.hasElement(iconName) : false
            normalIcon.visible = !hasSvg
            svgItemIcon.visible = hasSvg
        }
    }
    QtExtra.QIconItem {
        id: normalIcon
        anchors.fill: parent
        icon: Icon
    }
    PlasmaCore.SvgItem {
        id: svgItemIcon
        anchors.centerIn: parent
        width: Math.max(16, Math.min(parent.width, parent.height))
        height: width
        svg: iconSvg
        elementId: IconName ? IconName : ''
    }

    MouseArea {
        anchors.fill: taskIcon
        onClicked: {
            //print(iconSvg.hasElement(IconName))
            var service = statusNotifierSource.serviceForSource(DataEngineSource)
            var operation = service.operationDescription("Activate")
            operation.x = parent.x

            // kmix shows main window instead of volume popup if (parent.x, parent.y) == (0, 0), which is the case here.
            // I am passing a position right below the panel (assuming panel is at screen's top).
            // Plasmoids' popups are already shown below the panel, so this make kmix's popup more consistent
            // to them.
            operation.y = parent.y + parent.height + 6
            service.startOperationCall(operation)
        }
    }
}
