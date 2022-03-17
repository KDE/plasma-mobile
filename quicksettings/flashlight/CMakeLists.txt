# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(flashlightplugin_SRCS
    flashlightplugin.cpp
    flashlightutil.cpp
    ${DBUS_SRCS}
)

add_library(flashlightplugin ${flashlightplugin_SRCS})

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS 
    Declarative
)

target_link_libraries(flashlightplugin
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

set_property(TARGET flashlightplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/flashlight)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/flashlight)

install(TARGETS flashlightplugin DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/quicksetting/flashlight)
install(FILES qmldir ${qml_SRC} DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/quicksetting/flashlight)

plasma_install_package(package org.kde.plasma.quicksetting.flashlight quicksettings)


