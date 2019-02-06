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

import org.kde.plasma.private.minishell 2.0 as MiniShell

Item {
    id: root
    objectName: "org.kde.desktop-CompactApplet"
    anchors.fill: parent

    property Item fullRepresentation
    property Item compactRepresentation
    property Item expandedFeedback: expandedItem

    property Item rootItem: {
        var item = root
        while (item.parent) {
            item = item.parent;
        }
        return item;
    }
    onCompactRepresentationChanged: {
        if (compactRepresentation) {
            compactRepresentation.parent = root;
            compactRepresentation.anchors.fill = root;
            compactRepresentation.visible = true;
        }
        root.visible = true;
    }

    onFullRepresentationChanged: {

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
        visible: plasmoid.formFactor != PlasmaCore.Types.Planar && plasmoid.expanded
    }

    Connections {
        target: plasmoid
        onExpandedChanged: {
            if (plasmoid.expanded) {
                expandedOverlay.showFullScreen()
            } else {
                expandedOverlay.visible = false;
            }
        }
    }

    MiniShell.FullScreenPanel {
        id: expandedOverlay
        color: Qt.rgba(0, 0, 0, 0.5)
        visible: plasmoid.expanded
        width: Screen.width
        height: Screen.height
        MouseArea {
            anchors.fill: parent
            onClicked: plasmoid.expanded = false
        }

        PlasmaCore.FrameSvgItem {
            id: appletParent
            imagePath: "widgets/background"
            //used only indesktop mode, not panel

            x: Math.min(parent.width - width - units.largeSpacing, Math.max(units.largeSpacing, root.mapToItem(root.rootItem, 0, 0).x + root.width / 2 - width / 2))
            y: Math.min(parent.height - height - units.largeSpacing, Math.max(units.largeSpacing, root.mapToItem(root.rootItem, 0, 0).y + root.height / 2 - height / 2))
            width: Math.max(Math.max(root.fullRepresentation.implicitWidth, units.gridUnit * 15), plasmoid.switchWidth) * 1.5
            height: Math.max(Math.max(root.fullRepresentation.implicitHeight, units.gridUnit * 15), plasmoid.switchHeight) * 1.5
        }
    }
}
