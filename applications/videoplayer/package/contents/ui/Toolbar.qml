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

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.qtextracomponents 0.1

PlasmaCore.FrameSvgItem {
    id: toolbar
    anchors {
        left: parent.left
        right: parent.right
    }
    signal zoomIn()
    signal zoomOut()

    height: childrenRect.height + margins.bottom
    imagePath: "widgets/frame"
    prefix: "raised"
    enabledBorders: "BottomBorder"
    z: 9000
    Behavior on y {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }

    QIconItem {
        icon: QIcon("go-previous")
        width: 48
        height: 48
        opacity: viewer.scale==1?1:0
        anchors.verticalCenter: parent.verticalCenter
        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: imageViewer.state = "browsing"
        }
    }
    Text {
        text: i18n("%1 of %2", fullList.currentIndex+1, fullList.count)
        anchors.centerIn: parent
        font.pointSize: 14
        font.bold: true
        color: theme.textColor
        visible: viewer.scale==1
        style: Text.Raised
        styleColor: theme.backgroundColor
    }
    MobileComponents.ViewSearch {
        id: searchBox
        anchors {
            left: parent.left
            right:parent.right
            top:parent.top
        }
        onSearchQueryChanged: {
            filterModel.filterRegExp = ".*"+searchBox.searchQuery+".*"
            busy = (searchBox.searchQuery.length > 0)
        }
        Connections {
            target: filterModel
            onCountChanged: { searchBox.restartBusyTimer() }
        }
        opacity: viewer.scale==1?0:1
        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }

    PlasmaCore.Svg {
        id: iconsSvg
        imagePath: "widgets/configuration-icons"
    }
    Row {
        opacity: viewer.scale==1?1:0
        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
        }
        //TODO: ad hoc icons
        MobileComponents.ActionButton {
            svg: iconsSvg
            elementId: "add"
            onClicked: {
                toolbar.zoomIn()
            }
        }
        MobileComponents.ActionButton {
            svg: iconsSvg
            elementId: "remove"
            onClicked: {
                toolbar.zoomOut()
            }
        }
    }
}
