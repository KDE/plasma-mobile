/*
 * SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.workspace.keyboardlayout 1.0 as Keyboards

QS.QuickSetting {
    text: i18n("Virtual Keyboard")
    icon: "input-keyboard-virtual"
    status: !Keyboards.KWinVirtualKeyboard.available ? i18n("Tap to open settings")
                                                     : (keyboardEnabled ? i18n("On") : i18n("Off"))
    enabled: keyboardEnabled && Keyboards.KWinVirtualKeyboard.available
    settingsCommand: "plasma-open-settings kcm_mobile_onscreenkeyboard"

    property bool keyboardEnabled: Keyboards.KWinVirtualKeyboard.mode !== Keyboards.KWinVirtualKeyboard.Never

    function toggle() {
        if (!Keyboards.KWinVirtualKeyboard.available) {
            // select a keyboard in the settings (none is likely set)
            MobileShell.ShellUtil.executeCommand("plasma-open-settings kcm_virtualkeyboard");
        } else if (keyboardEnabled) {
            Keyboards.KWinVirtualKeyboard.mode = Keyboards.KWinVirtualKeyboard.Never;
        } else {
            Keyboards.KWinVirtualKeyboard.mode = Keyboards.KWinVirtualKeyboard.AnyInput;
        }
    }
}


