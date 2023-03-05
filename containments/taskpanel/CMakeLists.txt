# SPDX-FileCopyrightText: 2015-2016 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2021 Aleix Pol <apol@kde.org>
# SPDX-FileCopyrightText: 2021 Nicolas Fella <nicolas.fella@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

qt_add_dbus_interfaces(DBUS_SRCS ${KWIN_VIRTUALKEYBOARD_INTERFACE})

add_library(org.kde.plasma.mobile.taskpanel MODULE taskpanel.cpp ${DBUS_SRCS})

target_link_libraries(org.kde.plasma.mobile.taskpanel
                      Qt::Gui
                      Qt::DBus
                      Qt::Qml
                      Qt::Quick
                      KF6::Plasma
                      KF6::I18n
                      KF6::Service
                      KF6::WaylandClient
                     )


install(TARGETS org.kde.plasma.mobile.taskpanel DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.plasma.mobile.taskpanel)

