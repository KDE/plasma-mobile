project(LocationChooser)

add_subdirectory(package/icons)

installPackage(package org.kde.locationchooser)

include_directories(
   ${CMAKE_SOURCE_DIR}
   ${CMAKE_BINARY_DIR}
   ${CMAKE_CURRENT_SOURCE_DIR}
   ${CMAKE_CURRENT_BINARY_DIR}
   ${KDE4_INCLUDES}
)

configure_file(config-locationchooser.h.cmake
   ${CMAKE_CURRENT_BINARY_DIR}/config-locationchooser.h)

set(plasma_applet_locationchooser_SRCS
   LocationChooser.cpp
   Engine.cpp
)

qt4_add_dbus_interface(
   plasma_applet_locationchooser_SRCS
   org.kde.LocationManager.xml
   locationmanager_interface
   )

kde4_add_plugin(
   plasma_applet_locationchooser
   ${plasma_applet_locationchooser_SRCS}
   )

target_link_libraries(
   plasma_applet_locationchooser
   ${QT_QTDECLARATIVE_LIBRARY}
   ${QT_QTDBUS_LIBRARY}
   ${QT_QTCORE_LIBRARY}
   ${KDE4_PLASMA_LIBS}
   )

install(
   TARGETS plasma_applet_locationchooser
   DESTINATION ${PLUGIN_INSTALL_DIR}
   )

install(
   FILES plasma-applet-locationchooser.desktop
   DESTINATION ${SERVICES_INSTALL_DIR}
   )

