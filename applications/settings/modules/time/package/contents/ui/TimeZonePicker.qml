// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.active.settings 0.1
import org.kde.qtextracomponents 0.1

Item {
    id: timeZonePicker
    objectName: "timeZonePicker"
    anchors.fill: parent

    signal filterChanged(string filter)

    Text {
        id: timeZoneLabel
        color: theme.textColor
        anchors.right: parent.horizontalCenter
        anchors.top: parent.top
        text: i18n("Timezone:")
        anchors.rightMargin: 12
        //opacity: 1
    }

    Text {
        anchors.left: parent.horizontalCenter
        anchors.verticalCenter: timeZoneLabel.verticalCenter
        text: timeSettings.timeZone
    }

    PlasmaComponents.TextField {
        id: tzFilter
        width: parent.width
        placeholderText: "filter..."
        clearButtonShown: true
        //Keys.onTabPressed: tf2.forceActiveFocus();
        anchors {
            //verticalCenter: parent.verticalCenter
            top: timeZoneLabel.bottom
            //topMargin: 32;
            //bottom: parent.bottom
        }
        onTextChanged: {
            print("update filter" + text);
            //timeSettings.timeZoneFilterChanged(text);
            filterModel.filterRegExp = ".*"+text+".*"

        }
    }

    PlasmaCore.SortFilterModel {
        id: filterModel
        sourceModel: timeSettings.timeZonesModel
        filterRole: "display"
        //filterRegExp: ".*"+tzFilter.text+".*"
        sortRole: "display"
        sortOrder: "AscendingOrder"

//         {
// 
//             f = "s/" + tzFilter.text + "\.*/g"
//             print(" New regex: :" + f);
//             return f
//         }

    }

    ListView {
        id: timeZonesList
        currentIndex: -1
        //height: 500
        width: parent.width
        clip: true
        spacing: 8
        cacheBuffer: 10000
        anchors {
            //verticalCenter: parent.verticalCenter
            top: tzFilter.bottom
            topMargin: spacing
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        section.property: "continent"
        section.criteria: ViewSection.FullString
        section.delegate: PlasmaComponents.ListItem {
            sectionDelegate: true
            PlasmaComponents.Label {
                anchors {
                    top: parent.top; topMargin: 4
                    left: parent.left; leftMargin: 4
                }
                text: section
                horizontalAlignment: Text.AlignLeft
                font { bold: true; }
            }
        }

        model: filterModel
        //model: timeSettings.timeZonesModel

        delegate: timeZoneDelegate
//         highlight: PlasmaCore.FrameSvgItem {
//             id: highlightFrame
//             imagePath: "widgets/viewitem"
//             prefix: "selected+hover"
//         }

    }
    PlasmaComponents.SectionScroller {
        id: sectionScroller
        listView: timeZonesList
    }

    Component {
        id: timeZoneDelegate
        Item {
            id: tzDelegateContainer
            height: 24
            width: timeZonesList.width

            Text {
                id: tzLabel
                anchors.fill: parent
                text: display
                //text: modelData.name
                color: theme.textColor
            }

            MouseArea {
                id: theMouse
                anchors.margins: timeZonesList.spacing / -2 +2
                anchors.fill: tzDelegateContainer
                onPressed: { print("pressed " + index); timeZonesList.currentIndex = index; }
                onClicked: SequentialAnimation {
                    MobileComponents.ActivateAnimation { targetItem: tzDelegateContainer }
                    ScriptAction {
                        script: {
                            print (" save: " + display);
                            timeSettings.saveTimeZone(display);
                            dialog.state = "closed";
                        }
                    }
                }
            }
            //Rectangle { anchors.fill: theMouse; color: "green"; opacity: 0.2; }
        }
    }
    //Rectangle { anchors.fill: timeZonePicker; color: "green"; opacity: 0.1; }
    //Rectangle { anchors.fill: timeZonesList; color: "blue"; opacity: 0.1; p

}