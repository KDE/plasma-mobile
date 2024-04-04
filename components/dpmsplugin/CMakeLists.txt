# SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(dpmsplugin URI org.kde.plasma.private.mobileshell.dpmsplugin GENERATE_PLUGIN_SOURCE)

target_sources(dpmsplugin PRIVATE dpmsutil.cpp)

target_link_libraries(dpmsplugin PRIVATE
    Qt::Qml
    Qt::DBus
    Qt::Gui
    Qt::Quick
    KF6::ScreenDpms
)

ecm_finalize_qml_module(dpmsplugin)
