/*
 *   Copycontext 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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

import QtQuick 2.1
import QtQuick.Controls 1.3
import "private"
import org.kde.plasma.mobilecomponents 0.2
import QtGraphicalEffects 1.0


Rectangle {
    id: headerItem
    z: 2
    anchors {
        left: parent.left
        right: parent.right
    }
    color: Theme.highlightColor
    height: Math.max(Units.gridUnit*1.6, Math.min(units.gridUnit * 5, -Math.min(0, appWindow.pageStack.currentItem.flickable.contentY)))
    y: Math.min(0, -appWindow.pageStack.currentItem.flickable.contentY-Units.gridUnit*1.6)

    property QtObject appWindow: applicationWindow();
    parent: appWindow.contentItem;

    Behavior on height {
        NumberAnimation {
            duration: Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    ListView {
        id: titleList
        anchors.fill: parent
        orientation: ListView.Horizontal
        model: appWindow.pageStack.depth
        spacing: Units.gridUnit
        currentIndex: appWindow.pageStack.currentIndex
        snapMode: ListView.SnapToItem
        delegate:MouseArea {
            width: Math.min(titleList.width, delegateRoot.implicitWidth)
            height: delegateRoot.height
            onClicked: appWindow.pageStack.currentIndex = modelData
            Row {
                id: delegateRoot

                spacing: Units.gridUnit
                Rectangle {
                    opacity: modelData > 0 ? 0.5 : 0
                    color: Theme.viewBackgroundColor
                    anchors.verticalCenter: parent.verticalCenter
                    width: height
                    height: Math.min(Units.gridUnit, title.height / 1.6)
                    radius: width
                }
                Heading {
                    id: title
                    width:Math.min(titleList.width, implicitWidth)
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: appWindow.pageStack.currentIndex == modelData ? 1 : 0.5
                    //Scaling animate NativeRendering is too slow
                    renderType: Text.QtRendering
                    color: Theme.viewBackgroundColor
                    elide: Text.ElideRight
                    text: appWindow.pageStack.pageAt(modelData).title
                    font.pixelSize: headerItem.height / 1.6
                }
            }
        }
    }
    LinearGradient {
        height: Units.gridUnit/2
        anchors {
            right: parent.right
            left: parent.left
            top: parent.bottom
        }

        start: Qt.point(0, 0)
        end: Qt.point(0, Units.gridUnit/2)
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Qt.rgba(0, 0, 0, 0.2)
            }
            GradientStop {
                position: 0.3
                color: Qt.rgba(0, 0, 0, 0.1)
            }
            GradientStop {
                position: 1.0
                color:  "transparent"
            }
        }
    }
}
