# SPDX-FileCopyrightText: 2015-2021 Marco Martin <mart@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(homescreen_SRCS
    homescreen.cpp
    desktopmodel.cpp
    applicationlistmodel.cpp
)

add_library(plasma_containment_phone_homescreen MODULE ${homescreen_SRCS})

target_link_libraries(plasma_containment_phone_homescreen
                      Qt::Gui
                      Qt::Qml
                      Qt::Quick
                      KF6::Plasma
                      KF6::PlasmaQuick
                      KF6::I18n
                      KF6::Service
                      KF6::KIOGui
                      KF6::Notifications
                      KF6::WaylandClient
                      KF6::WindowSystem
)


install(TARGETS plasma_containment_phone_homescreen DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.phone.homescreen)
