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

import QtQuick 2.0
import QtQuick.Layouts 1.0

import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.draganddrop 2.0
import org.kde.kquickcontrolsaddons 2.0

PlasmaCore.FrameSvgItem {
    id: background
    width: list.delegateWidth
    height: list.delegateHeight

    imagePath: "widgets/viewitem"
    prefix: mouseArea.containsMouse ? "hover" : "normal"
    property var listView : list
    ColumnLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: background.margins.top
            bottomMargin: background.margins.bottom
            leftMargin: background.margins.left
            rightMargin: background.margins.right
        }
        spacing: 4
        QIconItem {
            id: iconWidget
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width / 2
            height: width
            icon: model.decoration
        }

        PlasmaExtras.Heading {
            id: titleText
            level: 4
            text: model.name
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            anchors {
                topMargin: units.smallSpacing
                horizontalCenter: parent.horizontalCenter
            }
        }

        QIconItem {
            icon: running ? "dialog-ok-apply" : undefined
            visible: running
            width: units.iconSizes.small
            height: width
            anchors {
                top: iconWidget.top
                left: iconWidget.left
                topMargin: units.smallSpacing
                leftMargin: units.smallSpacing
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            widgetExplorer.addApplet(model.pluginName)
            listView.currentIndex = (listView.currentPage * listView.pageSize) + listView.index
            listView.closeRequested()
        }
    }
}
