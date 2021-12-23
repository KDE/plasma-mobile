# SPDX-FileCopyrightText: 2021 Tobias Fella <fella@posteo.de>
# SPDX-License-Identifier: GPL-2.0-or-later

add_library(ppc-mmqmlplugin)
target_sources(ppc-mmqmlplugin PRIVATE
    mmqmlplugin.cpp
    signalindicator.cpp
)

target_link_libraries(ppc-mmqmlplugin
    Qt5::Qml
    KF5::ModemManagerQt
)

set_property(TARGET ppc-mmqmlplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/mm)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/mm)

install(TARGETS ppc-mmqmlplugin DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/mm)
install(FILES qmldir ${qml_SRC} DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/mm)
