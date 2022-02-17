# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

plasma_install_package(airplanemode org.kde.plasma.airplanemode quicksettings)
plasma_install_package(caffeine org.kde.plasma.caffeine quicksettings)
plasma_install_package(keyboardtoggle org.kde.plasma.keyboardtoggle quicksettings)
add_subdirectory(nightcolor)
add_subdirectory(powermenu)
