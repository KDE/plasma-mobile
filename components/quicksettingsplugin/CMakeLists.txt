# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(quicksettingsplugin URI org.kde.plasma.private.mobileshell.quicksettingsplugin GENERATE_PLUGIN_SOURCE)
target_sources(quicksettingsplugin PRIVATE
    paginatemodel.cpp
    quicksetting.cpp
    quicksettingsmodel.cpp
    quicksettingsconfig.cpp
    savedquicksettings.cpp
    savedquicksettingsmodel.cpp
)

target_link_libraries(quicksettingsplugin PRIVATE
    Qt::Qml
    Qt::DBus
    Qt::Gui
    Qt::Quick
    KF6::Service
    KF6::Package
    KF6::I18n
    KF6::ConfigCore
)

ecm_finalize_qml_module(quicksettingsplugin)


