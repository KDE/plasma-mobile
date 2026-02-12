# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set_source_files_properties(dbus/org.sigxcpu.Feedback.Haptic.xml PROPERTIES INCLUDE vibrationevent.h)
qt_add_dbus_interfaces(dbusinterface_SRCS
    dbus/org.sigxcpu.Feedback.Haptic.xml)

ecm_add_qml_module(hapticsplugin URI org.kde.plasma.private.mobileshell.hapticsplugin GENERATE_PLUGIN_SOURCE)
target_sources(hapticsplugin PRIVATE
    vibrationevent.h
    vibrationmanager.cpp
    ${dbusinterface_SRCS}
)

target_link_libraries(hapticsplugin PRIVATE
    Qt::Qml
    Qt::DBus
    KF6::CoreAddons
    KF6::I18n
    QCoro::DBus
    QCoro::Qml
)

ecm_finalize_qml_module(hapticsplugin)
