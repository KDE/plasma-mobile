# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

cmake_minimum_required(VERSION 3.0)

project(mobileshellkcm)

set(QT_MIN_VERSION "5.15.0")
set(KF5_MIN_VERSION "5.86.0")

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDEFrameworkCompilerSettings NO_POLICY_SCOPE)

find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    Quick
    Svg
)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
    I18n
    KCMUtils
    Declarative
    Config
)

set(mobileshellsettings_SRCS
    kcm.cpp
)

add_library(kcm_mobileshell MODULE ${mobileshellsettings_SRCS})

target_link_libraries(kcm_mobileshell
    Qt5::Core
    KF5::CoreAddons
    KF5::KCMUtils
    KF5::I18n
    KF5::QuickAddons
)

kcoreaddons_desktop_to_json(kcm_mobileshell "package/metadata.desktop")

install(TARGETS kcm_mobileshell DESTINATION ${KDE_INSTALL_PLUGINDIR}/kcms)
install(FILES package/metadata.desktop RENAME kcm_mobileshell.desktop DESTINATION ${KDE_INSTALL_KSERVICES5DIR}) # Install the desktop file


kpackage_install_package(package kcm_mobileshell kcms) # Install our QML kpackage.
