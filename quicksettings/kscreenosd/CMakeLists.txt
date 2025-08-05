# SPDX-FileCopyrightText: 2025 Sebastian Kügler <sebas@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(kscreenosdplugin_SRCS
    kscreenosdplugin.cpp
    kscreenosdutil.cpp
)

add_library(kscreenosdplugin ${kscreenosdplugin_SRCS})

target_link_libraries(kscreenosdplugin
    Qt::Core
    Qt::Qml
    Qt::Quick
    Qt::DBus
    KF6::Screen
)

set_property(TARGET kscreenosdplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/kscreenosd)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/kscreenosd)

install(TARGETS kscreenosdplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/kscreenosd)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/kscreenosd)

plasma_install_package(package org.kde.plasma.quicksetting.kscreenosd quicksettings)


