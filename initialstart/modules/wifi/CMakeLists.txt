# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(wifiplugin URI org.kde.plasma.mobileinitialstart.wifi GENERATE_PLUGIN_SOURCE)

set(wifiplugin_SRCS
    wifiutil.cpp
)

target_sources(wifiplugin PRIVATE ${wifiplugin_SRCS})

target_link_libraries(wifiplugin PRIVATE
    Qt::Core
    Qt::DBus
    Qt::Quick
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::NetworkManagerQt
    KF6::I18n
)

ecm_finalize_qml_module(mobileshellplugin)
