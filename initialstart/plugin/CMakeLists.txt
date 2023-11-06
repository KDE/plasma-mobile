# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(initialstartplugin_SRCS
    initialstartplugin.cpp
    initialstartutil.cpp
)

add_library(initialstartplugin ${initialstartplugin_SRCS})

target_link_libraries(initialstartplugin
    Qt::Core
    Qt::Quick
    KF6::CoreAddons
    KF6::I18n
)

set_property(TARGET initialstartplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/mobileinitialstart/initialstart)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/mobileinitialstart/initialstart)

install(TARGETS initialstartplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobileinitialstart/initialstart)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mobileinitialstart/initialstart)
