# SPDX-FileCopyrightText: 2015-2021 Marco Martin <mart@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(homescreen_SRCS
    homescreen.cpp
)

add_library(org.kde.plasma.mobile.homescreen.folio MODULE ${homescreen_SRCS})

target_link_libraries(org.kde.plasma.mobile.homescreen.folio
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


install(TARGETS org.kde.plasma.mobile.homescreen.folio DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.plasma.mobile.homescreen.folio)

add_subdirectory(plugin)
