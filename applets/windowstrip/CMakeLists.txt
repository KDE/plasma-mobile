project(windowstrip)

find_package(KDE4 REQUIRED)
include(KDE4Defaults)
add_definitions (${QT_DEFINITIONS} ${KDE4_DEFINITIONS})

include_directories(
   ${CMAKE_SOURCE_DIR}
   ${CMAKE_BINARY_DIR}
   ${KDE4_INCLUDES}
)

set(windowstrip_SRCS
    windowstrip.cpp
)

kde4_add_plugin(plasma_applet_windowstrip ${windowstrip_SRCS})
target_link_libraries(plasma_applet_windowstrip
                      ${KDE4_PLASMA_LIBS} ${KDE4_KDEUI_LIBS})


install(DIRECTORY qml/ DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.windowstrip)

install(TARGETS plasma_applet_windowstrip
        DESTINATION ${PLUGIN_INSTALL_DIR})

install(FILES plasma-applet-windowstrip.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})