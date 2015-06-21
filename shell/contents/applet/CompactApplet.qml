/*
 *  Copyright 2013 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */
import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

Item {
    id: root
    objectName: "org.kde.desktop-CompactApplet"
    anchors.fill: parent

    property Item fullRepresentation
    property Item compactRepresentation
    property Item expandedFeedback: expandedItem

    onCompactRepresentationChanged: {
        if (compactRepresentation) {
            compactRepresentation.parent = root;
            compactRepresentation.anchors.fill = root;
            compactRepresentation.visible = true;
        }
        root.visible = true;
    }

    onFullRepresentationChanged: {
print(fullRepresentation);
        if (!fullRepresentation) {
            return;
        }

        fullRepresentation.parent = appletParent;
        fullRepresentation.anchors.fill = fullRepresentation.parent;
        fullRepresentation.anchors.margins = appletParent.margins.top;
    }

    Rectangle {
        id: expandedItem
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.top
        }
        height: units.smallSpacing
        color: PlasmaCore.ColorScope.highlightColor
        visible: plasmoid.expanded
    }

    PlasmaCore.FrameSvgItem {
        id: appletParent
        imagePath: "widgets/background"
        visible: fullRepresentation.parent == appletParent
        z: 99
        opacity: plasmoid.expanded ? 1 : 0
        anchors.top: parent.top
        width: parent.width
        height: units.gridUnit * 20 - units.iconSizes.medium

        Behavior on opacity {
            OpacityAnimator {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

}
