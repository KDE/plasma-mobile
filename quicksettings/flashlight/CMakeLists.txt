# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(flashlightplugin_SRCS
    flashlightplugin.cpp
    flashlightutil.cpp
    ${DBUS_SRCS}
)

add_library(flashlightplugin ${flashlightplugin_SRCS})

target_link_libraries(flashlightplugin
    Qt::Core
    Qt::Qml
    Qt::Quick
    Qt::DBus
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Notifications
    udev
)

set_property(TARGET flashlightplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/flashlight)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/flashlight)

install(TARGETS flashlightplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/flashlight)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/flashlight)

plasma_install_package(package org.kde.plasma.quicksetting.flashlight quicksettings)


