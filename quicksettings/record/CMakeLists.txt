# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(recordplugin_SRCS
    recordplugin.cpp
    recordutil.cpp
)

add_library(recordplugin ${recordplugin_SRCS})

target_link_libraries(recordplugin
    Qt::Core
    Qt::DBus
    Qt::Qml
    Qt::Quick
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Notifications
)

set_property(TARGET recordplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/record)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/record)

install(TARGETS recordplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/record)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/record)
install(FILES plasma_mobile_quicksetting_record.notifyrc DESTINATION ${KDE_INSTALL_KNOTIFYRCDIR})

plasma_install_package(package org.kde.plasma.quicksetting.record quicksettings)
