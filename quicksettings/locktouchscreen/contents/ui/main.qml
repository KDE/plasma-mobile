// SPDX-FileCopyrightText: 2025 Sebastian Kŭgler <sebas@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.state as MobileShellState
import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS

QS.QuickSetting {
    id: lts_root
    text: i18n("Lock Touchscreen")
    icon: "input-touchscreen"
    status: " "
    enabled: true

    property var lts_component: null
    property var lts_object: null

    function toggle() {
        MobileShellState.ShellDBusClient.closeActionDrawer();
        if (lts_object != null) {
            console.log("Already locked."); // FIXME: perhaps unlock?
            return;
        }
        console.log("Locking the touchscreen now... lts_object: " + lts_object);
        if (lts_component) {
            finishCreation();
            return;
        }
        lts_component = Qt.createComponent("LockTouchScreen.qml");
        if (lts_component.status == Component.Ready) {
            finishCreation();
        } else {
            lts_component.statusChanged.connect(finishCreation);
        }
    }

    function finishCreation() {
        if (lts_component.status == Component.Ready) {
            lts_object = lts_component.createObject(lts_root, {});
            if (lts_object == null) {
                // Error Handling
                console.log("Error creating object");
            }
            lts_object.byebye.connect(lockDestroyed);
        } else if (lts_component.status == Component.Error) {
            // Error Handling
            console.log("Error loading component:", lts_component.errorString());
        }
    }

    function lockDestroyed() {
        //console.log("bye bye!");
        lts_object.destroy();
        lts_object = null;
    }
}
