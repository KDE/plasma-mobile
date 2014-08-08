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
    width: commonList.delegateWidth
    height: commonList.delegateHeight

    imagePath: "widgets/viewitem"
    prefix: mouseArea.containsMouse ? "hover" : "normal"
    property var commonListView : commonList
    ColumnLayout {
        id: col
        Layout.fillWidth: true
        Layout.fillHeight: true
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
            icon: isApplicationExplorer ? model.ApplicationIconRole :  model.decoration
        }

        PlasmaComponents.Label {
            id: titleText
            text: isApplicationExplorer ? ApplicationNameRole : display
            Layout.fillWidth: true
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            maximumLineCount: 1
            horizontalAlignment: Text.AlignHCenter
            anchors.topMargin: units.smallSpacing
        }

        QIconItem {
            icon: (typeof running !== "undefined" && running) ? "dialog-ok-apply" : undefined
            visible: (typeof running !== "undefined" && running) ? running : false
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
            if (isApplicationExplorer) {
                activityResources.shownAgents = "Application";
                activityResources.linkResourceToActivity(model.ApplicationEntryPathRole, function () {});
                activityResources.shownAgents = ":any"
            } else {
                widgetExplorer.addApplet(model.pluginName)
            }
            commonListView.currentIndex = (commonListView.currentPage * commonListView.pageSize) + commonListView.index
            commonListView.closeRequested()
        }
    }
}
