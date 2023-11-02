# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(halcyonplugin URI org.kde.private.mobile.homescreen.halcyon GENERATE_PLUGIN_SOURCE)

set(halcyonplugin_SRCS
    application.cpp
    applicationfolder.cpp
    applicationlistmodel.cpp
    pinnedmodel.cpp
    windowlistener.cpp
)

target_sources(halcyonplugin PRIVATE ${halcyonplugin_SRCS})

# Include qml and js files within ./qml/
file(GLOB _qml_sources
    "../package/contents/ui/*.qml"
)
ecm_target_qml_sources(halcyonplugin SOURCES ${_qml_sources})

target_link_libraries(halcyonplugin PRIVATE
                      Qt::Gui
                      Qt::Qml
                      Qt::Quick
                      KF6::Plasma
                      KF6::I18n
                      KF6::Service
                      KF6::KIOGui
                      KF6::JobWidgets
                      KF6::WaylandClient
                      KF6::WindowSystem)

ecm_finalize_qml_module(halcyonplugin)
