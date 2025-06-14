# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(recordplugin URI "org.kde.plasma.quicksetting.record" GENERATE_PLUGIN_SOURCE)

target_sources(recordplugin PRIVATE recordutil.cpp)

target_link_libraries(recordplugin PRIVATE
    Qt::Core
    Qt::DBus
    Qt::Qml
    Qt::Quick
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Notifications
    K::KPipeWire
    K::KPipeWireRecord
)

ecm_finalize_qml_module(recordplugin)

install(FILES plasma_mobile_quicksetting_record.notifyrc DESTINATION ${KDE_INSTALL_KNOTIFYRCDIR})

plasma_install_package(package org.kde.plasma.quicksetting.record quicksettings)
