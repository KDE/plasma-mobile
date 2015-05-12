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

import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

MouseArea {
    id: notificationItem


    height: units.gridUnit * (expanded ? (actionsLayout.visible ? 6 : 4) : 2) + background.margins.top + background.margins.bottom
    width: parent.width
    anchors.bottomMargin: 10
    drag.axis: Drag.XAxis
    drag.target: notificationItem

    property bool expanded: false
    property string source: model.source
    property var actions: model.actions

    Behavior on x {
        SpringAnimation { spring: 2; damping: 0.2 }
    }

    Behavior on height {
        SpringAnimation { spring: 5; damping: 0.3 }
    }

    onReleased: {
        if (drag.active) {
            if (x > width / 4 || x < width / -4) {
                //if there is an action, execute the first when swiping left
                if (x < 0 && actions) {
                    var action = actions.get(0)
                    root.executeAction(source, action.id)
                }
                notificationsModel.remove(index);
            } else {
                x = 0;
            }
        } else if (body || actions) {
            expanded = !expanded;
        }
    }


    PlasmaCore.FrameSvgItem {
        id: background
        imagePath: "widgets/background"
        anchors {
            fill: parent
            rightMargin: -notificationItem.width
            leftMargin: units.gridUnit
        }
        colorGroup: PlasmaCore.ColorScope.colorGroup
    }

    PlasmaComponents.ToolButton {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: units.gridUnit / 2
        }
        iconSource: "window-close"
        flat: false
        onClicked: {
            notificationsModel.remove(index);
        }
    }

    PlasmaComponents.Label {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: units.gridUnit * 3
        }
        color: PlasmaCore.ColorScope.textColor
        text: model.appName
    }

    PlasmaComponents.Label {
        id: summaryText
        anchors {
            right: icon.left
            verticalCenter: parent.verticalCenter
            rightMargin: units.smallSpacing
        }
        horizontalAlignment: Qt.AlignRight
        verticalAlignment: Qt.AlignVCenter
        color: PlasmaCore.ColorScope.textColor
        text: summary + (notificationItem.expanded ? (body ? "\n" + body : '') :
                                            (body ? '...' : ''))
    }

    PlasmaCore.IconItem {
        id: icon
        anchors {
            right: notificationItem.right
            verticalCenter: parent.verticalCenter
        }
        width: units.iconSizes.medium
        height: width
        source: appIcon && appIcon.length > 0 ? appIcon : "im-user"
    }
    RowLayout {
        id: actionsLayout
        anchors {
            right: summaryText.right
            top: summaryText.bottom
            topMargin: units.smallSpacing
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
