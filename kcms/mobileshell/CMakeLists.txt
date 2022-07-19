# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

cmake_minimum_required(VERSION 3.0)

project(mobileshellkcm)

set(QT_MIN_VERSION "5.15.0")
set(KF5_MIN_VERSION "5.90.0")

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDEFrameworkCompilerSettings NO_POLICY_SCOPE)

find_package(Qt${QT_MAJOR_VERSION} ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    Quick
    Svg
)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
    I18n
    KCMUtils
    Declarative
    Config
)

kcoreaddons_add_plugin(kcm_mobileshell SOURCES kcm.cpp INSTALL_NAMESPACE "plasma/kcms/systemsettings")

target_link_libraries(kcm_mobileshell
    Qt::Core
    KF5::CoreAddons
    KF5::KCMUtils
    KF5::I18n
    KF5::QuickAddons
)

kcmutils_generate_desktop_file(kcm_mobileshell)

kpackage_install_package(package kcm_mobileshell kcms) # Install our QML kpackage.
