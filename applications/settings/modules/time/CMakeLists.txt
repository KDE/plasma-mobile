project( kcm_mobile_time )

include_directories(../../../../components/settings)

configure_file(config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h )

set(timesettings_SRCS
#    timesettingsplugin.cpp
    timesettings.cpp
    timezone.cpp
    timezonesmodel.cpp
)

add_library(kcm_mobile_time MODULE ${timesettings_SRCS})

target_link_libraries(kcm_mobile_time
    Qt5::Quick
    Qt5::Qml
    KF5::Plasma
    KF5::Auth
    KF5::KDELibs4Support
    KF5::QuickAddons
    )
kcoreaddons_desktop_to_json(kcm_mobile_time "timesettings.desktop")

#install(TARGETS kcm_mobile_time DESTINATION ${PLUGIN_INSTALL_DIR}/active/settingsmodule)

# Time and Date
# install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.time)
# install(FILES package/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME org.kde.active.settings.time.desktop)
#plasma_install_package(package org.kde.active.settings.time packages package)

install(FILES timesettings.desktop DESTINATION ${SERVICES_INSTALL_DIR})
install(TARGETS kcm_mobile_time DESTINATION ${PLUGIN_INSTALL_DIR}/kcms)
kpackage_install_package(package kcm_mobile_time kcms)


########### helper ###############

add_executable(activedatetimehelper helper.cpp ${helper_mocs})
target_link_libraries(activedatetimehelper
    KF5::Auth
    KF5::ConfigCore
    KF5::KDELibs4Support
)
install(TARGETS activedatetimehelper DESTINATION ${KAUTH_HELPER_INSTALL_DIR})

kauth_install_helper_files(activedatetimehelper org.kde.active.clockconfig root)
kauth_install_actions(org.kde.active.clockconfig clockconfig_actions.actions)

