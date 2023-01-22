# SPDX-FileCopyrightText: 2015-2021 Marco Martin <mart@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(homescreen_SRCS
    homescreen.cpp
    desktopmodel.cpp desktopmodel.h
    applicationlistmodel.cpp applicationlistmodel.h
)

add_library(plasma_containment_phone_homescreen MODULE ${homescreen_SRCS})

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
                      KF5::WindowSystem
)


install(TARGETS plasma_containment_phone_homescreen DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.phone.homescreen)
