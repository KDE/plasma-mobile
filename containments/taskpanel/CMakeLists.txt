set(taskpanel_SRCS
    taskpanel.cpp
)

add_library(plasma_containment_phone_taskpanel MODULE ${taskpanel_SRCS})

kcoreaddons_desktop_to_json(plasma_containment_phone_taskpanel package/metadata.desktop)

target_link_libraries(plasma_containment_phone_taskpanel
                      Qt5::Gui
                      Qt5::DBus
                      KF5::Plasma
                      Qt5::Qml
                      Qt5::Quick
                      KF5::I18n
                      KF5::Service
                      KF5::WaylandClient
                     )


install(TARGETS plasma_containment_phone_taskpanel DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.phone.taskpanel)

