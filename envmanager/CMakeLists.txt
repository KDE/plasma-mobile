# SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(plasma-mobile-envmanager_SRCS
    main.cpp
    settings.cpp
    utils.cpp
    config.h
)

add_executable(plasma-mobile-envmanager ${plasma-mobile-envmanager_SRCS} ${RESOURCES})
target_link_libraries(plasma-mobile-envmanager
    Qt::Qml
    Qt::Gui
    Qt::Widgets
    Qt::Quick
    KF6::I18n
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::CoreAddons
    KF6::DBusAddons
    KF6::Package
)

target_include_directories(plasma-mobile-envmanager PRIVATE ${CMAKE_BINARY_DIR})
install(TARGETS plasma-mobile-envmanager ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

