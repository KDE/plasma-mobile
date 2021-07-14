qt_add_dbus_interfaces(DBUS_SRCS dbus/org.kde.KWin.Screenshot.xml
                                  dbus/org.kde.KScreen.xml)

set(phonepanel_SRCS
    phonepanel.cpp
    ${DBUS_SRCS}
)

add_library(plasma_applet_phonepanel MODULE ${phonepanel_SRCS})

kcoreaddons_desktop_to_json(plasma_applet_phonepanel package/metadata.desktop)

target_link_libraries(plasma_applet_phonepanel
                      Qt::Gui
                      Qt::DBus
                      KF5::Plasma
                      KF5::I18n
                      KF5::Notifications
                      KF5::KIOGui
                      KF5::Service
                     )

install(TARGETS plasma_applet_phonepanel DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)
#install(FILES plasma-phonepanel-default.desktop DESTINATION ${SERVICES_INSTALL_DIR})

plasma_install_package(package org.kde.phone.panel)

