/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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

import QtQuick 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.kquickcontrolsaddons 2.0

MobileComponents.SplitDrawer {
    id: resourceBrowser
    objectName: "resourceBrowser"
    property string currentUdi
    anchors {
        fill: parent
        topMargin: toolBar.height
    }

    open: true
    property bool hasItems: balooDataModel.count > 0 || folderModel.count > 0
    onHasItemsChanged: mainLoader.visible = true

    PlasmaExtras.ConditionalLoader {
        id: mainLoader
        when: hasItems
        visible: false
        anchors.fill: parent
        source: Qt.resolvedUrl("BrowserFrame.qml")
        onItemChanged: {
            if (item) {
                resourceBrowser.page = mainLoader
            }
        }
    }

    tools: PlasmaExtras.ConditionalLoader {
        when: hasItems
        height: theme.mSize(theme.defaultFont).height * 1.6
        source: Qt.resolvedUrl("ToolBar.qml")
    }

    drawer: Item {
        id: sidebar
        clip: false

        anchors.fill: parent

        Behavior on visible {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        Connections {
            target: resourceBrowser
            onOpenChanged: {
                sidebar.visible = resourceBrowser.open
            }
        }

        Item {
            anchors.fill: parent
            clip: false
            PlasmaComponents.TabGroup {
                id: sidebarTabGroup
                width: fileBrowserRoot.width/4 - theme.mSize(theme.defaultFont).width * 2
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    bottomMargin: 0
                    //topMargin: toolBar.height
                    leftMargin: theme.mSize(theme.defaultFont).width * 2
                    rightMargin: theme.mSize(theme.defaultFont).width
                }

                CategorySidebar {
                    id: categorySidebar
                }

                PlasmaExtras.ConditionalLoader {
                    id: timelineSidebar

                    when: sidebarTabGroup.currentTab == timelineSidebar
                    source: Qt.resolvedUrl("TimelineSidebar.qml")
                }
                PlasmaExtras.ConditionalLoader {
                    id: tagsSidebar

                    when: sidebarTabGroup.currentTab == tagsSidebar
                    source: Qt.resolvedUrl("TagsBar.qml")
                }
            }
        }
    }
}

