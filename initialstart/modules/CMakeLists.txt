# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

plasma_install_package(finished org.kde.plasma.mobileinitialstart.finished mobileinitialstart)
add_subdirectory(cellular)
add_subdirectory(prepare)
add_subdirectory(time)
add_subdirectory(wifi)
