# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

find_package(LibKWorkspace)

ecm_add_qml_module(powermenuplugin URI "org.kde.plasma.quicksetting.powermenu" GENERATE_PLUGIN_SOURCE)

target_sources(powermenuplugin PRIVATE powermenuutil.cpp)

target_link_libraries(powermenuplugin PRIVATE
    Qt::Core
    Qt::Qml
    Qt::Quick
    KF6::CoreAddons
    PW::KWorkspace
)

ecm_finalize_qml_module(powermenuplugin)

plasma_install_package(package org.kde.plasma.quicksetting.powermenu quicksettings)

