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
import QtQuick.Layouts 1.2
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents

MobileComponents.ApplicationWindow {
    id: root
    width: 500
    height: 800
    visible: true

    actionButton.onClicked: print("Action button clicked")

    globalDrawer: MobileComponents.GlobalDrawer {
        title: "Widget gallery"
        titleIcon: "applications-graphics"
        bannerImageSource: "banner.jpg"

        actions: [
            MobileComponents.ActionGroup {
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
            MobileComponents.ActionGroup {
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
                text: "Checkable"
                iconName: "view-list-details"
                checkable: true
                checked: false
                onTriggered: {
                    print("Action checked:" + checked)
                }
            },
            Controls.Action {
                text: "Settings"
                iconName: "configure"
                checkable: true
                //Need to do this, otherwise it breaks the bindings
                property bool current: pageStack.lastVisiblePage ? pageStack.lastVisiblePage.objectName == "settingsPage" : false
                onCurrentChanged: {
                    checked = current;
                }
                onTriggered: {
                    pageStack.pop(pageStack.initialPage);
                    pageStack.push(settingsComponent);
                }
            }
            ]

        Controls.CheckBox {
            checked: true
            text: "Option 1"
        }
        Controls.CheckBox {
            text: "Option 2"
        }
        Controls.CheckBox {
            text: "Option 3"
        }
        Controls.Slider {
            Layout.fillWidth: true
            value: 0.5
        }
    }
    contextDrawer: MobileComponents.ContextDrawer {
        id: contextDrawer
    }

    MobileComponents.OverlayDrawer {
        id: sheet
        edge: Qt.BottomEdge
        contentItem: Item {
            implicitWidth: MobileComponents.Units.gridUnit * 8
            implicitHeight: MobileComponents.Units.gridUnit * 8
            ColumnLayout {
                anchors.centerIn: parent
                Controls.Button {
                    text: "Button1"
                }
                Controls.Button {
                    text: "Button2"
                }
            }
        }
    }
    initialPage: mainPageComponent

    Component {
        id: settingsComponent
        MobileComponents.Page {
            objectName: "settingsPage"
            Rectangle {
                anchors.fill: parent
            }
        }
    }

    //Main app content
    Component {
        id: mainPageComponent
        MainPage {}
    }

}
