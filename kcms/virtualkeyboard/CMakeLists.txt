# SPDX-FileCopyrightText: 2020 Bhushan Shah <bshah@kde.org>
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

set(MALIIT_KEYBOARD_LANGUAGES_DIR "${CMAKE_INSTALL_FULL_LIBDIR}/maliit/keyboard2/languages" CACHE PATH "Directory containing maliit-keyboard data")

add_definitions(-DQT_NO_KEYWORDS)

set(onscreenkeyboard_SRCS
    languagemodel.cpp
    gsettingsitem.cpp
    virtualkeyboard.cpp
)

kcoreaddons_add_plugin(kcm_mobile_onscreenkeyboard SOURCES ${onscreenkeyboard_SRCS} INSTALL_NAMESPACE "plasma/kcms/systemsettings")

target_compile_definitions(kcm_mobile_onscreenkeyboard PRIVATE "MALIIT_KEYBOARD_LANGUAGES_DIR=\"${MALIIT_KEYBOARD_LANGUAGES_DIR}\"")

target_link_libraries(kcm_mobile_onscreenkeyboard
    Qt::Core
    KF6::CoreAddons
    KF6::I18n
    KF6::KCMUtilsQuick
    KF6::ConfigCore
    PkgConfig::GIO
    PkgConfig::GOBJECT
)

kcmutils_generate_desktop_file(kcm_mobile_onscreenkeyboard)
kpackage_install_package(package kcm_mobile_onscreenkeyboard kcms)
