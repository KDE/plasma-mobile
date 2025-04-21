# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

plasma_install_package(airplanemode org.kde.plasma.quicksetting.airplanemode quicksettings)
plasma_install_package(audio org.kde.plasma.quicksetting.audio quicksettings)
plasma_install_package(battery org.kde.plasma.quicksetting.battery quicksettings)
plasma_install_package(bluetooth org.kde.plasma.quicksetting.bluetooth quicksettings)
plasma_install_package(caffeine org.kde.plasma.quicksetting.caffeine quicksettings)
plasma_install_package(docked org.kde.plasma.quicksetting.docked quicksettings)
plasma_install_package(donotdisturb org.kde.plasma.quicksetting.donotdisturb quicksettings)
plasma_install_package(autohidepanels org.kde.plasma.quicksetting.autohidepanels quicksettings)
plasma_install_package(keyboardtoggle org.kde.plasma.quicksetting.keyboardtoggle quicksettings)
plasma_install_package(mobiledata org.kde.plasma.quicksetting.mobiledata quicksettings)
plasma_install_package(settingsapp org.kde.plasma.quicksetting.settingsapp quicksettings)
plasma_install_package(wifi org.kde.plasma.quicksetting.wifi quicksettings)
plasma_install_package(hotspot org.kde.plasma.quicksetting.hotspot quicksettings)
add_subdirectory(flashlight)
add_subdirectory(nightcolor)
add_subdirectory(powermenu)
# TODO: Disable screen recording quick setting, as it does not work properly
add_subdirectory(record)
add_subdirectory(screenshot)
add_subdirectory(screenrotation)
