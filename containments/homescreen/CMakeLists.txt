set(homescreen_SRCS
    homescreen.cpp
    applicationlistmodel.cpp
    colouraverage.cpp
)

add_library(plasma_containment_phone_homescreen MODULE ${homescreen_SRCS})

kcoreaddons_desktop_to_json(plasma_containment_phone_homescreen package/metadata.desktop)

target_link_libraries(plasma_containment_phone_homescreen
                      Qt5::Gui
                      KF5::Plasma
                      Qt5::Qml
                      Qt5::Quick
                      KF5::I18n
                      KF5::Service
                      KF5::KIOWidgets
                     )


install(TARGETS plasma_containment_phone_homescreen DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.phone.homescreen)

