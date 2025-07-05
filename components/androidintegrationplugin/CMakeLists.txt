# SPDX-FileCopyrightText: 2025 Florian RICHER <florian.richer@protonmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(androidintegrationplugin URI org.kde.plasma.private.mobileshell.androidintegrationplugin GENERATE_PLUGIN_SOURCE)
target_sources(androidintegrationplugin PRIVATE waydroidstate.cpp)

target_link_libraries(androidintegrationplugin PRIVATE
    Qt::Gui
    Qt::Qml
    Qt::Quick
    KF6::AuthCore
)

ecm_finalize_qml_module(androidintegrationplugin)

add_subdirectory(kauth)