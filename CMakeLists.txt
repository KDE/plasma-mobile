project(plasma-mobile)

cmake_minimum_required(VERSION 2.8.12)

################# Disallow in-source build #################

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
   message(FATAL_ERROR "plasma-mobile requires an out of source build. Please create a separate build directory and run 'cmake path_to_plasma-mobile [options]' there.")
endif()

# Make CPack available to easy generate binary packages
include(CPack)

include(FeatureSummary)

################# set KDE specific information #################

find_package(ECM 0.0.8 REQUIRED NO_MODULE)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings)

find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui)

################# Enable C++11 features for clang and gcc #################

if(UNIX)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++0x")
endif()

################# now find all used packages #################

set (QT_MIN_VERSION "5.4.0")

find_package(KF5 REQUIRED COMPONENTS
    WindowSystem Codecs Archive CoreAddons Solid
    Config Auth DBusAddons Sonnet
    I18n Service Notifications IconThemes Completion
    Bookmarks )

find_package(KF5Plasma REQUIRED NO_MODULE)
find_package(KF5PlasmaQuick REQUIRED NO_MODULE)
find_package(KF5Declarative REQUIRED NO_MODULE)
find_package(KF5KIO REQUIRED NO_MODULE)
find_package(KF5KDELibs4Support NO_MODULE)
find_package(KF5Activities REQUIRED NO_MODULE)
find_package(KF5Baloo NO_MODULE)
find_package(KF5Declarative REQUIRED NO_MODULE)
find_package(PkgConfig)
#########################################################################


find_package(PkgConfig)

#add_subdirectory(applets)
add_subdirectory(applications)
add_subdirectory(components)
add_subdirectory(containments)
#add_subdirectory(dataengines)
add_subdirectory(qmlpackages)
#add_subdirectory(runners)
#add_subdirectory(shell)
add_subdirectory(activeshellpackage)
