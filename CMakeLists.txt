project(plasma-mobile-browser)

cmake_minimum_required(VERSION 2.8.10.1)

################# Disallow in-source build #################

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
   message(FATAL_ERROR "plasma-mobile-browser requires an out of source build. Please create a separate build directory and run 'cmake path_to_plasma-mobile-browser [options]' there.")
endif()

# Make CPack available to easy generate binary packages
include(CPack)

include(FeatureSummary)

################# set KDE specific information #################

find_package(ECM 0.0.8 REQUIRED NO_MODULE)
find_package(PkgConfig)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings)

find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui WebEngine)

#add_definitions(-DQT_DISABLE_DEPRECATED_BEFORE=0)

if(KDE_PLATFORM_FEATURE_DISABLE_DEPRECATED)
   set(KDE_NO_DEPRECATED TRUE)
   set(CMAKE_AUTOMOC_MOC_OPTIONS "-DKDE_NO_DEPRECATED")
endif()

################# Enable C++11 features for clang and gcc #################

if(UNIX)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++0x")
endif()

################# now find all used packages #################

set (QT_MIN_VERSION "5.4.0")

find_package(KF5Plasma REQUIRED NO_MODULE)
find_package(KF5PlasmaQuick REQUIRED NO_MODULE)
find_package(KF5Declarative REQUIRED NO_MODULE)
find_package(KF5KIO REQUIRED NO_MODULE)
#find_package(KF5Activities REQUIRED NO_MODULE)
find_package(KF5Declarative REQUIRED NO_MODULE)
find_package(PkgConfig)
#########################################################################


add_subdirectory(src)
add_subdirectory(autotests)

install( PROGRAMS angelfish.desktop DESTINATION ${XDG_APPS_INSTALL_DIR} )

plasma_install_package(package org.kde.plasma.satellite.angelfish packages package)
# install(FILES plasma-mobile-browser.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})


