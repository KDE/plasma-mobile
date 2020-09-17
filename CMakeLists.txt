project(plasma-phone-components)

# minimal requirements
cmake_minimum_required (VERSION 2.8.12 FATAL_ERROR)
set (QT_MIN_VERSION "5.12.0")
set(KF5_MIN_VERSION "5.74")

set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ECM 5.41.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR} ${CMAKE_SOURCE_DIR}/cmake)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMOptionalAddSubdirectory)
include(ECMInstallIcons)
include(ECMSetupVersion)
include(ECMMarkNonGuiExecutable)
include(ECMGenerateHeaders)
include(GenerateExportHeader)
include(FeatureSummary)

find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED Core Qml Quick)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
    I18n
    KIO
    Plasma
    PlasmaQuick
    Service
    Notifications
)
find_package(KF5Wayland CONFIG)
set_package_properties(KF5Wayland PROPERTIES
                       TYPE REQUIRED
                       PURPOSE "Required for interacting with the compositor")

# torch
find_package(GStreamer 1.1.90 REQUIRED)
find_package(GLIB2 REQUIRED)
find_package(GObject REQUIRED)

include(CheckIncludeFiles)

plasma_install_package(look-and-feel org.kde.plasma.phone look-and-feel)
plasma_install_package(shell org.kde.plasma.phone shells)

install( DIRECTORY kwinmultitasking/ DESTINATION ${DATA_INSTALL_DIR}/kwin/scripts/org.kde.phone.multitasking )
install( FILES kwinmultitasking/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME kwin-script-org.kde.phone.multitasking.desktop )

install( DIRECTORY components/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell )

add_subdirectory(bin)
add_subdirectory(applets)
add_subdirectory(containments)
add_subdirectory(sounds)
#add_subdirectory(touchscreentest)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
