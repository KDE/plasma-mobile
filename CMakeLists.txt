cmake_minimum_required(VERSION 3.16)

project(plasma-phone-components)

set(QT_MIN_VERSION "5.15.0")
set(KF5_MIN_VERSION "5.78")

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
if(ECM_VERSION VERSION_GREATER_EQUAL 5.79)
    include(KDEGitCommitHooks)
    include(KDEClangFormat)
endif()
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
)
find_package(KWinDBusInterface)

include(CheckIncludeFiles)

plasma_install_package(look-and-feel org.kde.plasma.phone look-and-feel)
plasma_install_package(shell org.kde.plasma.phoneshell shells)

install(DIRECTORY kwinmultitasking/ DESTINATION ${DATA_INSTALL_DIR}/kwin/scripts/org.kde.phone.multitasking)
install(FILES kwinmultitasking/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME kwin-script-org.kde.phone.multitasking.desktop)
install(FILES plasma_phone_components.notifyrc DESTINATION ${KNOTIFYRC_INSTALL_DIR})
install(DIRECTORY components/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell)

add_subdirectory(bin)
add_subdirectory(applets)
add_subdirectory(containments)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

if(ECM_VERSION VERSION_GREATER_EQUAL 5.79)
    # add clang-format target for all our real source files
    file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
    kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
    kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)
endif()
