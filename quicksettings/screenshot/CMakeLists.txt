# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

add_definitions(-DTRANSLATION_DOMAIN=\"plasma_org.kde.plasma.quicksetting.screenshot\")

qt_add_dbus_interfaces(DBUS_SRCS dbus/org.kde.KWin.ScreenShot2.xml)

set(screenshotplugin_SRCS
    screenshotplugin.cpp
    screenshotutil.cpp
    ${DBUS_SRCS}
)

add_library(screenshotplugin ${screenshotplugin_SRCS})

target_link_libraries(screenshotplugin
    Qt::Core
    Qt::Qml
    Qt::Quick
    Qt::DBus
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Notifications
)

set_property(TARGET screenshotplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/screenshot)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/screenshot)

install(TARGETS screenshotplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/screenshot)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/quicksetting/screenshot)
install(FILES plasma_mobile_quicksetting_screenshot.notifyrc DESTINATION ${KDE_INSTALL_KNOTIFYRCDIR})

plasma_install_package(package org.kde.plasma.quicksetting.screenshot quicksettings)

