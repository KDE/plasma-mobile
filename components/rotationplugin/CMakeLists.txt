# SPDX-FileCopyrightText: 2025 Micah Stanley <stanleymicah@proton.me>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(rotationplugin URI org.kde.plasma.private.mobileshell.rotationplugin GENERATE_PLUGIN_SOURCE)
target_sources(rotationplugin PRIVATE rotationutil.cpp)

target_link_libraries(rotationplugin PRIVATE
    Qt::Gui
    Qt::DBus
    Qt::Qml
    Qt::Quick
    Qt::Sensors
    Plasma::Plasma
    KF6::Screen
    Qt::Qml
)

ecm_finalize_qml_module(rotationplugin)