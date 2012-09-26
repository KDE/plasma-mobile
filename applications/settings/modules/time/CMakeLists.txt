project( active_settings_time )
find_package(KDE4 REQUIRED)
include(KDE4Defaults)
add_definitions(${QT_DEFINITIONS} ${KDE4_DEFINITIONS})

include_directories(${KDE4_INCLUDES} ../../../../components/settings)

configure_file(config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h )

set(timesettings_SRCS
    timesettingsplugin.cpp
    timesettings.cpp
    timezone.cpp
    timezonesmodel.cpp
)


kde4_add_plugin(active_settings_time ${timesettings_SRCS})
target_link_libraries(active_settings_time ${KDE4_PLASMA_LIBS} ${QT_QTDECLARATIVE_LIBRARY})
install(TARGETS active_settings_time DESTINATION ${PLUGIN_INSTALL_DIR})

# Time and Date
install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.time)
install(FILES package/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME org.kde.active.settings.time.desktop)


########### helper ###############

kde4_add_executable(activedatetimehelper helper.cpp ${helper_mocs})
target_link_libraries(activedatetimehelper ${KDE4_KDECORE_LIBS})
install(TARGETS activedatetimehelper DESTINATION ${LIBEXEC_INSTALL_DIR})

kde4_install_auth_helper_files(activedatetimehelper org.kde.active.clockconfig root)

kde4_install_auth_actions(org.kde.active.clockconfig clockconfig_actions.actions)
