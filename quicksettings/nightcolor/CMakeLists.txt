# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set_source_files_properties(${KWIN_NIGHTLIGHT_INTERFACE} PROPERTIES NO_NAMESPACE TRUE)
qt_add_dbus_interfaces(DBUS_SRCS ${KWIN_NIGHTLIGHT_INTERFACE})

set(nightcolorplugin_SRCS
    nightcolorutil.cpp
    enum.h
    ${DBUS_SRCS}
)

kconfig_add_kcfg_files(nightcolorplugin_SRCS nightcolorsettings.kcfgc GENERATE_MOC)

ecm_add_qml_module(nightcolorplugin URI "org.kde.plasma.quicksetting.nightcolor" GENERATE_PLUGIN_SOURCE)

target_sources(nightcolorplugin PRIVATE ${nightcolorplugin_SRCS})

target_link_libraries(nightcolorplugin PRIVATE
    Qt::Core
    Qt::DBus
    Qt::Qml
    Qt::Quick
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
)

ecm_finalize_qml_module(nightcolorplugin)

plasma_install_package(package org.kde.plasma.quicksetting.nightcolor quicksettings)
