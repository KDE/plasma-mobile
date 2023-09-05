/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls
import Qt5Compat.GraphicalEffects

import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

MouseArea {
    id: delegate
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
        // launch app
        if (model.applicationRunning) {
            delegate.launch(0, 0, "", model.applicationName, model.applicationStorageId);
        } else {
            delegate.launch(delegate.x + (Kirigami.Units.smallSpacing * 2), delegate.y + (Kirigami.Units.smallSpacing * 2), icon.source, model.applicationName, model.applicationStorageId);
        }
    }
    hoverEnabled: true
    
    Rectangle {
        anchors.fill: parent
        color: delegate.pressed ? Qt.rgba(255, 255, 255, 0.2) : (delegate.containsMouse ? Qt.rgba(255, 255, 255, 0.05) : "transparent")
        Behavior on color { 
            ColorAnimation { duration: Kirigami.Units.shortDuration } 
        }
    }
    
    RowLayout {
        anchors {
            fill: parent
            leftMargin: Kirigami.Units.smallSpacing * 2
            topMargin: Kirigami.Units.smallSpacing
            rightMargin: Kirigami.Units.smallSpacing * 2
            bottomMargin: Kirigami.Units.smallSpacing
        }
        spacing: 0

        Kirigami.Icon {
            id: icon

            Layout.alignment: Qt.AlignLeft
            Layout.minimumWidth: Layout.minimumHeight
            Layout.preferredWidth: Layout.minimumHeight
            Layout.minimumHeight: parent.height
            Layout.preferredHeight: Layout.minimumHeight

            source: model.applicationIcon

            Rectangle {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
                visible: model.applicationRunning
                radius: width
                width: Kirigami.Units.smallSpacing
                height: width
                color: theme.highlightColor
            }
        }

        PlasmaComponents.Label {
            id: label
            visible: text.length > 0

            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            Layout.leftMargin: Kirigami.Units.smallSpacing * 2
            Layout.rightMargin: Kirigami.Units.gridUnit
            maximumLineCount: 1
            elide: Text.ElideRight

            text:  model.applicationName

            font.pointSize: Math.round(theme.defaultFont.pointSize * 1.1)
            color: "white"
        }
    }
}


