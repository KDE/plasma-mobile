project( active_settings_time )

find_package(KDE4 REQUIRED)
include(KDE4Defaults)
add_definitions(${QT_DEFINITIONS} ${KDE4_DEFINITIONS})

include_directories(${KDE4_INCLUDES} ../../src)

set(timesettings_SRCS
    timesettings.cpp
    ../../src/settingsmodule.cpp
)


kde4_add_plugin(active_settings_time ${timesettings_SRCS})
target_link_libraries(active_settings_time ${KDE4_PLASMA_LIBS} ${QT_QTDECLARATIVE_LIBRARY})
install(TARGETS active_settings_time DESTINATION ${PLUGIN_INSTALL_DIR})

# Time and Date
install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.time)
install(FILES package/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-package-org.kde.active.settings.time.desktop)
