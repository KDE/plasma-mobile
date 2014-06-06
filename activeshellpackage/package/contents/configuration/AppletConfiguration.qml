/*
 *  Copyright 2013 Marco Martin <mart@kde.org>
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

import QtQuick 2.0
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.0 as QtControls
import QtQuick.Layouts 1.0
import org.kde.plasma.configuration 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.activities 0.1 as Activities
import org.kde.plasma.plasmoid 2.0

//TODO: all of this will be done with desktop components
Rectangle {
    id: root

//BEGIN properties
    color: syspal.window
    width: units.gridUnit * 40
    height: units.gridUnit * 30

    onImplicitHeightChanged: main.height = implicitHeight - buttonsRow.height
    property bool isContainment: false
//END properties

//BEGIN model
    property ConfigModel globalConfigModel:  globalAppletConfigModel
//END model

//BEGIN functions
    function saveConfig() {
        if (main.currentItem.saveConfig) {
            main.currentItem.saveConfig()
        } else {
            for (var key in plasmoid.configuration) {
                if (main.currentItem["cfg_"+key] !== undefined) {
                    plasmoid.configuration[key] = main.currentItem["cfg_"+key]
                }
            }
        }
    }

    function saveActivityConfiguration() {
        //change the name of the activity
        if (plasmoid.activityName != activityNameEdit.text) {
            activitiesConfiguration.setActivityName(plasmoid.activity, activityNameEdit.text, function() {})
        }
    }

    function restoreConfig() {
        for (var key in plasmoid.configuration) {
            if (main.currentItem["cfg_"+key] !== undefined) {
                main.currentItem["cfg_"+key] = plasmoid.configuration[key]
            }
        }
    }

    function configurationHasChanged() {
        for (var key in plasmoid.configuration) {
            if (main.currentItem["cfg_"+key] !== undefined) {
                if (main.currentItem["cfg_"+key] != plasmoid.configuration[key]) {
                    return true;
                }
            }
        }
        return false;
    }
//END functions


//BEGIN connections
    Component.onCompleted: {
        main.sourceFile = globalConfigModel.get(0).source
        root.restoreConfig()
//         root.width = mainColumn.implicitWidth
//         root.height = mainColumn.implicitHeight
    }
//END connections

//BEGIN UI components
    SystemPalette {id: syspal}

    Activities.ActivityModel {
        id: activitiesConfiguration

        shownStates: "Running,Stopping"
    }

    Row {
        id: activityConfigurationRow
        spacing: 2
        width: buttonsRow.width
        height: buttonsRow.height
        anchors {
            horizontalCenter: buttonsRow.horizontalCenter
            top: buttonsRow.bottom
            topMargin: 8
        }

        PlasmaComponents.Label {
            id: activityNameLabel
            text: i18n("Name:")
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
        }

        PlasmaComponents.TextField {
            id: activityNameEdit
            height: parent.height * 1.2
            width: parent.width / 1.6
            clearButtonShown: true
            anchors.verticalCenter: parent.verticalCenter
            text: plasmoid.activityName
            Keys.onReturnPressed: {
                accept()
            }
        }
    }

    QtControls.StackView {
        id: main
        property string title: ""
        anchors {
            left: parent.left
            right: parent.right
            top: activityConfigurationRow.bottom
            topMargin: 8
        }
        clip: true
        property string sourceFile
        onSourceFileChanged: {
            print("Source file changed in flickable" + sourceFile);
            replace(Qt.resolvedUrl(sourceFile))
        }
    }

    QtControls.Action {
        id: cancelAction
        onTriggered: configDialog.close();
        shortcut: "Escape"
    }

    QtControls.Action {
        id: acceptAction
        onTriggered: {
            applyAction.trigger();
            configDialog.close();
        }
    }

    QtControls.Action {
        id: applyAction
        onTriggered: {
            root.saveActivityConfiguration();
            if (main.currentItem.saveConfig !== undefined) {
                main.currentItem.saveConfig();
            } else {
                root.saveConfig();
            }
        }
    }

    RowLayout {
        id: buttonsRow
        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        QtControls.Button {
            iconName: "dialog-ok"
            text: i18n("Ok")
            onClicked: acceptAction.trigger()
        }
        QtControls.Button {
            iconName: "dialog-ok-apply"
            text: i18n("Apply")
            onClicked: applyAction.trigger()
        }
        QtControls.Button {
            iconName: "dialog-cancel"
            text: i18n("Cancel")
            onClicked: cancelAction.trigger()
        }
    }
//END UI components
}
