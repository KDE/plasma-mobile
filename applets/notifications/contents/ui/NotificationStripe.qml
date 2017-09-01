/*
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
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

import QtQuick 2.4
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

MouseArea {
    id: notificationItem


    //actionsLayout.height*2 because the text is centered
    //TODO: center the whole block not only the text
    height: Math.max(units.gridUnit * 3, Math.max(messageLayout.height, icon.height)) + (expanded ? actionsLayout.height*2 : 0)
    width: parent.width
    anchors.bottomMargin: 10
    drag.axis: Drag.XAxis
    drag.target: notificationItem

    property bool expanded: false
    property string source: model.source
    property var actions: model.actions

    opacity: 1 - Math.abs(x) / (width/2)
    Behavior on x {
        NumberAnimation {
            easing.type: Easing.InOutQuad
            duration: units.longDuration
        }
    }
    Behavior on height {
        NumberAnimation {
            easing.type: Easing.InOutQuad
            duration: units.longDuration
        }
    }

    onReleased: {
        if (drag.active) {
            if (x > width / 4 || x < width / -4) {
                //if there is an action, execute the first when swiping left
                if (x < 0 && actions) {
                    var action = actions.get(0);
                    if (action) {
                        root.executeAction(source, action.id)
                    }
                }
                notificationsModel.remove(index);
            } else {
                x = 0;
            }
        } else if (body || actions) {
            expanded = !expanded;
        }
    }


    Rectangle {
        id: background
        anchors.fill: parent
        color: Qt.rgba(PlasmaCore.ColorScope.textColor.r, PlasmaCore.ColorScope.textColor.g, PlasmaCore.ColorScope.textColor.b, notificationItem.pressed ? 0.5 : 0.2)
    }

    PlasmaComponents.ToolButton {
        id: closeButton
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: units.gridUnit
        }
        iconSource: "window-close"
        flat: false
        onClicked: {
            notificationsModel.remove(index);
        }
    }

    ColumnLayout {
        id: messageLayout
        anchors {
            verticalCenter: parent.verticalCenter
            left: icon.right
            right: notificationItem.expanded ? actionsLayout.left : closeButton.left
            leftMargin: units.gridUnit
            rightMargin: units.gridUnit
        }

        PlasmaComponents.Label {
            id: summaryLabel
            Layout.fillWidth: true
            verticalAlignment: Qt.AlignVCenter
            text: model.appName + " " + summary
            elide: Text.ElideRight
        }

        PlasmaComponents.Label {
            id: bodyLabel
            Layout.fillWidth: true
            visible: text.length > 0
            opacity: 0.8
            verticalAlignment: Qt.AlignVCenter
            text: body
            wrapMode: Text.WordWrap
        }
    }


    PlasmaCore.IconItem {
        id: icon
        anchors {
            verticalCenter: parent.verticalCenter
        }
        x: units.gridUnit
        width: units.iconSizes.medium
        height: width
        source: appIcon && appIcon.length > 0 ? appIcon : "preferences-desktop-notification"
        colorGroup: PlasmaCore.ColorScope.colorGroup
    }

    Column {
        id: actionsLayout
        anchors {
            right: closeButton.left
            rightMargin: units.gridUnit
            verticalCenter: parent.verticalCenter
        }
        opacity: notificationItem.expanded && notificationItem.actions && notificationItem.actions.count > 0 ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }
        Repeater {
            model: notificationItem.actions
            delegate: PlasmaComponents.Button {
                text: model.text
                onClicked: {
                    root.executeAction(notificationItem.source, model.id)
                    notificationsModel.remove(index);
                }
            }
        }
    }
}
