# SPDX-FileCopyrightText: 2026 Florian Richer <florian.richer@protonmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(grayscaleplugin
    URI "org.kde.plasma.quicksetting.grayscale"
    GENERATE_PLUGIN_SOURCE
)

target_sources(grayscaleplugin PRIVATE grayscaleutil.cpp)

target_link_libraries(grayscaleplugin PRIVATE
    Qt::Core
    Qt::DBus
    Qt::Qml
    Qt::Quick
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
)

ecm_finalize_qml_module(grayscaleplugin)

plasma_install_package(package org.kde.plasma.quicksetting.grayscale quicksettings)
