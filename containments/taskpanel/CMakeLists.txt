# SPDX-FileCopyrightText: 2015-2016 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2021 Aleix Pol <apol@kde.org>
# SPDX-FileCopyrightText: 2021 Nicolas Fella <nicolas.fella@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

qt_add_dbus_interfaces(DBUS_SRCS ${KWIN_VIRTUALKEYBOARD_INTERFACE})

add_library(plasma_containment_phone_taskpanel MODULE taskpanel.cpp taskpanel.h ${DBUS_SRCS})

target_link_libraries(plasma_containment_phone_taskpanel
                      Qt::Gui
                      Qt::DBus
                      KF5::Plasma
                      Qt::Qml
                      Qt::Quick
                      KF5::I18n
                      KF5::Service
                      KF5::WaylandClient
                     )


install(TARGETS plasma_containment_phone_taskpanel DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.phone.taskpanel)

