# SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
# SPDX-License-Identifier: BSD-2-Clause

add_executable(flashlighthelper)
target_sources(flashlighthelper PRIVATE flashlighthelper.cpp)

target_link_libraries(flashlighthelper
    Qt6::Core
    KF6::AuthCore
    KF6::CoreAddons
    udev
)

install(TARGETS flashlighthelper DESTINATION ${KAUTH_HELPER_INSTALL_DIR})

find_package(KF6Auth NO_MODULE)

kauth_install_helper_files(flashlighthelper org.kde.plasma.mobileshell.flashlighthelper root)
kauth_install_actions(org.kde.plasma.mobileshell.flashlighthelper flashlighthelper.actions)

ecm_qt_declare_logging_category(flashlighthelper
    HEADER flashlighthelper_debug.h
    IDENTIFIER FLASHLIGHTHELPER
    DEFAULT_SEVERITY Warning
    CATEGORY_NAME org.kde.plasma.mobileshell.flashlighthelper
    DESCRIPTION "Helper for Flashlight for some actions need root access"
)