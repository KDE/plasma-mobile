# SPDX-FileCopyrightText: 2014-2020 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2017-2021 Bhushan Shah <bshah@kde.org>
# SPDX-FileCopyrightText: 2019-2021 Nicolas Fella <nicolas.fella@kde.org>
# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

cmake_minimum_required(VERSION 3.16)

project(plasma-mobile)
set(PROJECT_VERSION "5.27.80")
set(PROJECT_VERSION_MAJOR 5)

set(QT_MIN_VERSION "6.4.0")
set(KF6_MIN_VERSION "5.240.0")
set(KDE_COMPILERSETTINGS_LEVEL "5.82")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

set(KF_IGNORE_PLATFORM_CHECK ON CACHE BOOL "Don't check platform that is being built on")

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMOptionalAddSubdirectory)
include(ECMInstallIcons)
include(ECMSetupVersion)
include(ECMMarkNonGuiExecutable)
include(ECMGenerateHeaders)
include(ECMQMLModules)
include(ECMGenerateQmlTypes)
include(ECMFindQmlModule)
include(GenerateExportHeader)
include(KDEGitCommitHooks)
include(KDEClangFormat)
include(FeatureSummary)

add_definitions(-DQT_NO_URL_CAST_FROM_STRING)

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX PLASMA_MOBILE
    VERSION_HEADER ${CMAKE_CURRENT_BINARY_DIR}/version.h
)

find_package(Qt${QT_MAJOR_VERSION} ${QT_MIN_VERSION} CONFIG REQUIRED
    Core
    Qml
    Quick
)

find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS
    I18n
    KIO
    Config
    DBusAddons
    Plasma
    PlasmaQuick
    Service
    Notifications
    Wayland
    ModemManagerQt
    NetworkManagerQt
    KCMUtils
    Declarative
)
find_package(KF5KirigamiAddons 0.6 REQUIRED)

find_package(LibKWorkspace CONFIG REQUIRED)

find_package(KWinDBusInterface)
set_package_properties(KWinDBusInterface PROPERTIES DESCRIPTION "KWin DBus interface"
    TYPE REQUIRED
    PURPOSE "Needed for virtual keyboard toggle button"
)

include(CheckIncludeFiles)

ecm_find_qmlmodule(org.kde.pipewire 0.1)

plasma_install_package(look-and-feel org.kde.breeze.mobile look-and-feel lookandfeel)
plasma_install_package(shell org.kde.plasma.phoneshell shells)

install(FILES plasma_phone_components.notifyrc DESTINATION ${KDE_INSTALL_KNOTIFYRCDIR})

add_subdirectory(bin)
add_subdirectory(containments)
add_subdirectory(components)
add_subdirectory(quicksettings)
add_subdirectory(kcms)
add_subdirectory(kded)

find_program(PlasmaOpenSettings plasma-open-settings)
set_package_properties(PlasmaOpenSettings PROPERTIES
                                          URL https://invent.kde.org/plasma/kde-cli-tools/
                                          DESCRIPTION "Opens KCMs properly"
                                          TYPE RUNTIME
                                          PURPOSE "Used on the top panel")

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

# add clang-format target for all our real source files
file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)

ki18n_install(po)
