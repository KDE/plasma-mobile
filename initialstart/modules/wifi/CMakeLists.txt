# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(wifiplugin_SRCS
    wifiplugin.cpp
    wifiutil.cpp
)

add_library(wifiplugin ${wifiplugin_SRCS})

target_link_libraries(wifiplugin
    Qt::Core
    Qt::DBus
    Qt::Quick
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::NetworkManagerQt
    KF6::I18n
)

set_property(TARGET wifiplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/mobileinitialstart/wifi)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/mobileinitialstart/wifi)

install(TARGETS wifiplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobileinitialstart/wifi)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobileinitialstart/wifi)

plasma_install_package(package org.kde.plasma.mobileinitialstart.wifi mobileinitialstart)





