/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls
import QtGraphicalEffects 1.6

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.phone.homescreen 1.0

MouseArea {
    id: delegate
    width: GridView.view.cellWidth
    height: GridView.view.cellHeight

    property int reservedSpaceForLabel
    property alias iconItem: icon

    signal launch(int x, int y, var source, string title, string storageId)
    signal dragStarted(string imageSource, int x, int y, string mimeData)

    onPressAndHold: {
        delegate.grabToImage(function(result) {
            delegate.Drag.imageSource = result.url
            dragStarted(result.url, width/2, height/2, model.applicationStorageId)
        })
    }

    onClicked: {
        if (model.applicationRunning) {
            delegate.launch(0, 0, "", model.applicationName, model.applicationStorageId);
        } else {
            delegate.launch(delegate.x + (units.smallSpacing * 2), delegate.y + (units.smallSpacing * 2), icon.source, model.applicationName, model.applicationStorageId);
        }
    }

    //preventStealing: true
    ColumnLayout {
        anchors {
            fill: parent
            leftMargin: units.smallSpacing * 2
            topMargin: units.smallSpacing * 2
            rightMargin: units.smallSpacing * 2
            bottomMargin: units.smallSpacing * 2
        }
        spacing: 0

        PlasmaCore.IconItem {
            id: icon

            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillWidth: true
            Layout.minimumHeight: parent.height - delegate.reservedSpaceForLabel
            Layout.preferredHeight: Layout.minimumHeight

            usesPlasmaTheme: false
            source: model.applicationIcon

            Rectangle {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
                visible: model.applicationRunning
                radius: width
                width: units.smallSpacing
                height: width
                color: theme.highlightColor
            }
        }

        PlasmaComponents.Label {
            id: label
            visible: text.length > 0

            Layout.fillWidth: true
            Layout.preferredHeight: delegate.reservedSpaceForLabel
            wrapMode: Text.WordWrap
            Layout.leftMargin: -parent.anchors.leftMargin + units.smallSpacing
            Layout.rightMargin: -parent.anchors.rightMargin + units.smallSpacing
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            maximumLineCount: 2
            elide: Text.ElideRight

            text:  model.applicationName

            //FIXME: export smallestReadableFont
            font.pointSize: theme.defaultFont.pointSize * 0.9
            color: "white"//model.applicationLocation == ApplicationListModel.Desktop ? "white" : theme.textColor
        }
    }
}

