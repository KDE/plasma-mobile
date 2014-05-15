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

Item {
    id: confirmationDialog
    scale: 0
    width: childrenRect.width
    height: childrenRect.height
    //x: deleteButton.x + deleteButton.width / 2 - deleteButtonParent.confirmationDialog.width * (1 / delegate.scale) / 2

    property alias question: confirmationText.text
    signal accepted
    signal dismissed

    Behavior on scale {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }
    PlasmaCore.FrameSvgItem {
        id: frame
        imagePath: "dialogs/background"
        scale: 1 / delegate.scale
        transformOrigin: Item.Bottom
        width: theme.mSize(theme.defaultFont).width*12
        height: childrenRect.height+5+margins.top+margins.bottom


        Column {
            spacing: 8
            anchors {
                left: parent.left
                top: parent.top
                right:parent.right
                leftMargin: frame.margins.left
                rightMargin: frame.margins.right
                topMargin: frame.margins.top
            }
            Text {
                id: confirmationText
                wrapMode: Text.Wrap
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }

            Row {
                id: buttons
                spacing: 16
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                PlasmaComponents.Button {
                    id: yesButton
                    text: i18n("Yes")
                    width: theme.mSize(theme.defaultFont).width*8
                    onClicked: {
                        confirmationDialog.scale = 0
                        confirmationDialog.accepted()
                    }
                }

                PlasmaComponents.Button {
                    id: noButton
                    text: i18n("No")
                    width: theme.mSize(theme.defaultFont).width*8
                    onClicked: {
                        confirmationDialog.scale = 0
                        confirmationDialog.dismissed()
                    }
                }
            }
        }
    }
}
