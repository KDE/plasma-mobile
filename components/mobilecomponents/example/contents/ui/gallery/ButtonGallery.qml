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
import QtQuick.Layouts 1.2
import org.kde.plasma.mobilecomponents 0.2

ScrollablePage {
    id: page
    Layout.fillWidth: true
    title: "Buttons"
    contextualActions: [
        Action {
            text:"Action for buttons"
            iconName: "bookmarks"
            onTriggered: print("Action 1 clicked")
        },
        Action {
            text:"Action 2"
            iconName: "folder"
            enabled: false
        }
    ]
    mainAction: Action {
        iconName: sheet.opened ? "dialog-cancel" : "document-edit"
        onTriggered: {
            print("Action button in buttons page clicked");
            if (sheet.opened) {
                sheet.close();
            } else {
                sheet.open();
            }
        }
    }

    //Close the drawer with the back button
    onBackRequested: {
        if (bottomDrawer.opened) {
            event.accepted = true;
            bottomDrawer.close();
        }
    }

    OverlayDrawer {
        id: bottomDrawer
        anchors.fill: parent
        edge: Qt.BottomEdge
        contentItem: Item {
            implicitWidth: Units.gridUnit * 8
            implicitHeight: Units.gridUnit * 8
            ColumnLayout {
                anchors.centerIn: parent
                Controls.Button {
                    text: "Button1"
                    onClicked: print(root)
                }
                Controls.Button {
                    text: "Button2"
                }
            }
        }
    }

    OverlaySheet {
        id: sheet
        ColumnLayout {
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam id risus id augue euismod accumsan. Nunc vestibulum placerat bibendum. Morbi commodo auctor varius. Donec molestie euismod ultrices. Sed facilisis augue nec eros auctor, vitae mattis quam rhoncus. Nam ut erat diam. Curabitur iaculis accumsan magna, eget fermentum massa scelerisque eu. Cras elementum erat non erat euismod accumsan. Vestibulum ac mi sed dui finibus pulvinar. Vivamus dictum, leo sed lobortis porttitor, nisl magna faucibus orci, sit amet euismod arcu elit eget est. Duis et vehicula nibh. In arcu sapien, laoreet sit amet porttitor non, rhoncus vel magna. Suspendisse imperdiet consectetur est nec ornare. Pellentesque bibendum sapien at erat efficitur vehicula. Morbi sed porta nibh. Vestibulum ut urna ut dolor sagittis mattis.

    Morbi dictum, sapien at maximus pulvinar, sapien metus condimentum magna, quis lobortis nisi dui mollis turpis. Aliquam sit amet scelerisque dui. In sit amet tellus placerat, condimentum enim sed, hendrerit quam. Integer dapibus lobortis finibus. Suspendisse faucibus eros vitae ante posuere blandit. Nullam volutpat quam id diam hendrerit aliquam. Donec non sem at diam posuere convallis. Vivamus ut congue quam. Ut dictum fermentum sapien, eu ultricies est ornare ut.

    Nullam fringilla a libero vehicula faucibus. Donec euismod sodales nulla, in vehicula lectus posuere a. Donec nisi nulla, pulvinar eu porttitor vitae, varius eget ante. Nam rutrum eleifend elit, quis facilisis leo sodales vitae. Aenean accumsan a nulla at sagittis. Integer placerat tristique magna, vitae iaculis ante cursus sit amet. Sed facilisis mollis turpis nec tristique. Etiam quis feugiat odio. Vivamus sagittis at purus nec aliquam.

    Morbi neque dolor, elementum ac fermentum ac, auctor ut erat. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vivamus non nibh sit amet quam luctus congue. Donec in eros varius, porta metus sed, sagittis lacus. Mauris dapibus lorem nisi, non eleifend massa tristique egestas. Curabitur nec blandit urna. Mauris rhoncus libero felis, commodo viverra ante consectetur vel. Donec dictum tincidunt orci, quis tristique urna. Quisque egestas, dui ac mollis dictum, purus velit elementum est, at pellentesque erat est fermentum purus. Nulla a quam tellus. Vestibulum a congue ligula. Quisque feugiat nulla et tortor sodales viverra. Maecenas dolor leo, elementum sed urna vel, posuere hendrerit metus. Mauris pellentesque, mi non luctus aliquam, leo nulla varius arcu, vel pulvinar enim enim nec nisl.

    Etiam sapien leo, venenatis eget justo at, pellentesque mollis tellus. Fusce consequat ullamcorper vulputate. Duis tellus nisi, dictum ut augue non, elementum congue ligula. Fusce in vehicula arcu. Nulla facilisi. Quisque a convallis sapien. Aenean pellentesque convallis egestas. Phasellus rhoncus, nulla in tempor maximus, arcu ex venenatis diam, sit amet egestas mi dolor non ante. "
            }
            Controls.Button {
                text: "Close"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: sheet.close()
            }
        }
    }
    ColumnLayout {
        width: page.width
        spacing: Units.smallSpacing

        Controls.Button {
            text: "Open Bottom drawer"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: bottomDrawer.open()
        }
        Controls.Button {
            text: "Open Sheet"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: sheet.open()
        }
        Controls.Button {
            text: "Push another page"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: pageStack.push(Qt.resolvedUrl("ButtonGallery.qml"));
        }
        Controls.Button {
            text: "Toggle Action Button"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: mainAction.visible = !mainAction.visible;
        }
        Controls.Button {
            text: "Toggle Drawer Handles"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                globalDrawer.handleVisible = !globalDrawer.handleVisible
                contextDrawer.handleVisible = !contextDrawer.handleVisible
            }
        }
        Controls.Button {
            text: "Show Passive Notification"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: showPassiveNotification("This is a passive message", 3000);
        }
        Controls.Button {
            text: "Passive Notification Action"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: showPassiveNotification("This is a passive message", "long", "Action", function() {print("Passive notification action clicked")});
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
