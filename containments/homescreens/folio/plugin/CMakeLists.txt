# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(folioplugin_SRCS
    folioplugin.cpp
    applicationlistmodel.cpp
    desktopmodel.cpp
)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/private/mobile/homescreen/folio)

add_library(folioplugin SHARED ${folioplugin_SRCS})

target_link_libraries(folioplugin
                      Qt::Gui
                      Qt::Qml
                      Qt::Quick
                      KF6::Plasma
                      KF6::PlasmaQuick
                      KF6::I18n
                      KF6::Service
                      KF6::KIOGui
                      KF6::JobWidgets
                      KF6::WaylandClient
                      KF6::WindowSystem)

set_property(TARGET folioplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/private/mobile/homescreen/folio)
install(TARGETS folioplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/private/mobile/homescreen/folio)

