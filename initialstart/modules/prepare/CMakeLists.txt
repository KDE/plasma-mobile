# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(prepareplugin_SRCS
    prepareplugin.cpp
    prepareutil.cpp
)

kconfig_add_kcfg_files(prepareplugin_SRCS colorssettings.kcfgc GENERATE_MOC)

add_library(prepareplugin ${prepareplugin_SRCS})

target_link_libraries(prepareplugin
    Qt::Core
    Qt::DBus
    Qt::Quick
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Notifications
    KF6::Screen
)

set_property(TARGET prepareplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/mobileinitialstart/prepare)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/mobileinitialstart/prepare)

install(TARGETS prepareplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobileinitialstart/prepare)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobileinitialstart/prepare)

plasma_install_package(package org.kde.plasma.mobileinitialstart.prepare mobileinitialstart)



