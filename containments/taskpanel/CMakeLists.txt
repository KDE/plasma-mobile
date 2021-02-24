qt5_add_dbus_interfaces(DBUS_SRCS ${KWIN_VIRTUALKEYBOARD_INTERFACE})

add_library(plasma_containment_phone_taskpanel MODULE taskpanel.cpp ${DBUS_SRCS})

kcoreaddons_desktop_to_json(plasma_containment_phone_taskpanel package/metadata.desktop)

target_link_libraries(plasma_containment_phone_taskpanel
                      Qt::Gui
                      Qt::DBus
                      KF5::Plasma
                      Qt::Qml
                      Qt::Quick
                      KF5::I18n
                      KF5::Service
                      KF5::WaylandClient
                     )


install(TARGETS plasma_containment_phone_taskpanel DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.phone.taskpanel)

