# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set_source_files_properties(${KWIN_NIGHTLIGHT_INTERFACE} PROPERTIES NO_NAMESPACE TRUE)
qt_add_dbus_interfaces(DBUS_SRCS ${KWIN_NIGHTLIGHT_INTERFACE})

set(nightcolorplugin_SRCS
    nightcolorplugin.cpp
    nightcolorutil.cpp
    enum.h
    ${DBUS_SRCS}
)

kconfig_add_kcfg_files(nightcolorplugin_SRCS nightcolorsettings.kcfgc GENERATE_MOC)

add_library(nightcolorplugin ${nightcolorplugin_SRCS})

target_link_libraries(nightcolorplugin
    Qt::Core
    Qt::DBus
    Qt::Qml
    Qt::Quick
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
)

set_property(TARGET nightcolorplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/nightcolor)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/nightcolor)

install(TARGETS nightcolorplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/nightcolor)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/nightcolor)

plasma_install_package(package org.kde.plasma.quicksetting.nightcolor quicksettings)
