# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

add_library(quicksettingsplugin)
target_sources(quicksettingsplugin PRIVATE
    paginatemodel.cpp
    quicksetting.cpp
    quicksettingsmodel.cpp
    quicksettingsplugin.cpp
    quicksettingsconfig.cpp
    savedquicksettings.cpp
    savedquicksettingsmodel.cpp
)

target_link_libraries(quicksettingsplugin
    Qt::Qml
    Qt::DBus
    Qt::Gui
    Qt::Quick
    KF6::WaylandClient
    KF6::Service
    KF6::ConfigWidgets
    KF6::Package
)

set_property(TARGET quicksettingsplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/private/mobileshell/quicksettingsplugin)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/private/mobileshell/quicksettingsplugin)

install(TARGETS quicksettingsplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell/quicksettingsplugin)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell/quicksettingsplugin)


