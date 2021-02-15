set(homescreen_SRCS
    homescreen.cpp
    applicationlistmodel.cpp
    favoritesmodel.cpp
)

add_library(plasma_containment_phone_homescreen MODULE ${homescreen_SRCS})

kcoreaddons_desktop_to_json(plasma_containment_phone_homescreen package/metadata.desktop)

target_link_libraries(plasma_containment_phone_homescreen
                      Qt::Gui
                      KF5::Plasma
                      Qt::Qml
                      Qt::Quick
                      KF5::I18n
                      KF5::Service
                      KF5::KIOGui
                      KF5::Notifications
                      KF5::WaylandClient
)


install(TARGETS plasma_containment_phone_homescreen DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.phone.homescreen)

