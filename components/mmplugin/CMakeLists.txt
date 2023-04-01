# SPDX-FileCopyrightText: 2021 Tobias Fella <fella@posteo.de>
# SPDX-License-Identifier: GPL-2.0-or-later

add_library(ppc-mmqmlplugin)
target_sources(ppc-mmqmlplugin PRIVATE
    mmqmlplugin.cpp
    signalindicator.cpp
    profilesettings.cpp
)

target_link_libraries(ppc-mmqmlplugin
    Qt::Qml
    KF6::ModemManagerQt
    KF6::NetworkManagerQt
    KF6::CoreAddons
    KF6::I18n
)

set_property(TARGET ppc-mmqmlplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/mm)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/mm)

install(TARGETS ppc-mmqmlplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mm)
install(FILES qmldir ${qml_SRC} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/mm)
