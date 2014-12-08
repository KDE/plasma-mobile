/***************************************************************************
 *                                                                         *
 *   Copyright 2011-2014 Sebastian Kügler <sebas@kde.org>                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0
import org.kde.active.settings 2.0 as ActiveSettings

Item {
    id: settingsRoot

    Component {
        id: settingsModuleDelegate
        PlasmaComponents.ListItem {
            id: delegateItem
            height: units.gridUnit * 3
            width: parent ? parent.width : units.gridUnit * 15
            anchors.margins: units.gridUnit
            enabled: true
            //checked: listView.currentIndex == index

            PlasmaCore.IconItem {
                id: iconItem
                width: units.gridUnit * 2
                height: units.gridUnit * 2
                source: iconName

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.rightMargin: 8
            }

            PlasmaExtras.Heading {
                id: textItem
                text: name
                level: 4
                elide: Text.ElideRight
                anchors.bottom: parent.verticalCenter
                anchors.left: iconItem.right
                anchors.right: parent.right
                anchors.leftMargin: units.gridUnit
            }

            PlasmaComponents.Label {
                id: descriptionItem
                text: description
                font.pointSize: theme.defaultFont.pointSize -1
                opacity: 0.6
                elide: Text.ElideRight
                anchors.top: parent.verticalCenter
                anchors.left: textItem.left
                anchors.right: parent.right
            }

            onClicked: {
                loading = true;
                listView.currentIndex = index
                if (settingsItem.module == module) {
                    settingsRoot.state = "module"
                } else {
                    settingsItem.module = module
                }
            }

            onPressAndHold: {
                listView.currentIndex = index
                settingsItem.module = module
            }
        }
    }

    ActiveSettings.SettingsModulesModel {
        id: settingsModulesModel
        onSettingsModulesChanged: {
            // when the modules are loaded, we need to ensure that
            // the list has the correct item loaded
            if (startModule == "" && settingsItem.module == "") {
                listView.currentIndex = -1;
                return;
            }
            var module;
            if (settingsItem.module) {
                module = settingsItem.module
            } else if (typeof(startModule) != "undefined") {
                module = startModule
            }

            if (module) {
                var index = 0;
                var numModules = settingsModules.length
                var i = 0
                while (i < numModules) {
                    if (settingsModules[i].module == module) {
                        listView.currentIndex = i;
                        break
                    }
                    ++i
                }
            }
        }
    }

    ListView {
        id: listView
        //currentIndex: -1
        anchors.fill: parent
        //clip: true
        interactive: contentHeight > height
        spacing: units.gridUnit / 2
        model: settingsModulesModel.settingsModules
        delegate: settingsModuleDelegate

        Connections {
            target: settingsRoot
            onStateChanged: {
                if (settingsRoot.state == "navigation") {
                    listView.currentIndex = -1;
                }
            }
        }
    }
}