# SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(screenbrightnessplugin URI org.kde.plasma.private.mobileshell.screenbrightnessplugin GENERATE_PLUGIN_SOURCE)

qt_add_dbus_interfaces(DBUS_SRCS dbus/org.kde.Solid.PowerManagement.Actions.BrightnessControl.xml)

target_sources(screenbrightnessplugin PRIVATE
    screenbrightnessutil.cpp
    ${DBUS_SRCS}
)

target_link_libraries(screenbrightnessplugin PRIVATE
    Qt::Qml
    Qt::DBus
    Qt::Gui
    Qt::Quick
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Screen
)

ecm_finalize_qml_module(screenbrightnessplugin)
