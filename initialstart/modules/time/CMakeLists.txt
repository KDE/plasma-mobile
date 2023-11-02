# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(timeplugin URI org.kde.plasma.mobileinitialstart.time GENERATE_PLUGIN_SOURCE)

set(timeplugin_SRCS
    timeutil.cpp
    timezonemodel.cpp
)

target_sources(timeplugin PRIVATE ${timeplugin_SRCS})

target_link_libraries(timeplugin PRIVATE
    Qt::Core
    Qt::DBus
    Qt::Quick
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Notifications
)

ecm_finalize_qml_module(mobileshellplugin)
