/*
 *   Copycontext 2015 Marco Martin <mart@kde.org>
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

import QtQuick 2.1
import QtQuick.Controls 1.3
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.kquickcontrolsaddons 2.0

ApplicationWindow {
    id: root

    default property alias page: main.data
    property alias globalDrawer: global.drawer
    property alias contextDrawer: context.drawer

    property alias globalDrawerOpen: global.open
    property alias contextDrawerOpen: context.open

    //This can be any type of object that a ListView can accept as model. It expects items compatible with either QAction or QQC Action
    property alias contextualActions: internalActions.data
    property string contextualActionsTitle

    statusBar: PlasmaComponents.ToolBar {
        tools: PlasmaComponents.ToolBarLayout {
            //TODO: those buttons should support drag to open the menus as well
            PlasmaComponents.ToolButton {
                id: configureButton
                iconSource: "configure"
                checkable: true
                onCheckedChanged: {
                    globalDrawerOpen = checked
                    if (checked) {
                        contextDrawerOpen = false;
                    }
                }
            }
            PlasmaComponents.ToolButton {
                id: menuButton
                iconSource: "applications-other"
                checkable: true
                onCheckedChanged: {
                    contextDrawerOpen = checked
                    if (checked) {
                        globalDrawerOpen = false;
                    }
                }
            }
        }
    }

    onGlobalDrawerOpenChanged: {
        configureButton.checked = globalDrawerOpen;
    }
    onContextDrawerOpenChanged: {
        menuButton.checked = contextDrawerOpen;
    }

    Item {
        id: internalActions
    }

    Item {
        id: main
        anchors.fill: parent
        onChildrenChanged: main.children[0].anchors.fill = main
    }
    MobileComponents.OverlayDrawer {
        id: global
        inverse: true
    }
    MobileComponents.OverlayDrawer {
        id: context
        visible: true
        drawer: ContextDrawerContents {
            actions: root.contextualActions
            title: root.contextualActionsTitle
        }
    }
}
