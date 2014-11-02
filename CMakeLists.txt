project(plasma-phone-components)

# minimal requirements
cmake_minimum_required (VERSION 2.8.12 FATAL_ERROR)
set (QT_MIN_VERSION "5.2.0")
set(KF5_MIN_VERSION "5.0.0")

set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)


find_package(ECM 0.0.9 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings)
include(ECMOptionalAddSubdirectory)
include(ECMInstallIcons)
include(ECMSetupVersion)
include(ECMMarkNonGuiExecutable)
include(ECMGenerateHeaders)
include(GenerateExportHeader)
include(FeatureSummary)

find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED Core Gui Widgets Qml Quick)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS Plasma Service Declarative)
find_package(KF5 REQUIRED COMPONENTS PlasmaQuick)


feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

include(CheckIncludeFiles)

plasma_install_package(compositor org.kde.satellite.compositor.phone greenisland/compositors)
plasma_install_package(look-and-feel org.kde.satellite.phone look-and-feel)
plasma_install_package(shell org.kde.satellite.phone shells)
install(DIRECTORY wallpaper/ DESTINATION "${WALLPAPER_INSTALL_DIR}/org.kde.satellite.lockers")

configure_file(${CMAKE_SOURCE_DIR}/bin/plasma-phone.cmake ${CMAKE_BINARY_DIR}/plasma-phone)
install(FILES ${CMAKE_BINARY_DIR}/plasma-phone
        PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ WORLD_EXECUTE WORLD_READ GROUP_EXECUTE GROUP_READ
        DESTINATION ${BIN_INSTALL_DIR})

add_subdirectory(qmlcomponents)

