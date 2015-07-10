/*
 * Copyright (C) 2015 Marco Martin <mart@kde.org>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) version 3, or any
 * later version accepted by the membership of KDE e.V. (or its
 * successor approved by the membership of KDE e.V.), which shall
 * act as a proxy defined in Section 6 of version 3 of the license.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.2
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.milou 0.1 as Milou

Rectangle {
    id: editOverlay
    anchors.fill: parent

    color: Qt.rgba(0, 0, 0, 0.8)
    visible: false
    onVisibleChanged: {
        if (visible) {
            opacity = 1;
        }
    }
    opacity: 0
    Behavior on opacity {
        SequentialAnimation {
            OpacityAnimator {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
            ScriptAction {
                script: {
                    if (editOverlay.opacity == 0) {
                        editOverlay.visible = false;
                    }
                }
            }
        }
    }

    MouseArea {
        enabled: listView.visible
        anchors.fill: parent
        preventStealing: true
        onClicked: editOverlay.opacity = 0;
    }
    PlasmaCore.FrameSvgItem {
        id: background
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: editOverlay.height - (plasmoid.availableScreenRect.y + plasmoid.availableScreenRect.height)
        }
        height: buttonsLayout.height + margins.top
        imagePath: "widgets/background"
        enabledBorders: PlasmaCore.FrameSvg.TopBorder
        RowLayout {
            id: buttonsLayout
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: parent.margins.top
            }
            PlasmaComponents.Button {
                Layout.fillWidth: true
                Layout.fillHeight:true
                text: i18n("Wallpaper...")
                onClicked: plasmoid.action("configure").trigger();
            }
            PlasmaComponents.Button {
                Layout.fillWidth: true
                Layout.fillHeight:true
                text: i18n("Add Widgets...")
                onClicked: plasmoid.action("add widgets").trigger();
            }
        }
    }
}

