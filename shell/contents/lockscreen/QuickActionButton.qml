// SPDX-FileCopyrightText: 2025 User8395 <therealuser8395@proton.me>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.quicksetting.flashlight 1.0
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.private.mobileshell.shellsettingsplugin as ShellSettings
import org.kde.kirigami as Kirigami

Button {
    id: root
    property int buttonAction

    visible: buttonAction !== ShellSettings.Settings.None
    highlighted: buttonAction === ShellSettings.Settings.Flashlight ? FlashlightUtil.torchEnabled() : false
    display: Button.IconOnly
    icon.name: {
        switch (buttonAction) {
        case ShellSettings.Settings.Flashlight:
            return "flashlight-on-symbolic"
        case ShellSettings.Settings.Camera:
            return "camera-photo-symbolic"
        }
    }
    text: {
        switch (buttonAction) {
        case ShellSettings.Settings.Flashlight:
            return i18nc("@action:button", "Turn flashlight on");
        case ShellSettings.Settings.Camera:
            return i18nc("@action:button", "Open camera");
        }
    }
    onClicked: {
        switch (buttonAction) {
        case ShellSettings.Settings.Flashlight:
            FlashlightUtil.toggleTorch();
            return;
        case ShellSettings.Settings.Camera:
            MobileShell.ShellUtil.launchApp("org.kde.plasma.camera");
            flickable.goToOpenPosition();
            return;
        }
    }
}