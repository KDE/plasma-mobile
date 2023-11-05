# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(screenrotationplugin_SRCS
    screenrotationplugin.cpp
    screenrotationutil.cpp
)

add_library(screenrotationplugin ${screenrotationplugin_SRCS})

target_link_libraries(screenrotationplugin
    Qt::Core
    Qt::Qml
    Qt::Quick
    Qt::DBus
    Qt::Sensors
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Notifications
    KF6::Screen
)

set_property(TARGET screenrotationplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/screenrotation)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/screenrotation)

install(TARGETS screenrotationplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/screenrotation)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/screenrotation)

plasma_install_package(package org.kde.plasma.quicksetting.screenrotation quicksettings)


