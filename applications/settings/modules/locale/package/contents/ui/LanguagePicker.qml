/* Copyright (C) 2012 basysKom GmbH <info@basyskom.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 */

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1
import org.kde.qtextracomponents 0.1

Item {
    id: languagePicker
    objectName: "languagePicker"
    anchors.fill: parent

    signal filterChanged(string filter)

    function focusTextInput()
    {
        focusTimer.running = true
    }

    Timer {
        id: focusTimer
        interval: 100
        onTriggered: {
            langFilter.forceActiveFocus()
        }
    }
    Text {
        id: languageLabel
        color: theme.textColor
        anchors.right: parent.horizontalCenter
        anchors.top: parent.top
        text: i18n("Current Language:")
        anchors.rightMargin: 12
        //opacity: 1
    }

    Text {
        anchors.left: parent.horizontalCenter
        anchors.verticalCenter: languageLabel.verticalCenter
        text: localeSettings.language
    }

    PlasmaComponents.TextField {
        id: langFilter
        width: parent.width
        placeholderText: "Filter..."
        clearButtonShown: true
        //Keys.onTabPressed: tf2.forceActiveFocus();
        anchors {
            //verticalCenter: parent.verticalCenter
            top: languageLabel.bottom
            //topMargin: 32;
            //bottom: parent.bottom
        }
        onTextChanged: {
            console.log("update filter" + text);
            filterModel.filterRegExp = ".*"+text+".*"
        }
    }

    PlasmaCore.SortFilterModel {
        id: filterModel
        sourceModel: localeSettings.languagesModel
        filterRole: "display"
        sortRole: "display"
        sortOrder: "AscendingOrder"
    }

    ListView {
        id: languageList
        currentIndex: -1
        clip: true
        cacheBuffer: 90000
        anchors {
            //verticalCenter: parent.verticalCenter
            top: langFilter.bottom
            topMargin: 8
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        delegate: languageDelegate

        model: filterModel
    }
    PlasmaComponents.SectionScroller {
        id: sectionScroller
        listView: languageList
    }

    Component {
        id: languageDelegate
        PlasmaComponents.ListItem {
            PlasmaComponents.Label {
                text: display
            }
            enabled: true
            checked: localeSettings.language == display
            onClicked: {
                console.log(" save: " + langCode + " (" + display + ")");
                localeSettings.language = langCode
                languagePickerDialog.close()
            }
        }
    }
}
