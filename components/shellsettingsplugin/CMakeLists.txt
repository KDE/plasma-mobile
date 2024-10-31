# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(shellsettingsplugin URI org.kde.plasma.private.mobileshell.shellsettingsplugin GENERATE_PLUGIN_SOURCE)
target_sources(shellsettingsplugin PRIVATE mobileshellsettings.cpp)

target_link_libraries(shellsettingsplugin PRIVATE
    Qt::Qml
    Qt::DBus
    Qt::Gui
    Qt::Quick
    Plasma::KWaylandClient
    KF6::Service
    KF6::Package
    KF6::KIOGui
    KF6::JobWidgets
)

ecm_finalize_qml_module(shellsettingsplugin)
