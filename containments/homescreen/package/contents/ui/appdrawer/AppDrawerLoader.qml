/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Loader {
    id: root
    
    required property var homeScreenState
    
    property real topPadding: 0
    property real bottomPadding: 0
    property real leftPadding: 0
    property real rightPadding: 0
    
    property string appDrawerType: "gridview" // gridview/listview
    
    readonly property real headerHeight: Math.round(PlasmaCore.Units.gridUnit * 3)
    
    sourceComponent: appDrawerType === "gridview" ? gridViewDrawer : listViewDrawer
    
    Component {
        id: headerComponent
        
        AppDrawerHeader {
            onSwitchToListRequested: {
                if (root.appDrawerType !== "listview") {
                    root.appDrawerType = "listview";
                }
            }
            
            onSwitchToGridRequested: {
                if (root.appDrawerType !== "gridview") {
                    root.appDrawerType = "gridview";
                }
            }
        }
    }
    
    Component {
        id: listViewDrawer
        ListViewAppDrawer {
            anchors.fill: parent
            topPadding: root.topPadding
            bottomPadding: root.bottomPadding
            leftPadding: root.leftPadding
            rightPadding: root.rightPadding
            
            homeScreenState: root.homeScreenState
            headerItem: Loader { sourceComponent: headerComponent }
            headerHeight: root.headerHeight
        }
    }
    
    Component {
        id: gridViewDrawer
        GridViewAppDrawer {
            anchors.fill: parent
            topPadding: root.topPadding
            bottomPadding: root.bottomPadding
            leftPadding: root.leftPadding
            rightPadding: root.rightPadding
            
            homeScreenState: root.homeScreenState
            headerItem: Loader { sourceComponent: headerComponent }
            headerHeight: root.headerHeight
        }
    }
}
