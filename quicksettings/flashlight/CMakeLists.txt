# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(flashlightplugin
    URI "org.kde.plasma.quicksetting.flashlight"
    GENERATE_PLUGIN_SOURCE
)

target_sources(flashlightplugin PRIVATE flashlightutil.cpp)

target_link_libraries(flashlightplugin PRIVATE
    Qt::Core
    Qt::Qml
    Qt::Quick
    Qt::DBus
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Notifications
    udev
)

ecm_finalize_qml_module(flashlightplugin)

plasma_install_package(package org.kde.plasma.quicksetting.flashlight quicksettings)
