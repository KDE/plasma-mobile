# SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(homescreen_SRCS
    homescreen.cpp
)

add_library(plasma_containment_phone_homescreen_halcyon MODULE ${homescreen_SRCS})

target_link_libraries(plasma_containment_phone_homescreen_halcyon
                      Qt::Gui
                      Qt::Qml
                      Qt::Quick
                      KF6::Plasma
                      KF6::I18n
                      KF6::Service
                      KF6::KIOGui
                      KF6::Notifications
                      KF6::WaylandClient
                      KF6::WindowSystem
)

install(TARGETS plasma_containment_phone_homescreen_halcyon DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.plasma.mobile.homescreen.halcyon)

add_subdirectory(plugin)
