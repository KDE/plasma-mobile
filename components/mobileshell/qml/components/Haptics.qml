/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

pragma Singleton

QtObject {
    id: root

    function buttonVibrate() {
        if (MobileShell.MobileShellSettings.vibrationsEnabled) {
            if (hapticsEffect.status == Loader.Ready) {
                hapticsEffect.item.intensity = MobileShell.MobileShellSettings.vibrationIntensity;
                hapticsEffect.item.duration = MobileShell.MobileShellSettings.vibrationDuration;
                hapticsEffect.item.start();
            }
        }
    }
    
    Component.onCompleted: {
        hapticsEffect.setSource("HapticsEffectWrapper.qml");
    }
    
    property var hapticsEffect: Loader {}
}
