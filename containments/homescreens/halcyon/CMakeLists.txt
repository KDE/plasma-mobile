# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(homescreen_SRCS
    homescreen.cpp
    application.cpp
    applicationfolder.cpp
    applicationlistmodel.cpp
    pinnedmodel.cpp
    windowlistener.cpp
)

add_library(plasma_containment_phone_homescreen_halcyon MODULE ${homescreen_SRCS})

target_link_libraries(plasma_containment_phone_homescreen_halcyon
                      Qt::Gui
                      KF5::Plasma
                      Qt::Qml
                      Qt::Quick
                      KF5::I18n
                      KF5::Service
                      KF5::KIOGui
                      KF5::Notifications
                      KF5::WaylandClient
                      KF5::WindowSystem
)

install(TARGETS plasma_containment_phone_homescreen_halcyon DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.phone.homescreen.halcyon)
