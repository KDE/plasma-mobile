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

MobileComponents.ApplicationWindow {
    id: root
    width: 500
    height: 800

    MobileComponents.GlobalDrawer {
        title: "Widget gallery"
        titleIcon: "applications-graphics"

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
                text: "Settings"
                iconName: "configure"
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
    MobileComponents.ContextDrawer {
        actions:
            [
            Controls.Action {
                text:"Action 1"
                iconName: "document-decrypt"
                onTriggered: print("Action 1 clicked")
            },
            Controls.Action {
                text:"Action 2"
                iconName: "document-share"
            }]
        title: "Actions"
    }

    initialPage: mainPageComponent

    //Main app content
    Component {
        id: mainPageComponent
        MainPage {}
    }
}
