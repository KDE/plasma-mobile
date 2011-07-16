project(activitymanager-plugin-qtmobilityfeeder)

include_directories(
   ${CMAKE_SOURCE_DIR}
   ${CMAKE_BINARY_DIR}
   ${CMAKE_CURRENT_SOURCE_DIR}
   ${CMAKE_CURRENT_SOURCE_DIR}/foreign
   ${CMAKE_CURRENT_BINARY_DIR}
   ${KDE4_INCLUDES}
   )

set(
   qtmobilityfeeder_SRCS
   qtmobilityfeeder.cpp
   foreign/Plugin.cpp
   foreign/SharedInfo.cpp
   )

kde4_add_plugin(
   activitymanager_plugin_qtmobilityfeeder
   ${qtmobilityfeeder_SRCS}
   )

target_link_libraries(
   activitymanager_plugin_qtmobilityfeeder
   ${KDE4_KDECORE_LIBS}
   ${KDE4_KDEUI_LIBS}
   )

install(TARGETS activitymanager_plugin_qtmobilityfeeder DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES activitymanager-plugin-qtmobilityfeeder.desktop DESTINATION ${SERVICES_INSTALL_DIR})

