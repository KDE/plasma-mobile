# SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

add_executable(waydroidhelper)
target_sources(waydroidhelper PRIVATE waydroidhelper.cpp)

target_link_libraries(waydroidhelper
    Qt6::Core
    KF6::AuthCore
    KF6::CoreAddons
)

install(TARGETS waydroidhelper DESTINATION ${KAUTH_HELPER_INSTALL_DIR})

find_package(KF6Auth NO_MODULE)

kauth_install_helper_files(waydroidhelper org.kde.plasma.mobileshell.waydroidhelper root)
kauth_install_actions(org.kde.plasma.mobileshell.waydroidhelper waydroidhelper.actions)
