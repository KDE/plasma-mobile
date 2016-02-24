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

import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.2
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
    Layout.minimumHeight: Units.gridUnit*1.6

    height: units.gridUnit * 5

    y: appWindow.pageStack.currentItem.flickable ? Math.min(0, -appWindow.pageStack.currentItem.flickable.contentY - height) : -height

    property QtObject appWindow: applicationWindow();
    parent: appWindow.contentItem;

    Behavior on y {
        enabled: !appWindow.pageStack.currentItem.flickable.moving
        NumberAnimation {
            duration: Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    ListView {
        id: titleList
        anchors {
            fill: parent
            topMargin: Math.min(headerItem.height - headerItem.Layout.minimumHeight, -headerItem.y)
        }
        property bool wideScreen: appWindow.pageStack.currentItem && appWindow.pageStack.currentItem.width > 0 && appWindow.pageStack.width > appWindow.pageStack.currentItem.width
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        //FIXME: proper implmentation needs Qt 5.6 for new ObjectModel api
        model: appWindow.pageStack.depth
        spacing: wideScreen ? 0 : Units.gridUnit
        currentIndex: appWindow.pageStack.currentIndex
        snapMode: ListView.SnapToItem

        onCurrentIndexChanged: {
            positionViewAtIndex(currentIndex, ListView.Contain);
        }

        onContentXChanged: {
            if (wideScreen && !appWindow.pageStack.contentItem.moving) {
                appWindow.pageStack.contentItem.contentX = titleList.contentX
            }
        }
        onHeightChanged: {
            titleList.returnToBounds()
        }
        onMovementEnded: {
            if (wideScreen) {
                appWindow.pageStack.contentItem.movementEnded();
            }
        }
        delegate: MouseArea {
            width: {
                //more columns shown?
                if (titleList.wideScreen) {
                    return appWindow.pageStack.defaultColumnWidth;
                } else {
                    return Math.min(titleList.width, delegateRoot.implicitWidth);
                }
            }
            height: titleList.height
            onClicked: appWindow.pageStack.currentIndex = modelData
            Row {
                id: delegateRoot

                spacing: Units.gridUnit
                Rectangle {
                    opacity: modelData > 0 ? 0.5 : 0
                    visible: !titleList.wideScreen
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
                    font.pixelSize: titleList.height / 1.6
                }
            }
            Connections {
                target: appWindow.pageStack.pageAt(modelData).flickable
                onMovingChanged: {
                    if (appWindow.pageStack.pageAt(modelData).flickable.moving) {
                        appWindow.pageStack.currentIndex = modelData
                    }
                }
            }
        }
        Connections {
            target: titleList.wideScreen ? appWindow.pageStack.contentItem : null
            onContentXChanged: {
                if (!titleList.contentItem.moving) {
                    titleList.contentX = Math.max(0, appWindow.pageStack.contentItem.contentX)
                }
            }
        }
    }
    LinearGradient {
        height: Units.gridUnit/2
        opacity: headerItem.y > -headerItem.height ? 1 : 0
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
        Behavior on opacity {
            OpacityAnimator {
                duration: Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
}
