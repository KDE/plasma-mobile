/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls
import QtGraphicalEffects 1.6

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.phone.homescreen 1.0


PC3.RoundButton {
    id: removeButton
    anchors {
        right: parent.right
        top: parent.top
    }
    visible: false
    icon.name: "delete"
    onClicked: delegateDestructionAnim.restart()

    function show() {
        scale = 0;
        visible = true;
        removeButtonScaleAnim.from = 0;
        removeButtonScaleAnim.to = 1;
        removeButtonAnim.running = true;
    }
    function hide() {
        if (!visible) {
            return;
        }
        removeButtonScaleAnim.from = 1;
        removeButtonScaleAnim.to = 0;
        removeButtonAnim.running = true;
    }
    SequentialAnimation {
        id: delegateDestructionAnim
        NumberAnimation {
            target: delegate
            property: "scale"
            from: 1
            to: 0
            duration: PlasmaCore.Units.longDuration
            easing.type: Easing.InOutQuad
        }
        ScriptAction {
            script: {
                appletsLayout.releaseSpace(delegate);
                plasmoid.nativeInterface.applicationListModel.removeFavorite(index);
            }
        }
    }
    SequentialAnimation {
        id: removeButtonAnim
        NumberAnimation {
            id: removeButtonScaleAnim
            target: removeButton
            property: "scale"
            duration: PlasmaCore.Units.longDuration
            easing.type: Easing.InOutQuad
        }
        ScriptAction {
            script: {
                if (removeButton.scale === 0) {
                    removeButton.visible = false;
                }
            }
        }
    }
}
