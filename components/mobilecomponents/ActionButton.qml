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

import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents

Item {
    id: button

    //API
    property QtObject svg
    property alias elementId: icon.elementId
    property QtObject action
    property bool backgroundVisible: true
    property int iconSize: 32
    property bool checked: false
    property bool toggle: false
    property string text
    signal clicked

    width: buttonRow.width
    height: buttonRow.height

    opacity: action==undefined||action.enabled?1:0.6

    Behavior on opacity {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }

    onCheckedChanged: {
        if (checked) {
            buttonItem.elementId = "pressed"
            shadowItem.opacity = 0
        } else {
            buttonItem.elementId = "normal"
            shadowItem.opacity = 1
        }
    }

    PlasmaCore.Theme {
        id: theme
    }

    PlasmaCore.Svg {
        id: buttonSvg
        imagePath: "widgets/actionbutton"
    }

    PlasmaCore.SvgItem {
        id: shadowItem
        svg: buttonSvg
        elementId: "shadow"
        width: iconSize+13//button.backgroundVisible?iconSize+8:iconSize
        height: width
        visible: button.backgroundVisible
    }

    Row {
        id: buttonRow

        Item {
            width: buttonItem.visible?buttonItem.width:iconSize
            height: buttonItem.visible?buttonItem.height:iconSize

            PlasmaCore.SvgItem {
                id: buttonItem
                svg: buttonSvg
                elementId: "normal"
                width: shadowItem.width
                height: shadowItem.height
                visible: backgroundVisible
            }

            PlasmaCore.SvgItem {
                id: icon
                width: iconSize
                height: iconSize
                svg: button.svg
                anchors.centerIn: parent
            }
        }

        Text {
            id: actionText
            text: button.text
            style: Text.Outline
            color: theme.textColor
            styleColor: Qt.rgba(1,1,1,0.4)
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.leftMargin: -10
        anchors.topMargin: -10
        anchors.rightMargin: -10
        anchors.bottomMargin: -10
        preventStealing: true
        onPressed: {
            buttonItem.elementId = "pressed"
            shadowItem.opacity = 0
        }
        onReleased: {
            if (button.checked || !button.toggle) {
                buttonItem.elementId = "normal"
                shadowItem.opacity = 1
                button.checked = false
            } else {
                button.checked = true
            }
        }
        onClicked: {
            if (action) {
                action.trigger()
            } else {
                button.clicked()
            }
        }
    }
}
