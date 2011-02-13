/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.qtextracomponents 4.7

Item {
    id: delegate
    width: itemsRow.childrenRect.width
    height: itemsRow.childrenRect.height
    /*scale: PathView.delegateScale
    opacity: PathView.delegateOpacity*/

    Rectangle {
        color: "white"
        width: itemsRow.width -64
        height: 12
        x: 0
        y: parent.height/2 - height/2
    }

    Row {
        id: itemsRow
        Repeater {
            model: elements

            Item {
                x: 0
                id: wrapper
                width: childrenRect.width
                height: childrenRect.height

                Rectangle {
                    anchors.verticalCenter: iconBackgroundSvg.verticalCenter
                    x: 100
                    color: "black"
                    border.color: "white"
                    border.width: 8
                    radius:6
                    width: 100
                    height: nameText.height+border.width*2
                    Text {
                        id: nameText
                        text: name
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: 14
                        wrapMode: Text.WordWrap
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                    }
                }

                PlasmaCore.SvgItem {
                    id: iconBackgroundSvg
                    width: 128
                    height: 128
                    svg: iconsSvg
                    elementId: "icon-background"

                    QIconItem {
                        id: elementIcon
                        anchors.verticalCenter: parent.verticalCenter
                        width:48
                        height:48
                        anchors.horizontalCenter: parent.horizontalCenter
                        icon: QIcon(model.icon)
                    }
                }
            }
        }
        PlasmaCore.SvgItem {
            width: 128
            height: 128
            svg: iconsSvg
            elementId: "add"
        }
    }
    Connector {
        id: itemConnector
        itemA: activityRootSvg
        itemB: delegate
    }

    MouseArea {
            anchors.fill: parent
            onClicked: {
                print(itemsRow.childrenRect.width)
            }
        }
}
