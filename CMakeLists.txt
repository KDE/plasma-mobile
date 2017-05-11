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

find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED Core Gui Widgets Qml Quick Test)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS Plasma Service Declarative I18n KIO People)
find_package(KF5 REQUIRED COMPONENTS PlasmaQuick DBusAddons Notifications)
find_package(TelepathyQt5 REQUIRED)
find_package(KF5Wayland CONFIG)
set_package_properties(KF5Wayland PROPERTIES
                       TYPE REQUIRED
                       PURPOSE "Required for interacting with the compositor")


feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

include(CheckIncludeFiles)

plasma_install_package(look-and-feel org.kde.plasma.phone look-and-feel)
plasma_install_package(shell org.kde.plasma.phone shells)
install(DIRECTORY wallpaper/ DESTINATION "${WALLPAPER_INSTALL_DIR}/org.kde.plasma.phone.lockers")

#kpackage_install_package(phonebook org.kde.phone.phonebook genericqml)
#install(FILES phonebook/metadata.desktop DESTINATION ${XDG_APPS_INSTALL_DIR} RENAME org.kde.phone.phonebook.desktop)

install( DIRECTORY kwinmultitasking/ DESTINATION ${DATA_INSTALL_DIR}/kwin/scripts/org.kde.phone.multitasking )
install( FILES kwinmultitasking/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME kwin-script-org.kde.phone.multitasking.desktop )

install( DIRECTORY qtvirtualkeyboardplugin/ DESTINATION ${KDE_INSTALL_QMLDIR}/QtQuick/VirtualKeyboard/Styles/Plasma )

add_subdirectory(bin)
#add_subdirectory(services)
add_subdirectory(applets)
add_subdirectory(containments)
add_subdirectory(dialer)
add_subdirectory(sounds)
