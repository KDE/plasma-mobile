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

import QtQuick 2.0
import QtQuick.Controls 1.2 as Controls
import QtQuick.Layouts 1.3
import org.kde.plasma.mobilecomponents 0.2

Page {
    Layout.fillWidth: true
    contextualActions: [
        Controls.Action {
            text:"Action for buttons"
            iconName: "bookmarks"
            onTriggered: print("Action 1 clicked")
        },
        Controls.Action {
            text:"Action 2"
            iconName: "folder"
        }
    ]
    MouseArea {
        anchors.fill: parent
        onClicked: actionButton.toggleVisibility();
    }
    Heading {
        text: "Buttons"
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: Units.smallSpacing
        }
    }
    ColumnLayout {
        anchors.centerIn: parent
        spacing: Units.smallSpacing

        Controls.Button {
            text: "Button"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: print("clicked")
        }
        Controls.Button {
            text: "Disabled Button"
            enabled: false
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: print("clicked")
        }
        Controls.ToolButton {
            text: "Tool Button"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: print("clicked")
        }
        Controls.ToolButton {
            text: "Tool Button non flat"
            property bool flat: false
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: print("clicked")
        }
        Controls.ToolButton {
            iconName: "go-previous"
            property bool flat: false
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: print("clicked")
        }
        Row {
            spacing: 0
            anchors.horizontalCenter: parent.horizontalCenter
            Controls.ToolButton {
                iconName: "edit-cut"
                property bool flat: false
                onClicked: print("clicked")
            }
            Controls.ToolButton {
                iconName: "edit-copy"
                property bool flat: false
                onClicked: print("clicked")
            }
            Controls.ToolButton {
                iconName: "edit-paste"
                property bool flat: false
                onClicked: print("clicked")
            }
        }
    }
}
