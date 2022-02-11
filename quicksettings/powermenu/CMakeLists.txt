# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(powermenuplugin_SRCS
    powermenuplugin.cpp
    powermenuutil.cpp
)

add_library(powermenuplugin ${powermenuplugin_SRCS})

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS 
    Config
    Declarative
)

find_package(PW::KWorkspace)

target_link_libraries(powermenuplugin
        PUBLIC
            Qt::Core
        PRIVATE
            KF5::CoreAddons
            KF5::QuickAddons
            PW::KWorkspace
    )
    
set_property(TARGET powermenuplugin PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/powermenu)
file(COPY qmldir DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/org/kde/plasma/quicksetting/powermenu)

install(TARGETS powermenuplugin DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/quicksetting/powermenu)
install(FILES qmldir ${qml_SRC} DESTINATION ${QML_INSTALL_DIR}/org/kde/plasma/quicksetting/powermenu)

plasma_install_package(package org.kde.plasma.powermenu quicksettings)
