qt5_add_dbus_interfaces(DBUS_SRCS dbus/org.kde.KWin.Screenshot.xml)

set(phonepanel_SRCS
    phonepanel.cpp
    ${DBUS_SRCS}
)

add_library(plasma_applet_phonepanel MODULE ${phonepanel_SRCS})

kcoreaddons_desktop_to_json(plasma_applet_phonepanel package/metadata.desktop)

target_link_libraries(plasma_applet_phonepanel
                      Qt5::Gui
                      Qt5::DBus
                      KF5::Plasma
                      KF5::I18n
                      ${GSTREAMER_LIBRARIES} GLIB2::GLIB2 ${GOBJECT_LIBRARIES})

target_include_directories(plasma_applet_phonepanel PRIVATE "${GSTREAMER_INCLUDE_DIR}")

install(TARGETS plasma_applet_phonepanel DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)
#install(FILES plasma-phonepanel-default.desktop DESTINATION ${SERVICES_INSTALL_DIR})

plasma_install_package(package org.kde.phone.panel)

