# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(powermenuplugin_SRCS
    powermenuplugin.cpp
    powermenuutil.cpp
)

add_library(powermenuplugin ${powermenuplugin_SRCS})

find_package(LibKWorkspace)

target_link_libraries(powermenuplugin
    Qt::Core
    Qt::Qml
    Qt::Quick
    KF6::CoreAddons
    PW::KWorkspace
)

set_property(TARGET powermenuplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/powermenu)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/powermenu)

install(TARGETS powermenuplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/powermenu)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/powermenu)

plasma_install_package(package org.kde.plasma.quicksetting.powermenu quicksettings)

