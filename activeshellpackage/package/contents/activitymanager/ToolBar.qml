/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents

PlasmaCore.FrameSvgItem {
    id: actionsToolBar

    property alias query: filterField.text

    Connections {
        target: activitySwitcher
        onStateChanged: {
            if (activitySwitcher.state != "AcceptingInput") {
                filterField.opacity = 0
                filterField.text = ""
                query = ""
//                fakeTextInput.closeSoftwareInputPanel()
                filterButton.checked = false
            }
        }
    }

    imagePath: "dialogs/background"
    enabledBorders: "LeftBorder|TopBorder|BottomBorder"
    width: childrenRect.width+margins.left+margins.right+60
    height: childrenRect.height+margins.top+margins.bottom
    anchors {
        top: parent.top
        right: parent.right
    }
    Row {
        x: actionsToolBar.margins.left+30
        y: actionsToolBar.margins.top
        spacing: 40
        MobileComponents.ActionButton {
            svg: iconsSvg
            elementId: "add"

            onClicked: {
                activitySwitcher.state = "Passive"
                activitySwitcher.newActivityRequested()
            }
        }
        Item {
            width: filterField.opacity>0.5?filterField.width+iconSize/2:iconSize
            height: filterButton.height

            Item {
                clip: true
                anchors {
                    fill: parent
                    rightMargin: iconSize/2
                }
                PlasmaComponents.TextField {
                    id: filterField
                    opacity: 0
                    width: theme.mSize(theme.defaultFont).width*20
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
            MobileComponents.ActionButton {
                id: filterButton
                svg: iconsSvg
                elementId: "filter"
                anchors.right: parent.right
                toggle: true

                onClicked: {
                    if (filterField.opacity==1) {
                        filterField.opacity = 0
                        activitySwitcher.state = "Normal"
                        filterField.text = ""
                        query = ""
                        //fakeTextInput.closeSoftwareInputPanel()
                    } else {
                        filterField.opacity = 1
//                        filterField.forceActiveFocus()
                        activitySwitcher.state = "AcceptingInput"
                        //fakeTextInput.openSoftwareInputPanel()
                    }
                    //TODO: should get focus
                }
            }
            //FIXME: this dummy text edit is used only to close the on screen keyboard, need QtComponents
            TextInput{
                id: fakeTextInput
                width: 0
                height: 0
            }
        }
    }
}
