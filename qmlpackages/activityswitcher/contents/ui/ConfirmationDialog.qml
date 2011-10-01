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

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets

PlasmaCore.FrameSvgItem {
    id: confirmationDialog
    imagePath: "dialogs/background"
    scale: 0
    width: 200
    height: childrenRect.height+5+margins.top+margins.bottom
    property alias question: confirmationText.text
    signal accepted
    signal dismissed

    Behavior on scale {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }

    Column {
        spacing: 8
        anchors {
            left: parent.left
            top: parent.top
            right:parent.right
            leftMargin: confirmationDialog.margins.left
            rightMargin: confirmationDialog.margins.right
            topMargin: confirmationDialog.margins.top
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
            PlasmaWidgets.PushButton {
                id: yesButton
                text: i18n("Yes")
                onClicked: {
                    confirmationDialog.accepted()
                }
            }

            PlasmaWidgets.PushButton {
                id: noButton
                text: i18n("No")
                onClicked: {
                    confirmationDialog.scale = 0
                    confirmationDialog.dismissed()
                }
            }
        }
    }
}