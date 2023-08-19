# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

add_library(shellsettingsplugin)
target_sources(shellsettingsplugin PRIVATE
    mobileshellsettings.cpp
    shellsettingsplugin.cpp
)

target_link_libraries(shellsettingsplugin
    Qt::Qml
    Qt::DBus
    Qt::Gui
    Qt::Quick
    KF6::WaylandClient
    KF6::Service
    KF6::ConfigWidgets
    KF6::Package
    KF6::KIOGui
    KF6::JobWidgets
)

set_property(TARGET shellsettingsplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/private/mobileshell/shellsettingsplugin)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/private/mobileshell/shellsettingsplugin)

install(TARGETS shellsettingsplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell/shellsettingsplugin)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell/shellsettingsplugin)



