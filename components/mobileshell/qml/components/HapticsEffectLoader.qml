// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

Loader {
    source: "qrc:/org/kde/plasma/private/mobileshell/qml/components/HapticsEffectWrapper.qml"
    property bool valid: item !== null
    
    function buttonVibrate() {
        if (valid && MobileShell.MobileShellSettings.vibrationsEnabled) {
            item.intensity = MobileShell.MobileShellSettings.vibrationIntensity;
            item.duration = MobileShell.MobileShellSettings.vibrationDuration;
            item.start();
        }
    }
}

