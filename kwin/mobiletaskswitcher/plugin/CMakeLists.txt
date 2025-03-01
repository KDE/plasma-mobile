# SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(mobiletaskswitcherplugin URI org.kde.plasma.private.mobileshell.taskswitcherplugin GENERATE_PLUGIN_SOURCE)

target_sources(mobiletaskswitcherplugin PRIVATE
    mobiletaskswitchereffect.cpp
    effecttouchborder.cpp
    taskfiltermodel.cpp
    taskmodel.cpp)

target_link_libraries(mobiletaskswitcherplugin PRIVATE
    KF6::ConfigGui
    KF6::GlobalAccel
    KF6::I18n
    KF6::CoreAddons
    KF6::WindowSystem

    Qt::Quick
    Qt::Core

    KWin::kwin
    Plasma::Activities
)

ecm_finalize_qml_module(mobiletaskswitcherplugin)
