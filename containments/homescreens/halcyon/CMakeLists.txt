# SPDX-FileCopyrightText: 2022-2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_org.kde.plasma.mobile.homescreen.halcyon\")

set(homescreen_SRCS
    homescreen.cpp
    halcyonsettings.cpp
)

add_library(org.kde.plasma.mobile.homescreen.halcyon MODULE ${homescreen_SRCS})

target_link_libraries(org.kde.plasma.mobile.homescreen.halcyon
                      Qt::Gui
                      Qt::Qml
                      Qt::Quick
                      Plasma::Plasma
                      Plasma::KWaylandClient
                      KF6::I18n
                      KF6::Service
                      KF6::KIOGui
                      KF6::Notifications
                      KF6::WindowSystem
)

install(TARGETS org.kde.plasma.mobile.homescreen.halcyon DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.plasma.mobile.homescreen.halcyon)

add_subdirectory(plugin)
