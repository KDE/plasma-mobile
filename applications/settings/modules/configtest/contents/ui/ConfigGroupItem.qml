// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2012 Sebastian Kügler <mart@kde.org>
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

import QtQuick 2.2
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.active.settings 2.0 as ActiveSettings

ActiveSettings.ConfigGroup {

    id: levelZero
    property int itemHeight: 24
    property int itemMargin: 2
    //width: 200
    height: keyListView.height + groupListView.height + 40
    //anchors.fill: parent
    anchors.leftMargin: itemHeight

    file: "active-settings-configtestrc"
    //group: "LevelZero"

    Rectangle { anchors.fill: parent; color: "white"; border.color: "black"; opacity: 0.4; }
    ListView {
        anchors { top: parent.top; topMargin: 24; left: parent.left; right: parent.right; }
        id: keyListView
        currentIndex: -1
        height: keyList.length * (itemHeight + spacing)
        //height: contentHeight
        interactive: false
        width: parent.width
        clip: true
        spacing: itemMargin
        model: keyList
        delegate: configDelegate
    }

    Component {
        id: configDelegate
        Column {
            height: itemHeight
            width: keyListView.width - 300
            //Text { id: txt; text: "<b>" + modelData + "</b>:   "; anchors.right: parent.horizontalCenter }
            //Text { text: readEntry(modelData, "default value"); anchors.left: parent.horizontalCenter }
            Text { text: "<em>" + modelData + "</em>: " + readEntry(modelData, "default value"); anchors.left: parent.left; height: itemHeight; }
         //newGroupLoader.source = "ConfigGroupItem.qml"; }
        }
    }

    Column {
        anchors { top: keyListView.bottom; /*bottom: parent.bottom;*/ topMargin: itemMargin; left: parent.left; right: parent.right; }
        id: groupListView
        //currentIndex: -1
        height: groupList.length * (itemHeight + spacing)
        //height: contentHeight
        //interactive: false
        width: parent.width
        //clip: true
        //orientation: Qt.Horizontal
        //spacing: itemMargin
        //model: groupList
        //delegate: groupDelegate
    }
    /*
    Component {
        id: groupDelegate
        Item {
            height: 100
            id: delegateItem
            PlasmaComponents.Label {
                width: 300
                height: itemHeight
                //height: groupListView.height
                //checked: levelOne.group == modelData
                text: "<b>" + modelData + "<b> blabla"
                //onClicked: levelOne.group = modelData
            }
            Component.onCompleted: {
                var component = Qt.createComponent("ConfigGroupItem.qml");
                if (component.status == Component.Ready) {
                    print(" ++++++++++ ... Creating new group " + modelData);
                    var cfgItem = component.createObject(groupDelegate);
                    cfgItem.group = modelData;
                    //cftItem.height = 
                    //cfgItem.anchors.fill = parent;
                }
            }
        }
    }
    */
    Component.onCompleted: {
        print(group + "ConfigGroupItem.onCompleted:  " + group);

        for (var i = 0; i < groupList.length; i++){
            //print(" no: " + i + groupList[i]);
            print();
            var modelData = groupList[i];
            var component = Qt.createComponent("ConfigGroupItem.qml");
            if (component.status == Component.Ready) {
                print(" ++++++++++ ... Creating new group [" + group + "][" + modelData + "]");
                var cfgItem = component.createObject(groupListView, { "group": modelData });
            }
        }
        
    }

}
