/*
 *   Copyright 2014 Antonis Tsiapaliokas <antonis.tsiapaliokas@Kde.org>
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
    id: root
    visible: false

    signal accepted(string newActivityName)
    signal dismissed

    Behavior on visible {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }
    PlasmaCore.FrameSvgItem {
        id: frame
        imagePath: "widgets/background"
        scale: 1
        opacity: 0.5
        transformOrigin: Item.BottomLeft
        width: theme.mSize(theme.defaultFont).width*24
        height: parent.height+5+margins.top+margins.bottom


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
            PlasmaComponents.TextField {
                id: newActivityTextEdit
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
                    text: i18n("Create")
                    enabled: newActivityTextEdit.text.length > 0
                    width: theme.mSize(theme.defaultFont).width*8
                    onClicked: {
                        root.visible = false
                        root.accepted(newActivityTextEdit.text)
                    }
                }

                PlasmaComponents.Button {
                    id: noButton
                    text: i18n("Cancel")
                    width: theme.mSize(theme.defaultFont).width*8
                    onClicked: {
                        root.visible = false
                        root.dismissed()
                    }
                }
            }
        }
    }
}
