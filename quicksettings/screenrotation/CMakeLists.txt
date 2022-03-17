# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

qt_add_dbus_interfaces(DBUS_SRCS dbus/org.kde.KScreen.xml)

set(screenrotationplugin_SRCS
    screenrotationplugin.cpp
    screenrotationutil.cpp
    ${DBUS_SRCS}
)

add_library(screenrotationplugin ${screenrotationplugin_SRCS})

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS 
    Declarative
)

target_link_libraries(screenrotationplugin
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

set_property(TARGET screenrotationplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/screenrotation)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/screenrotation)

install(TARGETS screenrotationplugin DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/quicksetting/screenrotation)
install(FILES qmldir ${qml_SRC} DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/quicksetting/screenrotation)

plasma_install_package(package org.kde.plasma.quicksetting.screenrotation quicksettings)


