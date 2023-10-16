# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(timeplugin_SRCS
    timeplugin.cpp
    timeutil.cpp
    timezonemodel.cpp
)

add_library(timeplugin ${timeplugin_SRCS})

target_link_libraries(timeplugin
    Qt::Core
    Qt::DBus
    Qt::Quick
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Notifications
)

set_property(TARGET timeplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/mobileinitialstart/time)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/mobileinitialstart/time)

install(TARGETS timeplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobileinitialstart/time)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobileinitialstart/time)

plasma_install_package(package org.kde.plasma.mobileinitialstart.time mobileinitialstart)

