# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(halcyonplugin_SRCS
    halcyonplugin.cpp
    application.cpp
    applicationfolder.cpp
    applicationlistmodel.cpp
    pinnedmodel.cpp
    windowlistener.cpp
)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/private/mobile/homescreen/halcyon)

add_library(halcyonplugin SHARED ${halcyonplugin_SRCS})

target_link_libraries(halcyonplugin
                      Qt::Gui
                      Qt::Qml
                      Qt::Quick
                      Plasma::Plasma
                      KF6::I18n
                      KF6::Service
                      KF6::KIOGui
                      KF6::JobWidgets
                      Plasma::KWaylandClient
                      KF6::WindowSystem)

set_property(TARGET halcyonplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/private/mobile/homescreen/halcyon)
install(TARGETS halcyonplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/private/mobile/homescreen/halcyon)
