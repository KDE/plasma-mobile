/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
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
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.runnermodel 0.1 as RunnerModels

PlasmaComponents.Sheet {
    id: widgetsExplorer
    objectName: "widgetsExplorer"
    title: i18n("Add Items")
    acceptButtonText: i18n("Add Items")
    rejectButtonText: i18n("Cancel")

    signal addAppletRequested(string plugin)
    signal closeRequested

    function addItems()
    {
        for (var i = 0; i < selectedModel.count; ++i) {
            var item = selectedModel.get(i)
            widgetsExplorer.addAppletRequested(item.pluginName)
        }

    }

    //used only toexplicitly close the keyboard
    TextInput { id: inputPanelController; width:0; height:0}

    Binding {
        target: acceptButton
        property: "enabled"
        value: selectedModel.count > 0
    }

    onAccepted: {
        widgetsExplorer.addItems()
    }
    onStatusChanged: {
        if (status == PlasmaComponents.DialogStatus.Open) {
            searchField.forceActiveFocus()
        } else if (status == PlasmaComponents.DialogStatus.Closed) {
            closeRequested()
            inputPanelController.closeSoftwareInputPanel()
        }
    }

    ListModel {
        id: selectedModel
    }

    Timer {
        running: true
        interval: 100
        onTriggered: open()
    }

    content: [
        MobileComponents.ViewSearch {
            id: searchField

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
        },
        WidgetExplorer {
            anchors {
                left: parent.left
                right: parent.right
                top: searchField.bottom
                bottom: parent.bottom
            }
        }
    ]
}
