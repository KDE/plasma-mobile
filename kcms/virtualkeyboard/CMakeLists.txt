# SPDX-FileCopyrightText: 2020 Bhushan Shah <bshah@kde.org>
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

set(MALIIT_KEYBOARD_LANGUAGES_DIR "${CMAKE_INSTALL_FULL_LIBDIR}/maliit/keyboard2/languages" CACHE PATH "Directory containing maliit-keyboard data")

add_definitions(-DQT_NO_KEYWORDS)

kcmutils_add_qml_kcm(kcm_mobile_onscreenkeyboard)

target_sources(kcm_mobile_onscreenkeyboard PRIVATE
    languagemodel.cpp
    gsettingsitem.cpp
    virtualkeyboard.cpp
)
target_compile_definitions(kcm_mobile_onscreenkeyboard PRIVATE "MALIIT_KEYBOARD_LANGUAGES_DIR=\"${MALIIT_KEYBOARD_LANGUAGES_DIR}\"")

target_link_libraries(kcm_mobile_onscreenkeyboard PRIVATE
    Qt::Core
    KF6::CoreAddons
    KF6::I18n
    KF6::KCMUtilsQuick
    KF6::ConfigCore
    PkgConfig::GIO
    PkgConfig::GOBJECT
)
