# SPDX-FileCopyrightText: 2014-2020 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2017-2021 Bhushan Shah <bshah@kde.org>
# SPDX-FileCopyrightText: 2019-2021 Nicolas Fella <nicolas.fella@kde.org>
# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

cmake_minimum_required(VERSION 3.16)

project(plasma-mobile)
set(PROJECT_VERSION "6.1.80")
set(PROJECT_VERSION_MAJOR 6)

set(PROJECT_DEP_VERSION "6.1.80")
set(QT_MIN_VERSION "6.7.0")
set(KF6_MIN_VERSION "6.2.0")
set(KDE_COMPILERSETTINGS_LEVEL "5.82")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(INSTALL_SYSTEMD_SERVICE "Install a systemd service file to start the session" OFF)

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
include(ECMFindQmlModule)
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

find_package(Qt6 ${QT_MIN_VERSION} CONFIG REQUIRED
    Core
    Qml
    Quick
    Gui
    Sensors
)

find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS
    I18n
    GlobalAccel
    KIO
    Config
    DBusAddons
    ItemModels
    Service
    Notifications
    ModemManagerQt
    NetworkManagerQt
    KCMUtils
    Package
    JobWidgets
)

find_package(Plasma CONFIG REQUIRED)
find_package(PlasmaQuick CONFIG REQUIRED)
find_package(PlasmaActivities CONFIG REQUIRED)
find_package(KF6Screen CONFIG REQUIRED)
find_package(KWayland CONFIG REQUIRED)

find_package(PkgConfig REQUIRED)

find_package(QCoro6 REQUIRED COMPONENTS DBus)
qcoro_enable_coroutines()
kde_enable_exceptions()

pkg_check_modules(GOBJECT gobject-2.0 REQUIRED IMPORTED_TARGET)
pkg_check_modules(GIO gio-2.0 REQUIRED IMPORTED_TARGET)

find_package(KF6KirigamiAddons 0.6 REQUIRED)
find_package(epoxy REQUIRED)
find_package(XCB REQUIRED COMPONENTS XCB)
find_package(KWin ${PROJECT_DEP_VERSION} REQUIRED COMPONENTS
    kwin
)

find_package(LibKWorkspace CONFIG REQUIRED)
find_package(Libudev REQUIRED)

find_package(KWinDBusInterface)
set_package_properties(KWinDBusInterface PROPERTIES DESCRIPTION "KWin DBus interface"
    TYPE REQUIRED
    PURPOSE "Needed for virtual keyboard toggle button"
)

include(CheckIncludeFiles)

ecm_find_qmlmodule(org.kde.pipewire 0.1)

plasma_install_package(lookandfeel org.kde.breeze.mobile look-and-feel lookandfeel)
plasma_install_package(shell org.kde.plasma.mobileshell shells)

add_subdirectory(bin)
add_subdirectory(components)
add_subdirectory(containments)
add_subdirectory(quicksettings)
add_subdirectory(kcms)
add_subdirectory(kded)
add_subdirectory(kwin)
add_subdirectory(envmanager)
add_subdirectory(initialstart)
add_subdirectory(layout-templates)
if(BUILD_TESTING)
    add_subdirectory(tests)
endif()

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

if (INSTALL_SYSTEMD_SERVICE)
    install(FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/plasma-mobile.service
        DESTINATION ${KDE_INSTALL_SYSTEMDUNITDIR}
    )
endif()
