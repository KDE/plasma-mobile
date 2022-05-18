/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
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
                MobileShell.FavoritesModel.removeFavorite(index);
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
