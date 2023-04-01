# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(cellularplugin_SRCS
    cellularplugin.cpp
)

add_library(cellularplugin ${cellularplugin_SRCS})

target_link_libraries(cellularplugin
    Qt::Core
    Qt::DBus
    Qt::Quick
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Notifications
    KF6::NetworkManagerQt
    KF6::ModemManagerQt
)

set_property(TARGET cellularplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/mobileinitialstart/cellular)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/mobileinitialstart/cellular)

install(TARGETS cellularplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobileinitialstart/cellular)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobileinitialstart/cellular)

plasma_install_package(package org.kde.plasma.mobileinitialstart.cellular mobileinitialstart)




