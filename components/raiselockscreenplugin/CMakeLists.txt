# SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: LGPL-2.0-or-later

ecm_add_qml_module(raiselockscreenplugin URI org.kde.plasma.private.mobileshell.raiselockscreenplugin GENERATE_PLUGIN_SOURCE)
target_sources(raiselockscreenplugin PRIVATE
    raiselockscreen.cpp
    utils.h
)

target_link_libraries(raiselockscreenplugin PRIVATE
    Qt::Qml
    Qt::Quick
    Qt::WaylandClient
    Qt::WaylandClientPrivate
    KF6::Service
    KF6::Package
    KF6::I18n
    KF6::ConfigCore
    KF6::Service
    KF6::WindowSystem
    Wayland::Client
)

qt6_generate_wayland_protocol_client_sources(raiselockscreenplugin FILES
    ${PLASMA_WAYLAND_PROTOCOLS_DIR}/kde-lockscreen-overlay-v1.xml)

ecm_finalize_qml_module(raiselockscreenplugin)


