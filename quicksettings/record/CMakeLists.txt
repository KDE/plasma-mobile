# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(recordplugin_SRCS
    recordplugin.cpp
    recordutil.cpp
)

add_library(recordplugin ${recordplugin_SRCS})

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS 
    Declarative
    Notifications
)

target_link_libraries(recordplugin
    PUBLIC
        Qt::Core
    PRIVATE
        Qt::DBus
        KF5::CoreAddons
        KF5::QuickAddons
        KF5::ConfigCore
        KF5::ConfigGui
        KF5::I18n
        KF5::Notifications
)

set_property(TARGET recordplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/record)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/record)

install(TARGETS recordplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/record)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/record)

plasma_install_package(package org.kde.plasma.quicksetting.record quicksettings)
