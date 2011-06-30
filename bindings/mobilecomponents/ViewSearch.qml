/*
    Copyright 2010 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents


Item {
    id: searchFieldContainer
    
    property string searchQuery
    
    anchors {
        left: parent.left
        top: parent.top
        right: parent.right
    }

    height: 64
    PlasmaWidgets.LineEdit {
        id : searchField

        clickMessage: i18n("Click to search...")
        /*width: 300
        height: 35*/
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        onTextChanged: {
            searchTimer.running = true
        }
    }
    Timer {
        id: searchTimer
        interval: 500;
        running: false
        repeat: false
        onTriggered: {
            if (searchField.text == "") {
                clearButton.visible = false
            } else {
                clearButton.visible = true
            }
            searchQuery = searchField.text
        }
    }
    QIconItem {
        id: clearButton
        y: 6
        anchors.right: searchField.right
        anchors.rightMargin: -6
        visible: false
        width: 48
        height: 48
        icon: QIcon("edit-clear-locationbar-rtl")

        MouseArea {
            anchors.fill: parent
            onClicked: {
                searchField.text = ""
            }
        }
    }
}

