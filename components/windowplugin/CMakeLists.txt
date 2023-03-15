# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

add_library(windowplugin)
target_sources(windowplugin PRIVATE
    windowplugin.cpp
    windowutil.cpp
)

target_link_libraries(windowplugin
    Qt::Qml
    Qt::DBus
    Qt::Gui
    Qt::Quick
    KF6::WaylandClient
    KF6::Service
    KF6::ConfigWidgets
)

set_property(TARGET windowplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/private/mobileshell/windowplugin)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/private/mobileshell/windowplugin)

install(TARGETS windowplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell/windowplugin)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell/windowplugin)

