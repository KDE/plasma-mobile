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
import QtQuick.Controls 1.4 as Controls
import QtQuick.Layouts 1.3
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

ApplicationWindow {
    id: root
    width: 500
    height: 800

    GlobalDrawer {
        title: "Akregator"
        titleIcon: "akregator"

        actions: [
            ActionGroup {
                text: "View"
                iconName: "view-list-icons"
                Controls.Action {
                        text: "action 1"
                }
                Controls.Action {
                        text: "action 2"
                }
                Controls.Action {
                        text: "action 3"
                }
            },
            ActionGroup {
                text: "Sync"
                iconName: "folder-sync"
                Controls.Action {
                        text: "action 4"
                }
                Controls.Action {
                        text: "action 5"
                }
            },
            Controls.Action {
                text: "Settings"
                iconName: "configure"
            }
            ]
        content: Rectangle {
            Layout.minimumHeight: 200
            Layout.minimumWidth: 200
        }
    }
    ContextDrawer {
        actions: //ListModel {ListElement{text:"AAA"} ListElement{text:"cccc"}}
            [
            Controls.Action {
                text:"AAA"
                iconName: "document-decrypt"
                onTriggered: print("AAA")
            },
            Controls.Action {
                text:"bbb"
                iconName: "document-share"
            }]
        title: "Actions"
    }

    initialPage: mainPageComponent

    //Main app content
    Component {
        id: mainPageComponent
        Page {
            anchors.fill:parent
            actions:  [Controls.Action {iconName:"konqueror"; onTriggered: print("AAA")}, Controls.Action {iconName:"go-home"}]
            PlasmaExtras.ScrollArea {
                anchors.fill:parent
                ListView {
                    id: mainListView
                    model: 30
                    delegate: PlasmaComponents.ListItem {
                        enabled: true
                        PlasmaComponents.Label {
                            enabled: true
                            text: "Item " + modelData
                        }
                        onClicked: root.pageStack.push(mainPageComponent)
                    }
                }
            }
        }
    }
}
