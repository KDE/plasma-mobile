set(homescreen_SRCS
    homescreen.cpp
    applicationlistmodel.cpp
)

add_library(plasma_applet_phone_homescreen MODULE ${homescreen_SRCS})

kcoreaddons_desktop_to_json(plasma_applet_phone_homescreen package/metadata.desktop)

target_link_libraries(plasma_applet_phone_homescreen
                      Qt5::Gui
                      KF5::Plasma
                      Qt5::Qml
                      KF5::I18n
                      KF5::Service
                     )


install(TARGETS plasma_applet_phone_homescreen DESTINATION ${PLUGIN_INSTALL_DIR}/plasma/applets)

plasma_install_package(package org.kde.phone.homescreen)

