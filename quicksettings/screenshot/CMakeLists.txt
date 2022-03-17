# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

qt_add_dbus_interfaces(DBUS_SRCS dbus/org.kde.KWin.ScreenShot2.xml)

set(screenshotplugin_SRCS
    screenshotplugin.cpp
    screenshotutil.cpp
    ${DBUS_SRCS}
)

add_library(screenshotplugin ${screenshotplugin_SRCS})

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS 
    Declarative
)

target_link_libraries(screenshotplugin
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

set_property(TARGET screenshotplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/screenshot)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/screenshot)

install(TARGETS screenshotplugin DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/quicksetting/screenshot)
install(FILES qmldir ${qml_SRC} DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/quicksetting/screenshot)

plasma_install_package(package org.kde.plasma.quicksetting.screenshot quicksettings)

