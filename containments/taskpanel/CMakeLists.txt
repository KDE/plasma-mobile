# SPDX-FileCopyrightText: 2015-2016 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2021 Aleix Pol <apol@kde.org>
# SPDX-FileCopyrightText: 2021 Nicolas Fella <nicolas.fella@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

qt_add_dbus_interfaces(DBUS_SRCS ${KWIN_VIRTUALKEYBOARD_INTERFACE})

if (QT_MAJOR_VERSION EQUAL "5")
    ecm_add_qtwayland_client_protocol(wayland_SRCS
        PROTOCOL ${PLASMA_WAYLAND_PROTOCOLS_DIR}/fake-input.xml
        BASENAME fake-input
    )
else()
    qt6_generate_wayland_protocol_client_sources(wayland_SRCS FILES
        ${PLASMA_WAYLAND_PROTOCOLS_DIR}/fake-input.xml)
endif()

add_library(plasma_containment_phone_taskpanel MODULE taskpanel.cpp ${DBUS_SRCS} ${wayland_SRCS})

target_link_libraries(plasma_containment_phone_taskpanel
                      Qt::Gui
                      Qt::DBus
                      Qt::Qml
                      Qt::Quick
                      Qt::WaylandClient
                      Wayland::Client
                      KF5::Plasma
                      KF5::I18n
                      KF5::Service
                      KF5::WaylandClient
                     )


install(TARGETS plasma_containment_phone_taskpanel DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.phone.taskpanel)

