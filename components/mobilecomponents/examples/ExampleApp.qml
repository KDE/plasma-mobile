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
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaApp {
    id: root
    width: 500
    height: 800

    contextualActions: //ListModel {ListElement{text:"AAA"} ListElement{text:"cccc"}}
    [Action {text:"AAA"; iconName: "document-decrypt"; onTriggered: print("AAA")}, Action {text:"bbb"; iconName: "document-share"}]
    contextualDrawerTitle: "Actions"

    toolbarActions:  [Action {iconName:"konqueror"; onTriggered: print("AAA")}, Action {iconName:"go-home"}]

   /* toolbarDelegate: PlasmaComponents.TextField {
        Layout.fillWidth: true
    }*/

    mainFlickable: mainListView

    globalActions: [
       ActionGroup {
           text: "View"
           iconName: "view-list-icons"
           Action {
                text: "action 1"
           }
           Action {
                text: "action 2"
           }
           Action {
                text: "action 3"
           }
       },
       ActionGroup {
           text: "Sync"
           iconName: "folder-sync"
           Action {
                text: "action 4"
           }
           Action {
                text: "action 5"
           }
       },
       Action {
           text: "Settings"
           iconName: "configure"
       }
    ]

    globalDrawer: GlobalDrawerContents {
        Rectangle {
            Layout.minimumHeight: 200
            Layout.minimumWidth: 200
        }
        Rectangle {
            color: "red"
            Layout.minimumHeight: 200
            Layout.minimumWidth: 200
        }
    }


    //Main app content
    PlasmaExtras.ScrollArea {
        ListView {
            id: mainListView
            model: 30
            delegate: PlasmaComponents.ListItem {
                PlasmaComponents.Label {
                    enabled: true
                    text: "Item " + modelData
                }
            }
        }
    }
}
