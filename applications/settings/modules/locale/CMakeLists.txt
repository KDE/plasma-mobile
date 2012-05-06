project( active_settings_locale )
find_package(KDE4 REQUIRED)
include(KDE4Defaults)
add_definitions(${QT_DEFINITIONS} ${KDE4_DEFINITIONS})

include_directories(${KDE4_INCLUDES} ../../../../components/settings)

set(localesettings_SRCS
    localesettingsplugin.cpp
    localesettings.cpp
    languagesmodel.cpp
)

kde4_add_plugin(active_settings_locale ${localesettings_SRCS})
target_link_libraries(active_settings_locale ${KDE4_PLASMA_LIBS} ${QT_QTDECLARATIVE_LIBRARY})
install(TARGETS active_settings_locale DESTINATION ${PLUGIN_INSTALL_DIR})

# Locale
install(DIRECTORY package/ DESTINATION ${DATA_INSTALL_DIR}/plasma/packages/org.kde.active.settings.locale)
install(FILES package/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME plasma-package-org.kde.active.settings.locale.desktop)
