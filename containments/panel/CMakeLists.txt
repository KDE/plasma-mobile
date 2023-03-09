# SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
# SPDX-FileCopyrightText: 2021 Aleix Pol <apol@kde.org>
# SPDX-FileCopyrightText: 2020-2021 Nicolas Fella <nicolas.fella@kde.org>
# SPDX-FileCopyrightText: 2022 Alexey Andreyev <aa13q@ya.ru>
# SPDX-License-Identifier: GPL-2.0-or-later

set(phonepanel_SRCS
    phonepanel.cpp
)

add_library(org.kde.plasma.mobile.panel MODULE ${phonepanel_SRCS})

target_link_libraries(org.kde.plasma.mobile.panel
                      Qt::Gui
                      Qt::DBus
                      Qt::Quick
                      Qt::WaylandClient
                      Qt::WaylandClientPrivate
                      KF6::Plasma
                      KF6::I18n
                      KF6::Service
                      KF6::WindowSystem
                      Wayland::Client
                     )

qt6_generate_wayland_protocol_client_sources(org.kde.plasma.mobile.panel FILES
    ${PLASMA_WAYLAND_PROTOCOLS_DIR}/kde-lockscreen-overlay-v1.xml)

install(TARGETS org.kde.plasma.mobile.panel DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.plasma.mobile.panel)

