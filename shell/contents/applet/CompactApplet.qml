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

PlasmaCore.ToolTipArea {
    id: root
    objectName: "org.kde.desktop-CompactApplet"
    anchors.fill: parent

    icon: plasmoid.icon
    mainText: plasmoid.toolTipMainText
    subText: plasmoid.toolTipSubText
    location: plasmoid.location
    active: !plasmoid.expanded
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

        if (!fullRepresentation) {
            return;
        }
       /* //if the fullRepresentation size was restored to a stored size, or if is dragged from the desktop, restore popup size
        if (fullRepresentation.width > 0) {
            appletParent.width = fullRepresentation.width;
        } else if (fullRepresentation.Layout && fullRepresentation.Layout.preferredWidth > 0) {
            appletParent.width = fullRepresentation.Layout.preferredWidth
        } else if (fullRepresentation.implicitWidth > 0) {
            appletParent.width = fullRepresentation.implicitWidth
        } else {
            appletParent.width = theme.mSize(theme.defaultFont).width * 35
        }

        if (fullRepresentation.height > 0) {
            appletParent.height = fullRepresentation.height;
        } else if (fullRepresentation.Layout && fullRepresentation.Layout.preferredHeight > 0) {
            appletParent.height = fullRepresentation.Layout.preferredHeight
        } else if (fullRepresentation.implicitHeight > 0) {
            appletParent.height = fullRepresentation.implicitHeight
        } else {
            appletParent.height = theme.mSize(theme.defaultFont).height * 25
        }*/

        fullRepresentation.parent = appletParent;
        fullRepresentation.anchors.fill = fullRepresentation.parent;
    }

    Rectangle {
        id: expandedItem
        anchors.fill: parent
        color: PlasmaCore.ColorScope.highlightColor
        opacity: plasmoid.expanded ? 0.3 : 0
        Behavior on opacity {
            OpacityAnimator {
                duration: units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
 
    Timer {
        id: expandedSync
        interval: 100
        onTriggered: plasmoid.expanded = popupWindow.visible;
    }

    Item {
        id: appletParent
        opacity: plasmoid.expanded ? 1 : 0
        anchors.top: parent.bottom
        Layout.minimumWidth: (fullRepresentation && fullRepresentation.Layout) ? fullRepresentation.Layout.minimumWidth : 0
        Layout.minimumHeight: (fullRepresentation && fullRepresentation.Layout) ? fullRepresentation.Layout.minimumHeight: 0
        Layout.maximumWidth: (fullRepresentation && fullRepresentation.Layout) ? fullRepresentation.Layout.maximumWidth : Infinity
        Layout.maximumHeight: (fullRepresentation && fullRepresentation.Layout) ? fullRepresentation.Layout.maximumHeight: Infinity
        width: Math.max(parent.width, Layout.minimumWidth)
        height: Layout.minimumHeight

        Behavior on opacity {
            OpacityAnimator {
                duration: units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

}
