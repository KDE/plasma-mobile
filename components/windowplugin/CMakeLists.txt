# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(windowplugin URI org.kde.plasma.private.mobileshell.windowplugin GENERATE_PLUGIN_SOURCE)

target_sources(windowplugin PRIVATE windowutil.cpp)

set_source_files_properties(qml/WindowMaximizedTracker.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
ecm_target_qml_sources(windowplugin SOURCES qml/WindowMaximizedTracker.qml)

target_link_libraries(windowplugin PRIVATE
    Qt::Qml
    Qt::DBus
    Qt::Gui
    Qt::Quick
    KF6::WaylandClient
    KF6::Service
    KF6::ConfigWidgets
)

ecm_finalize_qml_module(windowplugin)
