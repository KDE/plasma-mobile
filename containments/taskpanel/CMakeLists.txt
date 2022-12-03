# SPDX-FileCopyrightText: 2015-2016 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2021 Aleix Pol <apol@kde.org>
# SPDX-FileCopyrightText: 2021 Nicolas Fella <nicolas.fella@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qtwayland_client_protocol(wayland_SRCS
        PROTOCOL ${PLASMA_WAYLAND_PROTOCOLS_DIR}/fake-input.xml
        BASENAME fake-input
    )

add_library(org.kde.plasma.mobile.taskpanel MODULE taskpanel.cpp ${DBUS_SRCS} ${wayland_SRCS})

target_link_libraries(org.kde.plasma.mobile.taskpanel
                      Qt::Gui
                      Qt::DBus
                      Qt::Qml
                      Qt::Quick
                      Qt::Sensors
                      Qt::WaylandClient
                      Plasma::Plasma
                      KF6::Screen
                      KF6::I18n
                      Wayland::Client
)


install(TARGETS org.kde.plasma.mobile.taskpanel DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.plasma.mobile.taskpanel)

