# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(wallpaperimageplugin URI org.kde.plasma.private.mobileshell.wallpaperimageplugin GENERATE_PLUGIN_SOURCE)
target_sources(wallpaperimageplugin PRIVATE
    wallpaperplugin.cpp
)

# Include qml and js files within ./qml/
file(GLOB_RECURSE _qml_sources
    "qml/*.qml"
    "qml/*.js"
)
ecm_target_qml_sources(wallpaperimageplugin SOURCES ${_qml_sources})

target_link_libraries(wallpaperimageplugin PRIVATE
    Qt::Qml
    Qt::Gui
    Qt::Quick
    Qt::DBus
    Qt::Widgets
    Plasma::Plasma
    Plasma::PlasmaQuick
    KF6::CoreAddons
    KF6::I18n
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::ConfigQml
    KF6::Package
    QCoro::DBus
    PW::KWorkspace
)

ecm_finalize_qml_module(wallpaperimageplugin)
