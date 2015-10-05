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
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

SimpleApp {
    id: root
    width: 500
    height: 800

    contextualActions: //ListModel {ListElement{text:"AAA"} ListElement{text:"cccc"}}
    [Action {text:"AAA"; onTriggered: print("AAA")}, Action {text:"bbb"}]
    contextualActionsTitle: "Actions"

    globalDrawer: PlasmaExtras.ScrollArea {
        implicitWidth: units.gridUnit * 12
        ListView {
            id: optionMenu
            model: 5
            //verticalLayoutDirection: ListView.BottomToTop

            header: Row {
                anchors {
                    left: parent.left
                    margins: units.largeSpacing
                }
                PlasmaCore.IconItem {
                    height: parent.height
                    width: height
                    source: "akregator"
                }
                PlasmaExtras.Heading {
                    level: 1
                    text: "Akregator"
                }
            }
            delegate: PlasmaComponents.ListItem {
                PlasmaComponents.Label {
                    anchors {
                        left: parent.left
                        margins: units.largeSpacing
                    }
                    enabled: true
                    text: "Option " + modelData
                }
            }
        }
    }


    //Main app content
    PlasmaExtras.ScrollArea {
        ListView {
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
