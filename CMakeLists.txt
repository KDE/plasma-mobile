project(plasma-mobile)

cmake_minimum_required(VERSION 2.8.10.1)

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

find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Core Quick X11Extras Svg Test PrintSupport WebKitWidgets)

add_definitions(-DQT_DISABLE_DEPRECATED_BEFORE=0)

if(KDE_PLATFORM_FEATURE_DISABLE_DEPRECATED)
   set(KDE_NO_DEPRECATED TRUE)
   set(CMAKE_AUTOMOC_MOC_OPTIONS "-DKDE_NO_DEPRECATED")
endif()

################# Enable C++11 features for clang and gcc #################

if(UNIX)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++0x")
endif()

################# now find all used packages #################

set (QT_MIN_VERSION "5.2.0")


# Load CMake, Compiler and InstallDirs settings from KF5 and the following are already somewhat "done" tier1/tier2 libs from kdelibs:
find_package(KF5 REQUIRED COMPONENTS
    IdleTime ItemModels WidgetsAddons WindowSystem Codecs Archive CoreAddons Solid ThreadWeaver
    Config Auth JS Wallet DBusAddons Sonnet
    I18n GuiAddons Service ConfigWidgets ItemViews Notifications IconThemes Completion JobWidgets TextWidgets
    TextEditor GlobalAccel XmlGui Crash UnitConversion Bookmarks Parts Kross NewStuff Attica)

find_package(KF5Plasma REQUIRED NO_MODULE)
find_package(KF5PlasmaQuick REQUIRED NO_MODULE)
find_package(KF5Declarative REQUIRED NO_MODULE)
find_package(KF5KIO REQUIRED NO_MODULE)
find_package(KF5KDELibs4Support REQUIRED NO_MODULE)
find_package(KF5Activities REQUIRED NO_MODULE)
find_package(Baloo REQUIRED NO_MODULE)
find_package(KF5Declarative REQUIRED NO_MODULE)
find_package(PkgConfig)
#########################################################################

add_definitions(-DQT_USE_FAST_CONCATENATION -DQT_USE_FAST_OPERATOR_PLUS)
add_definitions(-DQT_NO_URL_CAST_FROM_STRING)

remove_definitions(-DQT_NO_CAST_FROM_ASCII -DQT_STRICT_ITERATORS -DQT_NO_CAST_FROM_BYTEARRAY -DQT_NO_KEYWORDS)


find_package(PkgConfig)
pkg_check_modules(QTNETWORKMANAGER NetworkManagerQt)
##TODO find a way to find it properly
##find_package(LibKScreen)

MACRO(installPackage dir component)
   SET(root ${ARGN})
   IF(NOT root)
        SET(root plasma/plasmoids)
     ENDIF(NOT root)
    install(DIRECTORY ${dir}/ DESTINATION ${DATA_INSTALL_DIR}/${root}/${component} PATTERN Messages.sh EXCLUDE)
    install(FILES ${dir}/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-applet-${component}.desktop)
ENDMACRO(installPackage)

#add_subdirectory(applets)
#add_subdirectory(applications)
#add_subdirectory(artwork)
add_subdirectory(components)
add_subdirectory(containments)
#add_subdirectory(dataengines)
add_subdirectory(qmlpackages)
#add_subdirectory(runners)
#add_subdirectory(shell)
#add_subdirectory(wallpapers)
add_subdirectory(activeshellpackage)

#if (QTNETWORKMANAGER_FOUND)
#    add_subdirectory(contourd)
#else (QTNETWORKMANAGER_FOUND)
#    message(WARNING "QtNetworkManager not found. http://projects.kde.org/search?q=networkmanager&scope=all&all_words=1&projects=1&submit=Submit needed to build Contour")
#endif (QTNETWORKMANAGER_FOUND)

#if (BUILD_HANDSET)
#   add_subdirectory(handset)
#endif (BUILD_HANDSET)
