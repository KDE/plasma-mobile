cmake_minimum_required(VERSION 3.16)

project(plasma-phone-components)

set(QT_MIN_VERSION "5.15.0")
set(KF5_MIN_VERSION "5.82")
set(KDE_COMPILERSETTINGS_LEVEL "5.82")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMOptionalAddSubdirectory)
include(ECMInstallIcons)
include(ECMSetupVersion)
include(ECMMarkNonGuiExecutable)
include(ECMGenerateHeaders)
include(GenerateExportHeader)
include(KDEGitCommitHooks)
include(KDEClangFormat)
include(FeatureSummary)

find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED
    Core
    Qml
    Quick
)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
    I18n
    KIO
    Plasma
    PlasmaQuick
    Service
    Notifications
    Wayland
    ModemManagerQt
)
find_package(KWinDBusInterface)
set_package_properties(KWinDBusInterface PROPERTIES DESCRIPTION "KWin DBus interface"
    TYPE REQUIRED
    PURPOSE "Needed for virtual keyboard toggle button"
)

include(CheckIncludeFiles)

plasma_install_package(look-and-feel org.kde.plasma.phone look-and-feel)
plasma_install_package(shell org.kde.plasma.phoneshell shells)
plasma_install_package(quicksettings/nightcolor org.kde.plasma.nightcolor quicksettings)
plasma_install_package(quicksettings/airplanemode org.kde.plasma.airplanemode quicksettings)

install(FILES plasma_phone_components.notifyrc DESTINATION ${KNOTIFYRC_INSTALL_DIR})


add_subdirectory(bin)
add_subdirectory(applets)
add_subdirectory(containments)
add_subdirectory(components)
add_subdirectory(mmplugin)

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
