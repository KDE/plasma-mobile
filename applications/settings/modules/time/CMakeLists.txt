project( active_settings_time )

include_directories(../../../../components/settings)

configure_file(config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h )

set(timesettings_SRCS
    timesettingsplugin.cpp
    timesettings.cpp
    timezone.cpp
    timezonesmodel.cpp
)

add_library(active_settings_time MODULE ${timesettings_SRCS})
target_link_libraries(active_settings_time
    Qt5::Quick
    Qt5::Qml
    KF5::Plasma
    KF5::Auth
    KF5::KDELibs4Support
    )
kservice_desktop_to_json(active_settings_time "package/metadata.desktop" timeplugin.json)

install(TARGETS active_settings_time DESTINATION ${PLUGIN_INSTALL_DIR}/active/settingsmodule)

# Time and Date
# install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.time)
# install(FILES package/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME org.kde.active.settings.time.desktop)
plasma_install_package(package org.kde.active.settings.time packages package)

########### helper ###############

# add_executable(activedatetimehelper helper.cpp ${helper_mocs})
# target_link_libraries(activedatetimehelper
#     KF5::KCoreAddons
#     KF5::Auth
#     KF5::ConfigCore
#     KF5::KDELibs4Support
# )
#install(TARGETS activedatetimehelper DESTINATION ${LIBEXEC_INSTALL_DIR})

# FIXME
# kde4_install_auth_helper_files(activedatetimehelper org.kde.active.clockconfig root)
#
# kde4_install_auth_actions(org.kde.active.clockconfig clockconfig_actions.actions)
